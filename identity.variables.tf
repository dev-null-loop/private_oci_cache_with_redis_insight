variable "tenancy_ocid" {
  description = "Tenancy OCID."
  type        = string
}

variable "user_ocid" {
  description = "User OCID."
  type        = string
}

variable "fingerprint" {
  description = "API key fingerprint."
  type        = string
}

variable "private_key_path" {
  description = "Path to the OCI API private key."
  type        = string
}

variable "region" {
  description = "Target OCI region."
  type        = string
}

variable "compartment_ids" {
  description = "Map of friendly compartment names to compartment OCIDs."
  type        = map(string)
}
