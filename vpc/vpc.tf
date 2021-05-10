resource "alicloud_vpc" "vpc" {
  vpc_name   = var.vpc_name
  cidr_block = "192.168.0.0/16"
}

resource "alicloud_vswitch" "vsw" {
  vswitch_name = var.vswitch_name
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "192.168.1.0/24"
  zone_id      = "us-east-a"
}
