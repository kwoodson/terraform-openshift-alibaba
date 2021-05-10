resource "alicloud_nat_gateway" "gw" {
  vpc_id        = var.vpc_id
  specification = "Small"
  name          = "ocp-natgw"
  nat_type      = "Enhanced"
  vswitch_id    = var.vswitch_id
}

resource "alicloud_eip" "eip" {
  name = "eip-ocp"
}

resource "alicloud_snat_entry" "snat" {
  snat_table_id     = alicloud_nat_gateway.gw.snat_table_ids
  source_vswitch_id = var.vswitch_id
  snat_ip           = alicloud_eip.eip.ip_address
}

resource "alicloud_eip_association" "assoc" {
  allocation_id = alicloud_eip.eip.id
  instance_id   = alicloud_nat_gateway.gw.id
}

resource "alicloud_common_bandwidth_package" "default" {
  bandwidth_package_name = "tf_cbp"
  bandwidth              = 10
  internet_charge_type   = "PayByTraffic"
  ratio                  = 100
}

resource "alicloud_common_bandwidth_package_attachment" "default" {
  bandwidth_package_id = alicloud_common_bandwidth_package.default.id
  instance_id          = alicloud_eip.eip.id
}