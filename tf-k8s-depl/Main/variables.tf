locals {
  timestamp = "${timestamp()}"
  timestamp_sanitized = "${replace("${local.timestamp}", "/[-| |T|Z|:]/", "")}"

}

variable "dns_prefix" {
  default = "k8stest"
}

variable "initials" {
  default = "kk"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "azure_prefix" {
  default       = "azure"
  description   = "Prefix of the azure resource."
}

variable "azure_location" {
  default       = "westus"
  description   = "Location of the azure resource."
}

variable "agent_count" {
  default = 2
}
