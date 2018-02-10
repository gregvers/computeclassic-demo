resource "opc_compute_ip_network" "lbr-network" {
  name                = "lbr-network"
  description         = "lbr-network"
  ip_address_prefix   = "192.168.3.0/24"
  ip_network_exchange = "${opc_compute_ip_network_exchange.demoIPX.name}"
  tags                = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_ip_address_reservation" "lbr-ip" {
  name                = "lbr-ip"
  ip_address_pool     = "public-ippool"
  tags                = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_acl" "lbr-ext-acl" {
  name = "lbr-ext-acl"
  tags = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "lbr-from-anywhere" {
  name               = "lbr-from-anywhere"
  flow_direction     = "ingress"
  acl                = "${opc_compute_acl.lbr-ext-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.http.name}"]
  dst_vnic_set       = "${opc_compute_vnic_set.lbr-ext-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_acl" "lbr-int-acl" {
  name = "lbr-int-acl"
  tags = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "lbr-from-jumphost" {
  name               = "lbr-from-jumphost"
  flow_direction     = "ingress"
  acl                = "${opc_compute_acl.lbr-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.ssh.name}", "${opc_compute_security_protocol.icmp.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.jumphost-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.lbr-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "lbr-to-proxy" {
  name               = "lbr-to-proxy"
  flow_direction     = "egress"
  acl                = "${opc_compute_acl.lbr-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.icmp.name}", "${opc_compute_security_protocol.squid.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.lbr-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.proxy-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_security_rule" "lbr-to-apps" {
  name               = "lbr-to-apps"
  flow_direction     = "egress"
  acl                = "${opc_compute_acl.lbr-int-acl.name}"
  security_protocols = ["${opc_compute_security_protocol.icmp.name}", "${opc_compute_security_protocol.tcp8080.name}"]
  src_vnic_set       = "${opc_compute_vnic_set.lbr-int-vnicset.name}"
  dst_vnic_set       = "${opc_compute_vnic_set.apps-int-vnicset.name}"
  tags               = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_vnic_set" "lbr-ext-vnicset" {
  name         = "lbr-ext-vnicset"
  applied_acls = ["${opc_compute_acl.lbr-ext-acl.name}"]
  tags         = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_vnic_set" "lbr-int-vnicset" {
  name         = "lbr-int-vnicset"
  applied_acls = ["${opc_compute_acl.lbr-int-acl.name}"]
  tags         = ["computeclassic-demo", "application_stack"]
}

resource "opc_compute_instance" "lbr" {
  name       = "lbr"
  hostname   = "lbr"
  label      = "lbr"
  shape      = "oc3"
  image_list = "/oracle/public/OL_7.2_UEKR4_x86_64"
  ssh_keys = ["${opc_compute_ssh_key.ssh_key.name}"]
  networking_info {
    index      = 0
    ip_network = "${opc_compute_ip_network.external-network.name}"
    vnic_sets  = ["${opc_compute_vnic_set.lbr-ext-vnicset.name}"]
    nat        = ["${opc_compute_ip_address_reservation.lbr-ip.name}"]
    is_default_gateway = "true"
  }
  networking_info {
    index      = 1
    ip_network = "${opc_compute_ip_network.lbr-network.name}"
    vnic_sets  = ["${opc_compute_vnic_set.lbr-int-vnicset.name}"]
    dns = ["lbr"]
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
        "yum install -y nginx",
        "echo 'events {                             ' > /etc/nginx/nginx.conf",
        "echo '  worker_connections  1024;          ' >> /etc/nginx/nginx.conf",
        "echo '}                                    ' >> /etc/nginx/nginx.conf",
        "echo 'http {                               ' >> /etc/nginx/nginx.conf",
        "echo ' upstream apps {                     ' >> /etc/nginx/nginx.conf",
        "echo '   server apps0:8080;                ' >> /etc/nginx/nginx.conf",
        "echo ' }                                   ' >> /etc/nginx/nginx.conf",
        "echo ' server {                            ' >> /etc/nginx/nginx.conf",
        "echo '   listen 80;                        ' >> /etc/nginx/nginx.conf",
        "echo '   location / {                      ' >> /etc/nginx/nginx.conf",
        "echo '     proxy_pass http://apps;         ' >> /etc/nginx/nginx.conf",
        "echo '   }                                 ' >> /etc/nginx/nginx.conf",
        "echo ' }                                   ' >> /etc/nginx/nginx.conf",
        "echo '}                                    ' >> /etc/nginx/nginx.conf",
        "service nginx start"
      ]
    }
  }
}
JSON
  tags = ["computeclassic-demo", "application_stack"]
  depends_on = ["opc_compute_instance.apps", "opc_compute_instance.proxy"]
}

output "LBR NAT IP" {
  value = "${opc_compute_ip_address_reservation.lbr-ip.ip_address}"
}
