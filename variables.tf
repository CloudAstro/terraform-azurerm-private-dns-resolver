variable "name" {
  type        = string
  description = <<DESCRIPTION
  * `name` - (Required) Specifies the name of the Private DNS Resolver. Changing this forces a new Private DNS Resolver to be created.

  Example Input:
  ```
  name = "pdnsr-prod"
  ```
  DESCRIPTION
}

variable "resource_group_name" {
  type        = string
  description = <<DESCRIPTION
  * `resource_group_name` - (Required) Specifies the name of the Resource Group where the Private DNS Resolver should exist. Changing this forces a new Private DNS Resolver to be created.

  Example Input:
  ```
  resource_group_name = "rg-pdnsr-prod"
  ```
  DESCRIPTION
}

variable "location" {
  type        = string
  description = <<DESCRIPTION
  * `location` - (Required) Specifies the Azure Region where the Private DNS Resolver will be deployed. Changing this forces a new Private DNS Resolver to be created.

  Example Input:
  ```
  location = "East US"
  ```
  DESCRIPTION
}

variable "virtual_network_id" {
  type        = string
  description = <<DESCRIPTION
  * `virtual_network_id` - (Required) The ID of the Virtual Network that is linked to the Private DNS Resolver. Changing this forces a new Private DNS Resolver to be created.

  Example Input:
  ```
  virtual_network_id = "/subscriptions/12345678-abcd-efgh-ijkl-9876543210aa/resourceGroups/prod-rg/providers/Microsoft.Network/virtualNetworks/prod-vnet"
  ```
  DESCRIPTION
}

variable "inbound_endpoint" {
  type = map(object({
    name     = string
    location = string
    ip_configurations = list(object({
      subnet_id                    = string
      private_ip_address           = optional(string)
      private_ip_allocation_method = optional(string)
    }))
  }))
  default     = null
  description = <<DESCRIPTION
  * `inbound_endpoint` - Gets information about an existing Private DNS Resolver Inbound Endpoint.
    * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Inbound Endpoint. Changing this forces a new Private DNS Resolver Inbound Endpoint to be created.
    * `private_dns_resolver_id` - (Required) Specifies the ID of the Private DNS Resolver Inbound Endpoint. Changing this forces a new Private DNS Resolver Inbound Endpoint to be created.
    * `ip_configurations` - (Required) One `ip_configurations` block as defined below. Changing this forces a new Private DNS Resolver Inbound Endpoint to be created.
    * `subnet_id` - (Required) The subnet ID of the IP configuration.
    * `private_ip_address` - (Optional) Private IP address of the IP configuration.
    * `private_ip_allocation_method` - (Optional) Private IP address allocation method. Allowed value is `Dynamic` and `Static`. Defaults to `Dynamic`.
    * `location` - (Required) Specifies the Azure Region where the Private DNS Resolver Inbound Endpoint should exist. Changing this forces a new Private DNS Resolver Inbound Endpoint to be created.
    * `tags` - (Optional) A mapping of tags which should be assigned to the Private DNS Resolver Inbound Endpoint.

  Example Input:
  ```
  inbound_endpoint = {
    name                     = "in-endpoint-prd"
    location                 = "East US"
    private_dns_resolver_id  = "/subscriptions/12345678-abcd-efgh-ijkl-9876543210aa/resourceGroups/prod-rg/providers/Microsoft.Network/privateDnsResolver/prod-pdnsr"
    ip_configuration = {
      subnet_id                  = "/subscriptions/12345678-abcd-efgh-ijkl-9876543210aa/resourceGroups/prod-rg/providers/Microsoft.Network/virtualNetworks/prod-vnet/subnets/prod-subnet"
      private_ip_address         = "10.1.0.5"
      private_ip_allocation_method = "Static"
      }
    }
  ```
  DESCRIPTION
}

