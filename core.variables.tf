variable "source_ids" {
  description = "Map of friendly image names to image OCIDs."
  type        = map(string)
  default     = {}
}

variable "vcns" {
  description = "VCN definitions."
  type = map(object({
    cidr_blocks      = list(string)
    display_name     = string
    dns_label        = string
    compartment_name = string
    is_ipv6enabled   = optional(bool, false)
  }))
  default = {}
}

variable "internet_gateways" {
  description = "Internet gateway definitions."
  type = map(object({
    display_name = optional(string, null)
    vcn_name     = string
  }))
  default = {}
}

variable "nat_gateways" {
  description = "NAT gateway definitions."
  type = map(object({
    display_name = string
    vcn_name     = string
  }))
  default = {}
}

variable "service_gateways" {
  description = "Service gateway definitions."
  type = map(object({
    display_name = string
    vcn_name     = string
    service_name = optional(string, "services")
  }))
  default = {}
}

variable "security_lists" {
  description = "Security list definitions."
  type = map(object({
    vcn_name     = string
    display_name = optional(string, null)
    egress_rules = list(object({
      description      = optional(string)
      stateless        = optional(bool, false)
      protocol         = string
      destination      = string
      destination_type = optional(string, "CIDR_BLOCK")
      tcp_options = optional(object({
        min = number
        max = number
      }))
      udp_options = optional(object({
        min = number
        max = number
      }))
      icmp_options = optional(object({
        type = number
        code = optional(number)
      }))
    }))
    ingress_rules = list(object({
      description = optional(string)
      stateless   = optional(bool, false)
      protocol    = string
      source      = string
      source_type = optional(string, "CIDR_BLOCK")
      tcp_options = optional(object({
        min = number
        max = number
      }))
      udp_options = optional(object({
        min = number
        max = number
      }))
      icmp_options = optional(object({
        type = number
        code = optional(number)
      }))
    }))
  }))
  default = {}
}

variable "route_tables" {
  description = "Route table definitions."
  type = map(object({
    vcn_name     = string
    display_name = string
    route_rules = list(object({
      description         = optional(string)
      network_entity_name = string
      destination         = string
      destination_type    = optional(string, "CIDR_BLOCK")
    }))
  }))
  default = {}
}

variable "subnets" {
  description = "Subnet definitions."
  type = map(object({
    compartment_name           = string
    display_name               = string
    cidr_block                 = string
    dns_label                  = string
    prohibit_internet_ingress  = optional(bool, false)
    prohibit_public_ip_on_vnic = bool
    security_list_names        = optional(list(string), [])
    route_table_name           = optional(string)
    vcn_name                   = string
  }))
  default = {}
}

variable "network_security_groups" {
  description = "Network security group definitions."
  type = map(object({
    compartment_name = string
    display_name     = optional(string, null)
    vcn_name         = string
  }))
  default = {}
}

variable "network_security_group_rules" {
  description = "Network security group rule definitions."
  type = map(object({
    network_security_group_name = string
    rules = object({
      direction        = string
      protocol         = string
      description      = optional(string)
      destination      = optional(string)
      destination_type = optional(string)
      source           = optional(string)
      source_type      = optional(string, "CIDR_BLOCK")
      stateless        = optional(bool, false)
      tcp_options = optional(object({
        destination_port_range = optional(object({
          min = number
          max = number
        }))
        source_port_range = optional(object({
          min = number
          max = number
        }))
      }))
      udp_options = optional(object({
        destination_port_range = optional(object({
          min = number
          max = number
        }))
        source_port_range = optional(object({
          min = number
          max = number
        }))
      }))
      icmp_options = optional(object({
        type = optional(string)
        code = optional(number)
      }))
    })
  }))
  default = {}
}

variable "instances" {
  description = "Compute instance definitions."
  type = map(object({
    availability_domain = number
    compartment_name    = string
    display_name        = optional(string, null)
    shape               = string
    shape_config = optional(object({
      baseline_ocpu_utilization = optional(string)
      memory_in_gbs             = optional(number)
      nvmes                     = optional(number)
      ocpus                     = optional(number)
      vcpus                     = optional(number)
    }), null)
    fault_domain  = optional(number, 1)
    state         = optional(string, "RUNNING")
    defined_tags  = optional(map(string), null)
    freeform_tags = optional(map(string), {})
    create_vnic_details = object({
      assign_public_ip       = optional(bool, false)
      defined_tags           = optional(map(string), null)
      display_name           = optional(string, null)
      freeform_tags          = optional(map(string), {})
      hostname_label         = optional(string, null)
      nsg_names              = optional(list(string), [])
      private_ip             = optional(string, null)
      security_attributes    = optional(map(string), null)
      skip_source_dest_check = optional(bool, false)
      subnet_name            = string
      subnet_id              = optional(string)
    })
    ssh_public_keys = optional(list(string), [])
    cloud_init = optional(list(object({
      filename     = optional(string)
      content      = optional(string)
      content_type = optional(string)
      vars         = optional(map(string), {})
    })), [])
    preserve_boot_volume = optional(bool, false)
    source_details = object({
      source_name             = string
      source_type             = optional(string, "image")
      boot_volume_size_in_gbs = optional(number, 50)
      boot_volume_vpus_per_gb = optional(number)
      kms_key_id              = optional(string)
    })
  }))
  default = {}
}
