variable user {}
variable password {}
variable identity_domain {}
variable compute_endpoint {}

variable ssh_public_key {
  description = "ssh public key"
  default     = "~/.ssh/id_rsa.pub"
}

provider "opc" {
  user            = "${var.user}"
  password        = "${var.password}"
  identity_domain = "${var.identity_domain}"
  endpoint        = "${var.compute_endpoint}"
}
