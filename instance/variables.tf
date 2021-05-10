variable "vpc_id" {
  type = string
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "sg_id" {
  type = string
}

variable "vswitch_id" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "image_id" {
  type = string
}

variable "az" {
  type        = string
  description = "availability zone"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "private_zone_id" {
  type = string
}

variable "public_zone_id" {
  type = string
}

variable "ignition_url" {
  type    = string
  default = ""
}

variable "public_domain" {
  type = string
}

variable "max_bandwidth_out" {
  type    = number
  default = 0
}

variable "cluster_name" {
  type = string
}

variable "public_ssh_key" {
  type    = string
  default = ""
}