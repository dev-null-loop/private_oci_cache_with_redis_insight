variable "redis_config_sets" {
  description = "OCI Cache config set definitions."
  type = map(object({
    compartment_name = string
    display_name     = string
    description      = optional(string)
    software_version = string
    configuration_details = object({
      items = list(object({
        config_key   = string
        config_value = string
      }))
    })
    defined_tags  = optional(map(string), null)
    freeform_tags = optional(map(string), {})
  }))
  default = {}
}

variable "redis_clusters" {
  description = "OCI Cache Redis cluster definitions."
  type = map(object({
    compartment_name    = string
    display_name        = string
    cluster_mode        = optional(string, "NONSHARDED")
    node_count          = number
    node_memory_in_gbs  = number
    software_version    = string
    subnet_name         = string
    nsg_names           = optional(list(string), [])
    shard_count         = optional(number)
    config_set_name     = optional(string)
    backup_id           = optional(string)
    security_attributes = optional(map(string), null)
    defined_tags        = optional(map(string), null)
    freeform_tags       = optional(map(string), {})
    import_from_object_storage_details = optional(object({
      bucket    = string
      namespace = string
      objects = list(object({
        object = string
      }))
    }), null)
  }))
  default = {}
}

variable "redis_users" {
  description = "OCI Cache user definitions."
  type = map(object({
    compartment_name = string
    name             = string
    description      = string
    acl_string       = string
    status           = optional(string, "ON")
    authentication_mode = object({
      authentication_type = string
      hashed_passwords    = optional(list(string), [])
    })
    defined_tags  = optional(map(string), null)
    freeform_tags = optional(map(string), {})
  }))
  default = {}
}

variable "redis_cluster_user_attachments" {
  description = "Mappings of Redis users to clusters."
  type = map(object({
    redis_cluster_name = string
    redis_user_names   = list(string)
  }))
  default = {}
}

variable "redis_identity_tokens" {
  description = "Redis identity token requests."
  type = map(object({
    redis_cluster_name = string
    redis_user         = string
    public_key         = string
    defined_tags       = optional(map(string), null)
    freeform_tags      = optional(map(string), {})
  }))
  default = {}
}

variable "redis_backups" {
  description = "OCI Cache backup definitions."
  type = map(object({
    compartment_name                 = string
    display_name                     = string
    source_cluster_name              = string
    backup_source                    = optional(string)
    description                      = optional(string)
    retention_period_in_days         = optional(number)
    export_to_object_storage_trigger = optional(number)
    defined_tags                     = optional(map(string), null)
    freeform_tags                    = optional(map(string), {})
  }))
  default = {}
}
