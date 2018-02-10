resource "opc_compute_ip_network" "proxy-network" {
  name                = "proxy-network"
  description         = "proxy-network"
  ip_address_prefix   = "192.168.2.0/24"
  ip_network_exchange = "${opc_compute_ip_network_exchange.demoIPX.name}"
  tags                = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_ip_address_reservation" "proxy-ip" {
  name            = "proxy-ip"
  ip_address_pool = "public-ippool"
  tags            = ["computeclassic-demo", "admin_stack"]
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

resource "opc_compute_acl" "proxy-int-acl" {
  name = "proxy-int-acl"
  tags = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_acl" "proxy-ext-acl" {
  name = "proxy-ext-acl"
  tags = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_rule" "proxy-from-jumphost" {
  name               = "proxy-from-jumphost"
  flow_direction     = "ingress"
  acl                = "${opc_compute_acl.proxy-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.ssh.name}", "${opc_compute_security_protocol.icmp.name}", "${opc_compute_security_protocol.squid.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.jumphost-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.proxy-int-vnicset.name}"
  tags               = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_rule" "proxy-from-anywhere" {
  name               = "proxy-from-anywhere"
  flow_direction     = "ingress"
  acl                = "${opc_compute_acl.proxy-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.icmp.name}", "${opc_compute_security_protocol.squid.name}"]
  dst_vnic_set       = "${opc_compute_vnic_set.proxy-int-vnicset.name}"
  tags               = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_security_rule" "proxy-to-anywhere" {
  name               = "proxy-to-anywhere"
  flow_direction     = "egress"
  acl                = "${opc_compute_acl.proxy-ext-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.http.name}", "${opc_compute_security_protocol.https.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.proxy-ext-vnicset.name}"
  tags               = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_vnic_set" "proxy-int-vnicset" {
  name         = "proxy-int-vnicset"
  applied_acls = ["${opc_compute_acl.proxy-int-acl.name}"]
  tags         = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_vnic_set" "proxy-ext-vnicset" {
  name         = "proxy-ext-vnicset"
  applied_acls = ["${opc_compute_acl.proxy-ext-acl.name}"]
  tags         = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_instance" "proxy" {
  name         = "proxy"
  hostname     = "proxy"
  label        = "proxy"
  shape        = "oc3"
  image_list   = "/oracle/public/OL_6.8_UEKR4_x86_64"
  ssh_keys     = ["${opc_compute_ssh_key.ssh_key.name}"]
  networking_info {
    index      = 0
    ip_network = "${opc_compute_ip_network.external-network.name}"
    vnic_sets  = ["${opc_compute_vnic_set.proxy-ext-vnicset.name}"]
    nat        = ["${opc_compute_ip_address_reservation.proxy-ip.name}"]
    is_default_gateway = "true"
  }
  networking_info {
    index      = 1
    ip_network = "${opc_compute_ip_network.proxy-network.name}"
    vnic_sets  = ["${opc_compute_vnic_set.proxy-int-vnicset.name}"]
    dns = ["proxy"]
  }
  instance_attributes = <<JSON
{
  "userdata": {
    "pre-bootstrap": {
      "script": [
        "sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/ksplice-uptrack.repo",
        "sysctl -w net.ipv4.ip_forward=1 net.ipv4.conf.eth0.send_redirects=0",
        "iptables -t nat -A POSTROUTING -o eth0 -s 0.0.0.0/0 -j MASQUERADE",
        "yum -y install squid",
        "service squid start"
      ]
    }
  }
}
JSON
  tags = ["computeclassic-demo", "admin_stack"]
}

resource "opc_compute_route" "proxy-route" {
  name              = "proxy-route"
  description       = "route to internet through proxy"
  admin_distance    = 2
  ip_address_prefix = "0.0.0.0/0"
  next_hop_vnic_set = "${opc_compute_vnic_set.proxy-int-vnicset.name}"
  tags              = ["computeclassic-demo", "admin_stack"]
}

output "proxy private IP" {
  value = "${opc_compute_instance.proxy.ip_address}"
}
