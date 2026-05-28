module "redis_config_sets" {
  source                = "git@github.com:dev-null-loop/oci_redis//oci_cache_config_set"
  for_each              = var.redis_config_sets
  compartment_id        = var.compartment_ids[each.value.compartment_name]
  display_name          = each.value.display_name
  description           = each.value.description
  software_version      = each.value.software_version
  configuration_details = each.value.configuration_details
}

module "redis_clusters" {
  source                             = "git@github.com:dev-null-loop/oci_redis//redis_cluster"
  for_each                           = local.redis_clusters
  compartment_id                     = var.compartment_ids[each.value.compartment_name]
  display_name                       = each.value.display_name
  cluster_mode                       = each.value.cluster_mode
  node_count                         = each.value.node_count
  node_memory_in_gbs                 = each.value.node_memory_in_gbs
  software_version                   = each.value.software_version
  subnet_id                          = each.value.subnet_id
  nsg_ids                            = each.value.nsg_ids
  shard_count                        = each.value.shard_count
  oci_cache_config_set_id            = each.value.oci_cache_config_set_id
  backup_id                          = each.value.backup_id
  security_attributes                = each.value.security_attributes
  import_from_object_storage_details = each.value.import_from_object_storage_details
}

module "redis_users" {
  source              = "git@github.com:dev-null-loop/oci_redis//oci_cache_user"
  for_each            = var.redis_users
  compartment_id      = var.compartment_ids[each.value.compartment_name]
  acl_string          = each.value.acl_string
  authentication_mode = each.value.authentication_mode
  description         = each.value.description
  name                = each.value.name
  status              = each.value.status
}

module "redis_cluster_user_attachments" {
  source           = "git@github.com:dev-null-loop/oci_redis//redis_cluster_attach_oci_cache_user"
  for_each         = local.redis_cluster_user_attachments
  redis_cluster_id = each.value.redis_cluster_id
  oci_cache_users  = each.value.oci_cache_users
}

module "redis_identity_tokens" {
  source           = "git@github.com:dev-null-loop/oci_redis//redis_cluster_create_identity_token"
  for_each         = local.redis_identity_tokens
  redis_cluster_id = each.value.redis_cluster_id
  redis_user       = each.value.redis_user
  public_key       = each.value.public_key
}

module "redis_backups" {
  source                           = "git@github.com:dev-null-loop/oci_redis//oci_cache_backup"
  for_each                         = local.redis_backups
  compartment_id                   = var.compartment_ids[each.value.compartment_name]
  display_name                     = each.value.display_name
  source_cluster_id                = each.value.source_cluster_id
  backup_source                    = each.value.backup_source
  description                      = each.value.description
  retention_period_in_days         = each.value.retention_period_in_days
  export_to_object_storage_trigger = each.value.export_to_object_storage_trigger
}
