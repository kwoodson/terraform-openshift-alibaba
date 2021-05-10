resource "alicloud_nas_file_system" "foo" {
  protocol_type = var.proto_type
  encrypt_type  = var.encrypt_type
  storage_type  = var.storage_type
}