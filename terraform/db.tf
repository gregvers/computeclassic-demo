resource "opc_compute_ip_network" "db-network" {
  name                = "db-network"
  description         = "db-network"
  ip_address_prefix   = "192.168.5.0/24"
  ip_network_exchange = "${opc_compute_ip_network_exchange.demoIPX.name}"
  tags                = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_acl" "db-int-acl" {
  name = "db-int-acl"
  tags = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_protocol" "mongodb" {
  name        = "mongodb"
  dst_ports   = ["27017"]
  ip_protocol = "tcp"
  tags        = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "db-from-jumphost" {
  name               = "db-from-jumphost"
  flow_direction     = "ingress"
  acl                = "${opc_compute_acl.db-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.ssh.name}", "${opc_compute_security_protocol.icmp.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.jumphost-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.db-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "db-to-proxy" {
  name               = "db-to-proxy"
  flow_direction     = "egress"
  acl                = "${opc_compute_acl.db-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.icmp.name}", "${opc_compute_security_protocol.squid.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.db-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.proxy-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "db-from-apps" {
  name               = "db-from-apps"
  flow_direction     = "ingress"
  acl                = "${opc_compute_acl.db-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.mongodb.name}", "${opc_compute_security_protocol.icmp.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.apps-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.db-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_vnic_set" "db-int-vnicset" {
  name         = "db-int-vnicset"
  applied_acls = ["${opc_compute_acl.db-int-acl.name}"]
  tags         = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_instance" "db" {
  name       = "db"
  hostname   = "db"
  label      = "db"
  shape      = "oc3"
  image_list = "/oracle/public/OL_7.2_UEKR4_x86_64"
  ssh_keys = ["${opc_compute_ssh_key.ssh_key.name}"]
  networking_info {
    index      = 0
    ip_network = "${opc_compute_ip_network.db-network.name}"
    vnic_sets  = ["${opc_compute_vnic_set.db-int-vnicset.name}"]
    dns = ["db"]
    is_default_gateway = "true"
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
        "yum install -y ./epel-release-latest-7.noarch.rpm",
        "yum install --enablerepo ol7_addons -y docker-engine",
        "systemctl enable docker",
        "echo 'http_proxy=http://proxy:3128' >> /etc/sysconfig/docker",
        "systemctl start docker",
        "docker pull mongo",
        "docker run -d -p 27017:27017 mongo"
      ]
    }
  }
}
JSON
  tags = ["computeclassic-demo", "application_stack"]
  depends_on = ["opc_compute_instance.proxy"]
}

output "db private IP" {
  value = "${opc_compute_instance.db.ip_address}"
}
