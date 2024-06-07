// Common
variable "service_account_key_file" {
  type    = string
  default = "./key/key.json"
}

variable "cloud_id" {
  type = string
  default = "b1gn3qr6tj34r8cf7u85"
}

variable "folder_id" {
  type = string
  default = "b1g2eu9iuna0k6l2b6aq"
}

variable "zone" {
  type = string
  default = "ru-central1-a"
}
