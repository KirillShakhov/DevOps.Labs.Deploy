resource "yandex_vpc_network" "devops_network" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "devops_subnet" {
  network_id     = yandex_vpc_network.devops_network.id
  v4_cidr_blocks = var.v4_cidr_blocks
  zone           = var.zone
}

resource "yandex_vpc_address" "devops_static_ip" {
  name = "devops-static-ip"

  external_ipv4_address {
    zone_id = var.zone
  }
}