variable "outbound_endpoint" {
  type = map(object({
    name      = string
    subnet_id = string
    forwarding_ruleset = optional(map(object({
      name = optional(string)
      virtual_network_link = optional(map(object({
        name               = string
        virtual_network_id = string
        metadata           = optional(map(string))
      })))
      rule = optional(map(object({
        name        = string
        domain_name = string
        enabled     = optional(bool)
        metadata    = optional(map(string))
        target_dns_servers = list(object({
          ip_address = string
          port       = optional(number)
        }))
      })))
    })))
  }))
  default     = null
  description = <<DESCRIPTION
  * `outbound_endpoint` - Manages a Private DNS Resolver Outbound Endpoint.
    * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Outbound Endpoint. Changing this forces a new Private DNS Resolver Outbound Endpoint to be created.
    * `private_dns_resolver_id` - (Required) Specifies the ID of the Private DNS Resolver Outbound Endpoint. Changing this forces a new Private DNS Resolver Outbound Endpoint to be created.
    * `subnet_id` - (Required) The ID of the Subnet that is linked to the Private DNS Resolver Outbound Endpoint. Changing this forces a new resource to be created.
    * `dns_forwarding_ruleset` - Manages a Private DNS Resolver Dns Forwarding Ruleset.
      * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Dns Forwarding Ruleset. Changing this forces a new Private DNS Resolver Dns Forwarding Ruleset to be created.
      * `private_dns_resolver_outbound_endpoint_ids` - (Required) The list of IDs of the Private DNS Resolver Outbound Endpoint that is linked to the Private DNS Resolver Dns Forwarding Ruleset.
    * `forwaring_rule` - Manages a Private DNS Resolver Forwarding Rule.
      * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Forwarding Rule. Changing this forces a new Private DNS Resolver Forwarding Rule to be created.
      * `dns_forwarding_ruleset_id` - (Required) Specifies the ID of the Private DNS Resolver Forwarding Ruleset. Changing this forces a new Private DNS Resolver Forwarding Rule to be created.
      * `domain_name` - (Required) Specifies the domain name for the Private DNS Resolver Forwarding Rule. Changing this forces a new Private DNS Resolver Forwarding Rule to be created.
      * `target_dns_servers` - (Required) Can be specified multiple times to define multiple target DNS servers. Each `target_dns_servers` block as defined below.
        * `ip_address` - (Required) DNS server IP address.
        * `port` - (Optional) DNS server port.
      * `enabled` - (Optional) Specifies the state of the Private DNS Resolver Forwarding Rule. Defaults to `true`.
      * `metadata` - (Optional) Metadata attached to the Private DNS Resolver Forwarding Rule.
    * `virtual_network_link` - Manages a Private DNS Resolver Virtual Network Link.
      * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Virtual Network Link. Changing this forces a new Private DNS Resolver Virtual Network Link to be created.
      * `dns_forwarding_ruleset_id` - (Required) Specifies the ID of the Private DNS Resolver DNS Forwarding Ruleset. Changing this forces a new Private DNS Resolver Virtual Network Link to be created.
      * `virtual_network_id` - (Required) The ID of the Virtual Network that is linked to the Private DNS Resolver Virtual Network Link. Changing this forces a new resource to be created.
      * `metadata` - (Optional) Metadata attached to the Private DNS Resolver Virtual Network Link.

  Example Input:
  ```
  outbound_endpoints = {
    "outbound1" = {
      name      = "outbound-endpoint"
      subnet_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"

      forwarding_ruleset = {
        "example-ruleset" = {
          name = "example-ruleset"

          virtual_network_links = {
            "link1" = {
              name     = "example-vnet-link"
              vnet_id  = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/vnet"
              metadata = {
                link_owner = "infra-team"
              }
            }
          }

          rules = {
            "google-forward" = {
              name        = "forward-google"
              domain_name = "google.com."
              enabled     = true
              metadata = {
                team = "dns"
              }
              destination_ip_addresses = {
                "8.8.8.8" = 53
                "8.8.4.4" = 53
              }
            }
          }
        }
      }
    }
  }
  ```
  DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string, "90")
    read   = optional(string, "5")
    update = optional(string, "60")
    delete = optional(string, "60")
  })
  default     = null
  description = <<DESCRIPTION
  * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:
    * `create` - (Defaults to 30 minutes) Used when creating the Container App.
    * `delete` - (Defaults to 30 minutes) Used when deleting the Container App.
    * `read` - (Defaults to 5 minutes) Used when retrieving the Container App.
    * `update` - (Defaults to 30 minutes) Used when updating the Container App.

  Example Input:
  ```
  container_app_timeouts = {
    create = "45m"
    delete = "30m"
    read   = "10m"
    update = "40m"
  }
  ```
  DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
  * `tags` - (Optional) A map of tags to associate with the network and subnets.

  Example Input:
  ```
  tags = {
    "environment" = "production"
    "department"  = "IT"
  }
  ```
  DESCRIPTION
}
