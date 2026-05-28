[Connect to Oracle Cloud Infrastructure Cache with Redis using Redis Insight](https://docs.oracle.com/en/learn/oci-cache-redis/index.html)

## What this stack builds

- one or more VCNs
- public and private subnets
- internet, NAT, and service gateways
- security lists and NSGs
- an optional Redis Insight / admin VM
- one or more OCI Cache Redis clusters
- optional OCI Cache config sets
- optional OCI Cache users
- optional cluster/user attachments
- optional Redis identity tokens
- optional OCI Cache backups

## Style

This repo intentionally follows the guidance-repo root style:
- data-driven `map(object(...))` inputs
- pluralized module calls with `for_each`
- alias resolution in `locals.tf`
- grouped `*.auto.tfvars.example` files

## Files

- `provider.tf`: provider configuration
- `versions.tf`: Terraform and provider versions
- `variables.tf`: shared identity and lookup variables
- `core.variables.tf`: networking and instance schemas
- `redis.variables.tf`: OCI Cache schemas
- `locals.tf`: alias and ID resolution
- `core.tf`: core network and instance module calls
- `redis.tf`: OCI Cache module calls
- `outputs.tf`: aggregated outputs
- `userdata/redis-insight-cloud-config.yaml.tftpl`: optional Redis Insight bootstrap

## Prerequisites

- OCI API credentials
- valid compartment OCIDs
- valid image OCIDs in `source_ids`
- SSH access to GitHub if you want `terraform init` to fetch module sources over `git@github.com:...`

## Suggested first deployment

Start with:
- one VCN
- one public subnet for the Redis Insight VM
- one private subnet for OCI Cache
- one Redis cluster in `NONSHARDED` mode with 3 nodes
- one IAM Redis user
- one backup
