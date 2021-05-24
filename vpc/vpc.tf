resource "alicloud_vpc" "vpc" {
  vpc_name   = var.vpc_name
  cidr_block = var.vpc_cidr
}

resource "alicloud_vswitch" "vsw" {
  count        = length(var.vsw_cidrs)
  vswitch_name = length(var.vsw_cidrs) > 1 || var.use_num_suffix ? format("%s%03d", var.vsw_name, count.index + 1) : var.vsw_name
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = var.vsw_cidrs[count.index]
  zone_id      = element(var.zone_id, count.index)
}
