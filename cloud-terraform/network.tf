resource "yandex_vpc_network" "devops-network" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "devops-subnet" {
  network_id     = yandex_vpc_network.devops-network.id
  v4_cidr_blocks = var.v4_cidr_blocks
  zone           = var.zone
}

resource "yandex_vpc_address" "devops-static-ip" {
  name = "devops-static-ip"

  external_ipv4_address {
    zone_id = var.zone
  }
}
