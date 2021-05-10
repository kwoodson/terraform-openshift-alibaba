output "instance_ids" {
  #   value = alicloud_instance.instance.*.id
  value = data.alicloud_instances.created.instances
}