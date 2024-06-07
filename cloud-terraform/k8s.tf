locals {
  folder_id = var.folder_id
}

resource "yandex_iam_service_account" "k8s_account" {
  name        = "k8s-service-account"
  description = "Service account for Kubernetes cluster"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  folder_id = local.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  folder_id = local.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  folder_id = local.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_account.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  folder_id = local.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_account.id}"
}

resource "yandex_kms_symmetric_key" "kms_key" {
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // 1 year
}

resource "yandex_vpc_security_group" "k8s_public_services" {
  name        = "k8s-public-services"
  description = "Security group for public services in Kubernetes cluster"
  network_id  = yandex_vpc_network.devops_network.id

  ingress {
    protocol          = "TCP"
    description       = "Allow availability checks from load balancer"
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol          = "ANY"
    description       = "Allow master-to-node and node-to-node communication"
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol          = "ANY"
    description       = "Allow pod-to-pod and service-to-service communication"
    v4_cidr_blocks    = yandex_vpc_subnet.devops_subnet.v4_cidr_blocks
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol       = "ICMP"
    description    = "Allow debugging ICMP packets from internal subnets"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow incoming traffic from the internet to NodePort range"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name        = "k8s-zonal"
  description = "Kubernetes cluster in a single zone"

  network_id = yandex_vpc_network.devops_network.id

  master {
    version = "1.27"

    zonal {
      zone      = yandex_vpc_subnet.devops_subnet.zone
      subnet_id = yandex_vpc_subnet.devops_subnet.id
    }

    public_ip = true

    security_group_ids = [yandex_vpc_security_group.k8s_public_services.id]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.k8s_account.id
  node_service_account_id = yandex_iam_service_account.k8s_account.id

  labels = {
    my_key       = "my_value"
    my_other_key = "my_other_value"
  }

  release_channel         = "RAPID"
  network_policy_provider = "CALICO"

  kms_provider {
    key_id = yandex_kms_symmetric_key.kms_key.id
  }
}

resource "yandex_kubernetes_node_group" "worker_nodes" {
  cluster_id  = yandex_kubernetes_cluster.k8s_cluster.id
  name        = "worker-nodes"
  description = "Worker nodes for Kubernetes cluster"
  version     = "1.27"

  labels = {
    "key" = "value"
  }

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.devops_subnet.id]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  depends_on = [
    yandex_kubernetes_cluster.k8s_cluster,
  ]
}
