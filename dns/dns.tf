resource "alicloud_pvtz_zone" "pvt_zone" {
  zone_name = "168.192.in-addr.arpa"
}

resource "alicloud_pvtz_zone" "pub_zone" {
  zone_name = var.public_domain
}

resource "alicloud_pvtz_zone_attachment" "attach_pvt_zone" {
  zone_id = alicloud_pvtz_zone.pvt_zone.id
  vpc_ids = [var.vpc_id]
}

resource "alicloud_pvtz_zone_attachment" "attach_pub_zone" {
  zone_id = alicloud_pvtz_zone.pub_zone.id
  vpc_ids = [var.vpc_id]
}