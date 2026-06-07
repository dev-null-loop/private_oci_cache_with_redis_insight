data "oci_core_services" "these" {}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

locals {
  network_entity_ids = merge(
    { for k, v in module.internet_gateways : "ig_${k}" => v.id },
    { for k, v in module.nat_gateways : "ng_${k}" => v.id },
    { for k, v in module.service_gateways : "sg_${k}" => v.id }
  )

  services = {
    for svc in data.oci_core_services.these.services :
    (startswith(lower(svc.cidr_block), "all-") ? "services" : "objectstorage") => {
      cidr_block = svc.cidr_block
      id         = svc.id
    }
  }

  availability_domains = {
    for idx, ad in data.oci_identity_availability_domains.ads.availability_domains : idx + 1 => ad.name
  }

  security_lists = {
    for k, v in var.security_lists : k => merge(v, {
      egress_rules = [for rule in v.egress_rules : merge(rule, {
        destination = try(local.services[rule.destination].cidr_block, rule.destination)
      })]
    })
  }

  route_tables = {
    for k, v in var.route_tables : k => merge(v, {
      route_rules = [
        for rr in v.route_rules : {
          description       = rr.description
          destination       = try(local.services[rr.destination].cidr_block, rr.destination)
          destination_type  = rr.destination_type
          network_entity_id = local.network_entity_ids[rr.network_entity_name]
        }
      ]
    })
  }

  instances = {
    for k, v in var.instances : k => merge(v, {
      availability_domain = local.availability_domains[v.availability_domain]
      create_vnic_details = merge(v.create_vnic_details, {
        subnet_id = try(module.subnets[v.create_vnic_details.subnet_name].id, v.create_vnic_details.subnet_id)
        nsg_ids   = [for nsg_name in v.create_vnic_details.nsg_names : module.network_security_groups[nsg_name].id]
      })
      source_details = merge(v.source_details, {
        source_id = var.source_ids[v.source_details.source_name]
      })
      ssh_public_keys = join("\n", v.ssh_public_keys)
    })
  }

  redis_clusters = {
    for k, v in var.redis_clusters : k => merge(v, {
      subnet_id               = module.subnets[v.subnet_name].id
      nsg_ids                 = [for nsg_name in v.nsg_names : module.network_security_groups[nsg_name].id]
      oci_cache_config_set_id = try(module.redis_config_sets[v.config_set_name].id, null)
    })
  }

  redis_cluster_user_attachments = {
    for name, attachment in var.redis_cluster_user_attachments : name => {
      redis_cluster_id = module.redis_clusters[attachment.redis_cluster_name].id
      oci_cache_users  = [for user_name in attachment.redis_user_names : module.redis_users[user_name].id]
    }
  }

  redis_identity_tokens = {
    for name, token in var.redis_identity_tokens : name => merge(token, {
      redis_cluster_id = module.redis_clusters[token.redis_cluster_name].id
    })
  }

  redis_backups = {
    for name, backup in var.redis_backups : name => merge(backup, {
      source_cluster_id = module.redis_clusters[backup.source_cluster_name].id
    })
  }
}
