resource "alicloud_oss_bucket" "bucket" {
  bucket = var.oss_bucket_name
  # THIS NEEDS TO CHANGE! publid-read to enable access to ignition files on boot
  acl = "public-read"
}

resource "alicloud_oss_bucket_object" "bootstrap_ign" {
  bucket = alicloud_oss_bucket.bucket.bucket
  key    = "ign/bootstrap.ign"
  source = "${var.ignition_path}/bootstrap.ign"
  acl    = "public-read"
}

resource "alicloud_oss_bucket_object" "master_ign" {
  bucket = alicloud_oss_bucket.bucket.bucket
  key    = "ign/master.ign"
  source = "${var.ignition_path}/master.ign"
  acl    = "public-read"
}

resource "alicloud_oss_bucket_object" "worker_ign" {
  bucket = alicloud_oss_bucket.bucket.bucket
  key    = "ign/worker.ign"
  source = "${var.ignition_path}/worker.ign"
  acl    = "public-read"
}