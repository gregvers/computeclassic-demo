variable "apps-hostnames" {
  default = {
    "1" = "apps1"
    "2" = "apps2"
  }
}

resource "opc_compute_ip_network" "apps-network" {
  name                = "apps-network"
  description         = "apps-network"
  ip_address_prefix   = "192.168.4.0/24"
  ip_network_exchange = "${opc_compute_ip_network_exchange.demoIPX.name}"
  tags                = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_acl" "apps-int-acl" {
  name = "apps-int-acl"
  tags = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_protocol" "tcp8080" {
  name        = "tcp8080"
  dst_ports   = ["8080"]
  ip_protocol = "tcp"
  tags        = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "apps-from-jumphost" {
  name               = "apps-from-jumphost"
  flow_direction     = "ingress"
  acl                = "${opc_compute_acl.apps-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.ssh.name}", "${opc_compute_security_protocol.icmp.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.jumphost-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.apps-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "apps-to-proxy" {
  name               = "apps-to-proxy"
  flow_direction     = "egress"
  acl                = "${opc_compute_acl.apps-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.icmp.name}", "${opc_compute_security_protocol.squid.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.apps-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.proxy-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "apps-from-lbr" {
  name               = "apps-from-lbr"
  flow_direction     = "ingress"
  acl                = "${opc_compute_acl.apps-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.tcp8080.name}", "${opc_compute_security_protocol.icmp.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.lbr-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.apps-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "apps-to-db" {
  name               = "apps-to-db"
  flow_direction     = "egress"
  acl                = "${opc_compute_acl.apps-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.icmp.name}", "${opc_compute_security_protocol.mongodb.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.apps-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.db-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_vnic_set" "apps-int-vnicset" {
  name         = "apps-int-vnicset"
  applied_acls = ["${opc_compute_acl.apps-int-acl.name}"]
  tags         = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_instance" "apps" {
  count      = 1
  name       = "apps${count.index}"
  hostname   = "apps${count.index}"
  label      = "apps${count.index}"
  shape      = "oc3"
  image_list = "/oracle/public/OL_7.2_UEKR4_x86_64"
  ssh_keys = ["${opc_compute_ssh_key.ssh_key.name}"]
  networking_info {
    index      = 0
    ip_network = "${opc_compute_ip_network.apps-network.name}"
    vnic_sets  = ["${opc_compute_vnic_set.apps-int-vnicset.name}"]
    dns = ["apps${count.index}"]
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
        "docker pull gregvers/hitcount",
        "docker run -d -e HOST_HOSTNAME=`hostname` -e MONGODB_SERVICE_HOST='db' -e MONGODB_SERVICE_PORT='27017' -p 8080:3000 gregvers/hitcount"
      ]
    }
  }
}
JSON
  tags = ["computeclassic-demo", "application_stack"]
  depends_on = ["opc_compute_instance.proxy"]
}

output "apps private IP" {
  value = "${opc_compute_instance.apps.ip_address}"
}
