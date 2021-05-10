output "private_zone_id" {
  value = alicloud_pvtz_zone.pvt_zone.id
}

output "public_zone_id" {
  value = alicloud_pvtz_zone.pub_zone.id
}