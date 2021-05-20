resource "alicloud_nas_file_system" "foo" {
  protocol_type = var.proto_type
  encrypt_type  = var.encrypt_type
  storage_type  = var.storage_type
}

resource "alicloud_nas_access_group" "access_group" {
  access_group_name = "registry"
  access_group_type = "Vpc"
}

resource "alicloud_nas_mount_target" "registry" {
  file_system_id    = alicloud_nas_file_system.foo.id
  vswitch_id        = var.vswitch_id
  access_group_name = "registry"
}