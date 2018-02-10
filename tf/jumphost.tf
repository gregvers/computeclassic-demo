resource "opc_compute_ip_network" "jumphost-network" {
  name                = "jumphost-network"
  description         = "jumphost-network"
  ip_address_prefix   = "192.168.1.0/24"
  ip_network_exchange = "${opc_compute_ip_network_exchange.demoIPX.name}"
  tags                = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_ip_address_reservation" "jumphost-ip" {
  name            = "jumphost-ip"
  ip_address_pool = "public-ippool"
  tags            = ["computeclassic-demo", "admin_stack"]
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

resource "opc_compute_acl" "jumphost-int-acl" {
  name = "jumphost-int-acl"
  tags = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_acl" "jumphost-ext-acl" {
  name = "jumphost-ext-acl"
  tags = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_rule" "jumphost-from-anywhere" {
  name               = "jumphost-from-anywhere"
  flow_direction     = "ingress"
  acl                = "${opc_compute_acl.jumphost-ext-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.ssh.name}", "${opc_compute_security_protocol.icmp.name}"]
  dst_vnic_set       = "${opc_compute_vnic_set.jumphost-ext-vnicset.name}"
  tags               = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_rule" "jumphost-to-proxy" {
  name               = "jumphost-to-proxy"
  flow_direction     = "egress"
  acl                = "${opc_compute_acl.jumphost-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.ssh.name}", "${opc_compute_security_protocol.icmp.name}", "${opc_compute_security_protocol.squid.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.jumphost-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.proxy-int-vnicset.name}"
  tags               = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_rule" "jumphost-to-anywhere" {
  name               = "jumphost-to-anywhere"
  flow_direction     = "egress"
  acl                = "${opc_compute_acl.jumphost-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.ssh.name}", "${opc_compute_security_protocol.icmp.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.jumphost-int-vnicset.name}"
  tags               = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_vnic_set" "jumphost-int-vnicset" {
  name         = "jumphost-int-vnicset"
  applied_acls = ["${opc_compute_acl.jumphost-int-acl.name}"]
  tags         = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_vnic_set" "jumphost-ext-vnicset" {
  name         = "jumphost-ext-vnicset"
  applied_acls = ["${opc_compute_acl.jumphost-ext-acl.name}"]
  tags         = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_instance" "jumphost" {
  name         = "jumphost"
  hostname     = "jumphost"
  label        = "jumphost"
  shape        = "oc3"
  image_list   = "/oracle/public/OL_7.2_UEKR4_x86_64"
  ssh_keys     = ["${opc_compute_ssh_key.ssh_key.name}"]
  networking_info {
    index      = 0
    ip_network = "${opc_compute_ip_network.external-network.name}"
    vnic_sets  = ["${opc_compute_vnic_set.jumphost-ext-vnicset.name}"]
    nat        = ["${opc_compute_ip_address_reservation.jumphost-ip.name}"]
    is_default_gateway = "true"
  }
  networking_info {
    index      = 1
    ip_network = "${opc_compute_ip_network.jumphost-network.name}"
    vnic_sets  = ["${opc_compute_vnic_set.jumphost-int-vnicset.name}"]
    dns = ["jumphost"]
  }
  instance_attributes = <<JSON
{
  "userdata": {
    "pre-bootstrap": {
      "script": [
        "sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/ksplice-uptrack.repo",
        "echo 'proxy=http://proxy:3128' >> /etc/yum.conf",
        "cd /tmp",
        "until curl --proxy http://proxy:3128 -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm; do sleep 10; done",
        "yum install -y ./epel-release-latest-7.noarch.rpm"
      ]
    }
  }
}
JSON
  tags = ["computeclassic-demo", "admin_stack"]
}

output "Jumphost NAT IP" {
  value = "${opc_compute_ip_address_reservation.jumphost-ip.ip_address}"
}
