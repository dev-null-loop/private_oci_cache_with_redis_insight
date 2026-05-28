data "oci_core_services" "these" {}

data "oci_identity_availability_domains" "this" {
  compartment_id = var.tenancy_ocid
}

locals {
  network_entity_ids = merge(
    { for k, v in module.ig : "ig_${k}" => v.id },
    { for k, v in module.ng : "ng_${k}" => v.id },
    { for k, v in module.sg : "sg_${k}" => v.id }
  )

  services = {
    for svc in data.oci_core_services.these.services :
    (startswith(lower(svc.cidr_block), "all-") ? "services" : "objectstorage") => {
      cidr_block = svc.cidr_block
      id         = svc.id
    }
  }

  availability_domains = {
    for idx, ad in data.oci_identity_availability_domains.this.availability_domains : idx + 1 => ad.name
  }

  security_lists = {
    for sl_name, sl in var.security_lists : sl_name => merge(sl, {
      egress_rules = [
	for rule in sl.egress_rules : merge(rule, {
	  destination = try(local.services[rule.destination].cidr_block, rule.destination)
	})
      ]
    })
  }

  route_tables = {
    for rt_name, rt in var.route_tables : rt_name => merge(rt, {
      route_rules = [
	for rr in rt.route_rules : {
	  description       = rr.description
	  destination       = try(local.services[rr.destination].cidr_block, rr.destination)
	  destination_type  = rr.destination_type
	  network_entity_id = local.network_entity_ids[rr.network_entity_name]
	}
      ]
    })
  }

  instances = {
    for name, inst in var.instances : name => merge(inst, {
      availability_domain = local.availability_domains[inst.availability_domain]
      create_vnic_details = merge(inst.create_vnic_details, {
	subnet_id = module.sn[inst.create_vnic_details.subnet_name].id
	nsg_ids   = [for nsg_name in inst.create_vnic_details.nsg_names : module.nsg[nsg_name].id]
      })
      source_details = merge(inst.source_details, {
	source_id = var.source_ids[inst.source_details.source_name]
      })
    })
  }

  redis_clusters = {
    for name, cluster in var.redis_clusters : name => merge(cluster, {
      subnet_id               = module.sn[cluster.subnet_name].id
      nsg_ids                 = [for nsg_name in cluster.nsg_names : module.nsg[nsg_name].id]
      oci_cache_config_set_id = try(module.redis_config_sets[cluster.config_set_name].id, null)
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
