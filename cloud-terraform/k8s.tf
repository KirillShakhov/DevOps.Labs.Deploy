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

resource "null_resource" "wait_for_roles" {
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter,
  ]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "yandex_kubernetes_cluster" "k8s_cluster" {
  depends_on = [null_resource.wait_for_roles]

  name        = "k8s-devops"
  description = "Kubernetes cluster in a single zone"

  network_id = "default"

  master {
    version = "1.28"

    zonal {
      zone      = var.zone
      subnet_id = "default"
    }

    public_ip = true

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
}

resource "yandex_kubernetes_node_group" "worker_nodes" {
  cluster_id  = yandex_kubernetes_cluster.k8s_cluster.id
  name        = "worker-nodes"
  description = "Worker nodes for Kubernetes cluster"
  version     = "1.28"

  labels = {
    "key" = "value"
  }

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = ["default"]
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
