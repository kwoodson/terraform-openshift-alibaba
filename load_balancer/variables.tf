variable "slb_name" {
  type    = string
  default = "ocp-slb"
}

variable "vpc_id" {
  type = string
}

variable "vswitch_id" {
  type = string
}

variable "region" {
  type = string
}

variable "availability_zone" {
  type = string
}
variable "public_zone_id" {
  type = string
}

variable "private_zone_id" {
  type = string
}

variable "public_domain" {
  type = string
}

variable "api_endpoint" {
  type = string
}

variable "account_id" {
  type = string
  # sensitive = true
}

variable "load_balancer_address_type" {
  type    = string
  default = "intranet"
}

variable "backend_servers" {
  type = list(any)
}

variable "cluster_name" {
  type = string
}