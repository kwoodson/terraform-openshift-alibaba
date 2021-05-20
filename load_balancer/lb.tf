locals {
  backend_servers = concat(var.masters, var.workers, var.bootstrap)
  control_plane   = concat(var.masters, var.bootstrap)
}
resource "alicloud_slb" "ext_slb" {
  name           = "ocp_ext_slb"
  vswitch_id     = var.vswitch_id
  specification  = "slb.s2.small"
  address_type   = "internet"
  master_zone_id = var.availability_zone
}

resource "alicloud_slb" "int_slb" {
  name           = "ocp_int_slb"
  vswitch_id     = var.vswitch_id
  specification  = "slb.s2.small"
  master_zone_id = var.availability_zone
  address_type   = var.load_balancer_address_type
}

resource "alicloud_pvtz_zone_record" "api_pvt" {
  zone_id = var.private_zone_id
  rr      = join(".", reverse(slice(split(".", alicloud_slb.ext_slb.address), 2, 4)))
  type    = "PTR"
  value   = "api.${var.cluster_name}.${var.public_domain}"
  ttl     = 60
}

resource "alicloud_pvtz_zone_record" "api_int_pvt" {
  zone_id = var.private_zone_id
  rr      = join(".", reverse(slice(split(".", alicloud_slb.int_slb.address), 2, 4)))
  type    = "PTR"
  value   = "api-int.${var.cluster_name}.${var.public_domain}"
  ttl     = 60
}

resource "alicloud_pvtz_zone_record" "api_int_pub" {
  zone_id = var.public_zone_id
  value   = alicloud_slb.int_slb.address
  type    = "A"
  rr      = "api-int.${var.cluster_name}"
}

resource "alicloud_pvtz_zone_record" "api_pub" {
  zone_id = var.public_zone_id
  value   = alicloud_slb.ext_slb.address
  type    = "A"
  rr      = "api.${var.cluster_name}"
}

resource "alicloud_pvtz_zone_record" "apps" {
  zone_id = var.public_zone_id
  value   = alicloud_slb.ext_slb.address
  type    = "A"
  rr      = "*.apps.${var.cluster_name}"
}

# resource "alicloud_slb_backend_server" "default" {
#   load_balancer_id = alicloud_slb.slb.id

#   dynamic "backend_servers" {
#     for_each = [for inst in var.backend_servers : {
#       instance = inst
#       }
#     ]
#     content {
#       server_id = backend_servers.value.instance.id
#       weight    = 100
#     }
#   }

# }
resource "alicloud_slb_server_group" "masters_ext_6443" {
  load_balancer_id = alicloud_slb.ext_slb.id
  name             = "masters_ext_6443"
  servers {
    server_ids = local.control_plane.*.id
    port       = 6443
    weight     = 100
  }
}

resource "alicloud_slb_server_group" "masters_int_6443" {
  load_balancer_id = alicloud_slb.int_slb.id
  name             = "masters_int_6443"
  servers {
    server_ids = local.control_plane.*.id
    port       = 6443
    weight     = 100
  }
}
resource "alicloud_slb_server_group" "masters_int_22623" {
  load_balancer_id = alicloud_slb.int_slb.id
  name             = "masters_int_22623"
  servers {
    server_ids = local.control_plane.*.id
    port       = 22623
    weight     = 100
  }

}

resource "alicloud_slb_listener" "tcp_ext_6443" {
  load_balancer_id = alicloud_slb.ext_slb.id
  backend_port     = 6443
  frontend_port    = 6443
  protocol         = "tcp"
  bandwidth        = 100
  sticky_session   = "off"
  # sticky_session_type = "insert" // try server?
  cookie_timeout = 86400
  # cookie                    = "openshiftcookie" // 
  health_check        = "on"
  health_check_domain = var.public_domain
  # health_check_uri          = "/cons"
  health_check_connect_port = 6443
  healthy_threshold         = 8
  unhealthy_threshold       = 8
  health_check_timeout      = 8
  health_check_interval     = 5
  # health_check_http_code    = "http_2xx,http_3xx"
  # x_forwarded_for {
  #   retrive_slb_ip = true
  #   retrive_slb_id = true
  # }
  # acl_status = "on"
  # acl_type   = "white"
  # acl_id          = alicloud_slb_acl.acl_6443.id
  request_timeout = 60
  idle_timeout    = 20
  server_group_id = alicloud_slb_server_group.masters_ext_6443.id
}

