data "template_file" "user_data" {
  template = file("instance/user_data")
  vars = {
    ignition_url   = "${var.ignition_url}"
    public_ssh_key = "${var.public_ssh_key}"
  }
}

resource "alicloud_instance" "instance" {
  count                = var.instance_count
  availability_zone    = var.az
  security_groups      = [var.sg_id]
  instance_type        = var.instance_type
  system_disk_category = "cloud_ssd"
  image_id             = var.image_id
  instance_name        = "${var.instance_name}${var.instance_name == "bootstrap" || var.instance_name == "bastion" ? "" : count.index}"
  vswitch_id           = var.vswitch_id
  // if this value is > 0 then it creates a public IP address
  internet_max_bandwidth_out = var.max_bandwidth_out
  user_data                  = data.template_file.user_data.rendered
}

data "alicloud_instances" "created" {
  ids = alicloud_instance.instance.*.id
}

resource "alicloud_pvtz_zone_record" "private_ptr" {
  count   = var.instance_count
  zone_id = var.private_zone_id
  rr      = join(".", reverse(slice(split(".", data.alicloud_instances.created.instances[count.index].private_ip), 2, 4)))
  type    = "PTR"
  value   = "${var.instance_name}${count.index}.${var.cluster_name}.${var.public_domain}"
  ttl     = 60
}

resource "alicloud_pvtz_zone_record" "public" {
  count   = var.instance_count
  zone_id = var.public_zone_id
  rr      = "${var.instance_name}${count.index}.${var.cluster_name}"
  value   = data.alicloud_instances.created.instances[count.index].private_ip
  type    = "A"
}

