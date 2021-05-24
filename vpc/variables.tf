variable "vsw_name" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vsw_cidrs" {
  type      = list(any)
}

variable "zone_id" {
  type      = list(any)
}

variable "use_num_suffix" {
  type        = bool
  default     = false
}