resource "alicloud_slb_listener" "tcp_int_6443" {
  load_balancer_id          = alicloud_slb.int_slb.id
  backend_port              = 6443
  frontend_port             = 6443
  protocol                  = "tcp"
  bandwidth                 = 100
  sticky_session            = "off"
  cookie_timeout            = 86400
  health_check              = "on"
  health_check_domain       = var.public_domain
  health_check_connect_port = 6443
  healthy_threshold         = 8
  unhealthy_threshold       = 8
  health_check_timeout      = 8
  health_check_interval     = 5
  request_timeout           = 60
  idle_timeout              = 20
  server_group_id           = alicloud_slb_server_group.masters_int_6443.id
}

resource "alicloud_slb_server_group" "workers_443" {
  load_balancer_id = alicloud_slb.ext_slb.id
  name             = "workers_443"
  servers {
    server_ids = var.workers.*.id
    port       = 443
    weight     = 100
  }
}
resource "alicloud_slb_server_group" "workers_80" {
  load_balancer_id = alicloud_slb.ext_slb.id
  name             = "workers_80"
  servers {
    server_ids = var.workers.*.id
    port       = 80
    weight     = 100
  }

}


resource "alicloud_slb_listener" "tcp_443" {
  load_balancer_id = alicloud_slb.ext_slb.id
  backend_port     = 443
  frontend_port    = 443
  protocol         = "tcp"
  bandwidth        = 100
  sticky_session   = "off"
  # sticky_session_type = "insert" // try server?
  cookie_timeout            = 86400
  health_check              = "on"
  health_check_domain       = var.public_domain
  health_check_connect_port = 443
  healthy_threshold         = 8
  unhealthy_threshold       = 8
  health_check_timeout      = 8
  health_check_interval     = 5
  request_timeout           = 60
  idle_timeout              = 20
  server_group_id           = alicloud_slb_server_group.workers_443.id

}

resource "alicloud_slb_listener" "tcp_80" {
  load_balancer_id = alicloud_slb.ext_slb.id
  backend_port     = 80
  frontend_port    = 80
  protocol         = "tcp"
  bandwidth        = 100
  sticky_session   = "off"
  # sticky_session_type = "insert" // try server?
  cookie_timeout            = 86400
  health_check              = "on"
  health_check_domain       = var.public_domain
  health_check_connect_port = 80
  healthy_threshold         = 8
  unhealthy_threshold       = 8
  health_check_timeout      = 8
  health_check_interval     = 5
  request_timeout           = 60
  idle_timeout              = 20
  server_group_id           = alicloud_slb_server_group.workers_80.id

}

resource "alicloud_slb_listener" "tcp_22623" {
  load_balancer_id = alicloud_slb.int_slb.id
  backend_port     = 22623
  frontend_port    = 22623
  protocol         = "tcp"
  bandwidth        = 100
  sticky_session   = "off"
  # sticky_session_type = "insert" // try server?
  # cookie_timeout      = 86400
  health_check              = "on"
  health_check_domain       = var.public_domain
  health_check_connect_port = 22623
  healthy_threshold         = 8
  unhealthy_threshold       = 8
  health_check_timeout      = 8
  health_check_interval     = 5
  request_timeout           = 60
  idle_timeout              = 20
  server_group_id           = alicloud_slb_server_group.masters_int_22623.id

}

# resource "alicloud_slb_listener" "tcp_22" {
#   load_balancer_id = alicloud_slb.slb.id
#   backend_port     = 22
#   frontend_port    = 22
#   protocol         = "tcp"
#   bandwidth        = 100
#   sticky_session   = "off"
#   # sticky_session_type = "insert" // try server?
#   # cookie_timeout      = 86400
#   health_check              = "on"
#   health_check_domain       = var.public_domain
#   health_check_connect_port = 22
#   healthy_threshold         = 8
#   unhealthy_threshold       = 8
#   health_check_timeout      = 8
#   health_check_interval     = 5
#   request_timeout           = 60
#   idle_timeout              = 20
# }