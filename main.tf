provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "vpc" {
  source       = "./vpc"
  vpc_name     = var.vpc_name
  vpc_cidr     = var.vpc_cidr
  vsw_name     = var.vsw_name
  vsw_cidrs    = var.vsw_cidrs
  zone_id      = var.zone_id
}

module "oss" {
  source          = "./oss"
  oss_bucket_name = var.oss_bucket_name
  ignition_path   = var.ignition_path
}

module "security_group" {
  source = "./security_group"
  vpc_id = module.vpc.vpc_id
}

module "nat_gateway" {
  source     = "./nat_gateway"
  vpc_id     = module.vpc.vpc_id
  vswitch_id = module.vpc.vswitch_id
}

module "load_balancer" {
  source            = "./load_balancer"
  region            = var.region
  availability_zone = var.availability_zone
  public_domain     = var.public_domain
  public_zone_id    = module.dns.public_zone_id
  private_zone_id   = module.dns.private_zone_id
  vswitch_id        = module.vpc.vswitch_id
  vpc_id            = module.vpc.vpc_id
  api_endpoint      = var.api_endpoint
  account_id        = var.account_id
  # backend_servers   = concat(module.master.instance_ids, module.worker.instance_ids, module.bootstrap.instance_ids)
  masters      = module.master.instance_ids
  workers      = module.worker.instance_ids
  bootstrap    = module.bootstrap.instance_ids
  cluster_name = var.cluster_name
}

module "nas" {
  source       = "./nas"
  proto_type   = "NFS"
  encrypt_type = "0"
  storage_type = "Capacity"
  vswitch_id   = module.vpc.vswitch_id
}

module "dns" {
  source        = "./dns"
  vpc_id        = module.vpc.vpc_id
  public_domain = var.public_domain
}

module "bootstrap" {
  source = "./instance"

  ignition_url      = "https://${var.oss_bucket_name}.oss-${var.region}.aliyuncs.com/ign/bootstrap.ign"
  region            = var.region
  az                = var.availability_zone
  vpc_id            = module.vpc.vpc_id
  sg_id             = module.security_group.sg_id
  vswitch_id        = module.vpc.vswitch_id
  instance_name     = "bootstrap"
  instance_type     = var.bootstrap_instance_type
  image_id          = var.image_id
  private_zone_id   = module.dns.private_zone_id
  public_zone_id    = module.dns.public_zone_id
  public_domain     = var.public_domain
  max_bandwidth_out = 10
  cluster_name      = var.cluster_name
}

module "master" {
  source = "./instance"

  ignition_url    = "https://${var.oss_bucket_name}.oss-${var.region}.aliyuncs.com/ign/master.ign"
  instance_count  = 3
  region          = var.region
  az              = var.availability_zone
  vpc_id          = module.vpc.vpc_id
  sg_id           = module.security_group.sg_id
  vswitch_id      = module.vpc.vswitch_id
  instance_name   = "master"
  instance_type   = var.master_instance_type
  image_id        = var.image_id
  private_zone_id = module.dns.private_zone_id
  public_zone_id  = module.dns.public_zone_id
  public_domain   = var.public_domain
  cluster_name    = var.cluster_name

}

module "worker" {
  source = "./instance"

  ignition_url    = "https://${var.oss_bucket_name}.oss-${var.region}.aliyuncs.com/ign/worker.ign"
  instance_count  = 3
  region          = var.region
  az              = var.availability_zone
  vpc_id          = module.vpc.vpc_id
  sg_id           = module.security_group.sg_id
  vswitch_id      = module.vpc.vswitch_id
  instance_name   = "worker"
  instance_type   = var.worker_instance_type
  image_id        = var.image_id
  private_zone_id = module.dns.private_zone_id
  public_zone_id  = module.dns.public_zone_id
  public_domain   = var.public_domain
  cluster_name    = var.cluster_name

}

// bastion
module "bastion" {
  source = "./instance"

  //ignition_url    = "https://${var.oss_bucket_name}.oss-${var.region}.aliyuncs.com/ign/worker.ign"
  instance_count    = 1
  region            = var.region
  az                = var.availability_zone
  vpc_id            = module.vpc.vpc_id
  sg_id             = module.security_group.sg_id
  vswitch_id        = module.vpc.vswitch_id
  instance_name     = "bastion"
  instance_type     = var.worker_instance_type
  image_id          = "centos_8_3_x64_20G_alibase_20210420.vhd"
  private_zone_id   = module.dns.private_zone_id
  public_zone_id    = module.dns.public_zone_id
  public_domain     = var.public_domain
  cluster_name      = var.cluster_name
  max_bandwidth_out = 10
  public_ssh_key    = var.public_ssh_key
}
