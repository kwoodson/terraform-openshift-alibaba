variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "account_id" {
  type = string
  //sensitive = true
}

variable "public_domain" {
  type = string
}

variable "master_instance_type" {
  type = string
}

variable "bootstrap_instance_type" {
  type = string
}

variable "worker_instance_type" {
  type = string
}

variable "region" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "image_id" {
  type = string
}

variable "oss_bucket_name" {
  type = string
}

variable "ignition_path" {
  type = string
}

variable "api_endpoint" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "public_ssh_key" {
  type = string
}