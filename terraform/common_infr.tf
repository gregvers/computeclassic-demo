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
