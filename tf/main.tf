provider "opc" {
  user            = "${var.user}"
  password        = "${var.password}"
  identity_domain = "${var.identity_domain}"
  endpoint        = "${var.endpoint}"
}

resource "opc_compute_ssh_key" "ssh_key" {
  name    = "ssh_key"
  key     = "${file(var.ssh_public_key)}"
  enabled = true
}

resource "opc_compute_ip_network_exchange" "demoIPX" {
  name        = "demoIPX"
  description = "Demo IP Exchange"
  tags              = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_ip_network" "external-network" {
  name                = "external-network"
  description         = "external-network"
  ip_address_prefix   = "192.168.0.0/24"
  ip_network_exchange = ""
  tags              = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_protocol" "icmp" {
  name        = "icmp"
  ip_protocol = "icmp"
  tags              = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_protocol" "ssh" {
  name        = "ssh"
  dst_ports   = ["22"]
  ip_protocol = "tcp"
  tags              = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_protocol" "http" {
  name        = "http"
  dst_ports   = ["80"]
  ip_protocol = "tcp"
  tags              = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_protocol" "https" {
  name        = "https"
  dst_ports   = ["443"]
  ip_protocol = "tcp"
  tags              = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_protocol" "squid" {
  name        = "squid"
  dst_ports   = ["3128"]
  ip_protocol = "tcp"
  tags        = ["computeclassic-demo", "admin_stack"]
}
