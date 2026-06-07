output "vcns" {
  description = "Created VCNs."
  value = {
    for k, v in module.vcns : k => {
      id           = v.id
      display_name = v.display_name
      cidr_blocks  = v.cidr_blocks
      subnets = [
        for sn_name, sn in module.subnets : {
          name       = sn_name
          cidr_block = sn.cidr_block
          id         = sn.id
        } if sn.vcn_id == v.id
      ]
    }
  }
}

output "instances" {
  description = "Created instances."
  value = {
    for k, v in module.instances : k => {
      id         = v.id
      public_ip  = v.public_ip == "" ? null : v.public_ip
      private_ip = v.private_ip
    }
  }
}

output "redis_clusters" {
  description = "Created Redis clusters."
  value = {
    for k, v in module.redis_clusters : k => {
      id                          = v.id
      state                       = v.state
      cluster_mode                = v.cluster_mode
      primary_fqdn                = v.primary_fqdn
      primary_endpoint_ip_address = v.primary_endpoint_ip_address
      discovery_fqdn              = v.discovery_fqdn
      replicas_fqdn               = v.replicas_fqdn
      subnet_id                   = v.subnet_id
      nsg_ids                     = v.nsg_ids
    }
  }
}

output "redis_users" {
  description = "Created Redis users."
  value = {
    for k, v in module.redis_users : k => {
      id     = v.id
      name   = v.name
      status = v.status
      state  = v.state
    }
  }
}

output "redis_backups" {
  description = "Created Redis backups."
  value = {
    for k, v in module.redis_backups : k => {
      id                = v.id
      state             = v.state
      source_cluster_id = v.source_cluster_id
      backup_source     = v.backup_source
    }
  }
}

output "redis_identity_tokens" {
  description = "Generated Redis identity tokens."
  value = {
    for k, v in module.redis_identity_tokens : k => {
      id         = v.id
      redis_user = v.redis_user
      token      = v.identity_token
    }
  }
  sensitive = true
}
