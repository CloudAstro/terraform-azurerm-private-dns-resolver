<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
# Azure Private DNS Resolver Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md)
[![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/cloudastro/private-dns-resolver/azurerm/)

This Terraform module provisions and manages **Azure Private DNS Resolver** resources. It supports configuration of the DNS Resolver itself, as well as associated inbound/outbound endpoints, virtual network links, forwarding rules, and DNS forwarding rulesets. The module is designed for flexible integration with custom Azure network topologies.

## Features

- **Private DNS Resolver**: Deploys a Private DNS Resolver instance in a specified region and resource group.
- **Inbound Endpoints**: Configure endpoints to receive DNS queries from on-premises networks or other sources.
- **Outbound Endpoints**: Manage endpoints to forward DNS queries to upstream DNS servers.
- **Forwarding Rules**: Define custom DNS forwarding rules to route requests based on domain patterns.
- **DNS Forwarding Ruleset**: Manage forwarding rulesets for logical grouping and reuse across endpoints.
- **Virtual Network Link**: Link virtual networks to the DNS Resolver for internal name resolution.

## Example Usage

This example demonstrates how to deploy a full Azure Private DNS Resolver setup, including endpoints, forwarding rules, and VNet links:

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "rg-pdnsr-example"
  location = "germanywestcentral"
}

module "vnet_1" {
  source              = "CloudAstro/virtual-network/azurerm"
  name                = "vnet-pdnsr-example-1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "snet_1" {
  source               = "CloudAstro/subnet/azurerm"
  name                 = "snet-pdnsr-example-1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = module.vnet_1.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation = [
    {
      name = "dnsDelegation"
      service_delegation = {
        name = "Microsoft.Network/dnsResolvers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
  }]
}

# This second virtual network is created solely to demonstrate how `virtual_network_links` work
# in the Private DNS Resolver module. It is linked from the forwarding ruleset as "link-to-vnet2".
module "vnet_2" {
  source              = "CloudAstro/virtual-network/azurerm"
  name                = "vnet-pdnsr-example-2"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "snet_2" {
  source               = "CloudAstro/subnet/azurerm"
  name                 = "snet-example-2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = module.vnet_1.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation = [
    {
      name = "dnsDelegation"
      service_delegation = {
        name = "Microsoft.Network/dnsResolvers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
  }]
}

module "private_dns_resolver" {
  source              = "../.."
  name                = "pdnsr-example"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_network_id  = module.vnet_1.virtual_network.id

  inbound_endpoint = {
    endpoint1 = {
      name     = "inbound1"
      location = azurerm_resource_group.rg.location
      ip_configurations = [
        {
          subnet_id                    = module.snet_2.subnet.id
          private_ip_address           = "10.0.2.4"
          private_ip_allocation_method = "Static"
        }
      ]
    }
  }

  outbound_endpoint = {
    "outbound1" = {
      name      = "outbound-endpoint"
      subnet_id = module.snet_1.subnet.id

      forwarding_ruleset = {
        ruleset-1 = {
          name = "example-ruleset"
          virtual_network_link = {
            "link1" = {
              name               = "link-to-vnet2"
              virtual_network_id = module.vnet_2.virtual_network.id
              metadata = {
                link_owner = "infra-team"
              }
            }
          }

          rule = {
            "google-forward" = {
              name        = "forward-google"
              domain_name = "google.com."
              enabled     = true
              metadata = {
                team = "dns"
              }
              target_dns_servers = [{
                ip_address = "8.8.8.8"
                port       = 53
                }, {
                ip_address = "8.8.4.4"
                port       = 53
              }]
            }
            internal-forward = {
              name        = "internal-forward"
              domain_name = "example.com."
              enabled     = true
              metadata = {
                team = "dns"
              }
              target_dns_servers = [{
                ip_address = "10.0.0.1"
                port       = 53
                }, {
                ip_address = "10.0.0.2"
                port       = 5353
              }]
            }
          }
        }
      }
    }
  }
}
```
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_resolver.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) | resource |
| [azurerm_private_dns_resolver_dns_forwarding_ruleset.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_dns_forwarding_ruleset) | resource |
| [azurerm_private_dns_resolver_forwarding_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_forwarding_rule) | resource |
| [azurerm_private_dns_resolver_inbound_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_inbound_endpoint) | resource |
| [azurerm_private_dns_resolver_outbound_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_outbound_endpoint) | resource |
| [azurerm_private_dns_resolver_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_virtual_network_link) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | * `location` - (Required) Specifies the Azure Region where the Private DNS Resolver will be deployed. Changing this forces a new Private DNS Resolver to be created.<br/><br/>  Example Input:<pre>location = "East US"</pre> | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | * `name` - (Required) Specifies the name of the Private DNS Resolver. Changing this forces a new Private DNS Resolver to be created.<br/><br/>  Example Input:<pre>name = "pdnsr-prod"</pre> | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | * `resource_group_name` - (Required) Specifies the name of the Resource Group where the Private DNS Resolver should exist. Changing this forces a new Private DNS Resolver to be created.<br/><br/>  Example Input:<pre>resource_group_name = "rg-pdnsr-prod"</pre> | `string` | n/a | yes |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | * `virtual_network_id` - (Required) The ID of the Virtual Network that is linked to the Private DNS Resolver. Changing this forces a new Private DNS Resolver to be created.<br/><br/>  Example Input:<pre>virtual_network_id = "/subscriptions/12345678-abcd-efgh-ijkl-9876543210aa/resourceGroups/prod-rg/providers/Microsoft.Network/virtualNetworks/prod-vnet"</pre> | `string` | n/a | yes |
| <a name="input_inbound_endpoint"></a> [inbound\_endpoint](#input\_inbound\_endpoint) | * `inbound_endpoint` - Gets information about an existing Private DNS Resolver Inbound Endpoint.<br/>    * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Inbound Endpoint. Changing this forces a new Private DNS Resolver Inbound Endpoint to be created.<br/>    * `private_dns_resolver_id` - (Required) Specifies the ID of the Private DNS Resolver Inbound Endpoint. Changing this forces a new Private DNS Resolver Inbound Endpoint to be created.<br/>    * `ip_configurations` - (Required) One `ip_configurations` block as defined below. Changing this forces a new Private DNS Resolver Inbound Endpoint to be created.<br/>    * `subnet_id` - (Required) The subnet ID of the IP configuration.<br/>    * `private_ip_address` - (Optional) Private IP address of the IP configuration.<br/>    * `private_ip_allocation_method` - (Optional) Private IP address allocation method. Allowed value is `Dynamic` and `Static`. Defaults to `Dynamic`.<br/>    * `location` - (Required) Specifies the Azure Region where the Private DNS Resolver Inbound Endpoint should exist. Changing this forces a new Private DNS Resolver Inbound Endpoint to be created.<br/>    * `tags` - (Optional) A mapping of tags which should be assigned to the Private DNS Resolver Inbound Endpoint.<br/><br/>  Example Input:<pre>inbound_endpoint = {<br/>    name                     = "in-endpoint-prd"<br/>    location                 = "East US"<br/>    private_dns_resolver_id  = "/subscriptions/12345678-abcd-efgh-ijkl-9876543210aa/resourceGroups/prod-rg/providers/Microsoft.Network/privateDnsResolver/prod-pdnsr"<br/>    ip_configuration = {<br/>      subnet_id                  = "/subscriptions/12345678-abcd-efgh-ijkl-9876543210aa/resourceGroups/prod-rg/providers/Microsoft.Network/virtualNetworks/prod-vnet/subnets/prod-subnet"<br/>      private_ip_address         = "10.1.0.5"<br/>      private_ip_allocation_method = "Static"<br/>      }<br/>    }</pre> | <pre>map(object({<br/>    name     = string<br/>    location = string<br/>    ip_configurations = list(object({<br/>      subnet_id                    = string<br/>      private_ip_address           = optional(string)<br/>      private_ip_allocation_method = optional(string)<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_outbound_endpoint"></a> [outbound\_endpoint](#input\_outbound\_endpoint) | * `outbound_endpoint` - Manages a Private DNS Resolver Outbound Endpoint.<br/>    * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Outbound Endpoint. Changing this forces a new Private DNS Resolver Outbound Endpoint to be created.<br/>    * `private_dns_resolver_id` - (Required) Specifies the ID of the Private DNS Resolver Outbound Endpoint. Changing this forces a new Private DNS Resolver Outbound Endpoint to be created.<br/>    * `subnet_id` - (Required) The ID of the Subnet that is linked to the Private DNS Resolver Outbound Endpoint. Changing this forces a new resource to be created.<br/>    * `dns_forwarding_ruleset` - Manages a Private DNS Resolver Dns Forwarding Ruleset.<br/>      * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Dns Forwarding Ruleset. Changing this forces a new Private DNS Resolver Dns Forwarding Ruleset to be created.<br/>      * `private_dns_resolver_outbound_endpoint_ids` - (Required) The list of IDs of the Private DNS Resolver Outbound Endpoint that is linked to the Private DNS Resolver Dns Forwarding Ruleset.<br/>    * `forwaring_rule` - Manages a Private DNS Resolver Forwarding Rule.<br/>      * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Forwarding Rule. Changing this forces a new Private DNS Resolver Forwarding Rule to be created.<br/>      * `dns_forwarding_ruleset_id` - (Required) Specifies the ID of the Private DNS Resolver Forwarding Ruleset. Changing this forces a new Private DNS Resolver Forwarding Rule to be created.<br/>      * `domain_name` - (Required) Specifies the domain name for the Private DNS Resolver Forwarding Rule. Changing this forces a new Private DNS Resolver Forwarding Rule to be created.<br/>      * `target_dns_servers` - (Required) Can be specified multiple times to define multiple target DNS servers. Each `target_dns_servers` block as defined below.<br/>        * `ip_address` - (Required) DNS server IP address.<br/>        * `port` - (Optional) DNS server port.<br/>      * `enabled` - (Optional) Specifies the state of the Private DNS Resolver Forwarding Rule. Defaults to `true`.<br/>      * `metadata` - (Optional) Metadata attached to the Private DNS Resolver Forwarding Rule.<br/>    * `virtual_network_link` - Manages a Private DNS Resolver Virtual Network Link.<br/>      * `name` - (Required) Specifies the name which should be used for this Private DNS Resolver Virtual Network Link. Changing this forces a new Private DNS Resolver Virtual Network Link to be created.<br/>      * `dns_forwarding_ruleset_id` - (Required) Specifies the ID of the Private DNS Resolver DNS Forwarding Ruleset. Changing this forces a new Private DNS Resolver Virtual Network Link to be created.<br/>      * `virtual_network_id` - (Required) The ID of the Virtual Network that is linked to the Private DNS Resolver Virtual Network Link. Changing this forces a new resource to be created.<br/>      * `metadata` - (Optional) Metadata attached to the Private DNS Resolver Virtual Network Link.<br/><br/>  Example Input:<pre>outbound_endpoints = {<br/>    "outbound1" = {<br/>      name      = "outbound-endpoint"<br/>      subnet_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"<br/><br/>      forwarding_ruleset = {<br/>        "example-ruleset" = {<br/>          name = "example-ruleset"<br/><br/>          virtual_network_links = {<br/>            "link1" = {<br/>              name     = "example-vnet-link"<br/>              vnet_id  = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Network/virtualNetworks/vnet"<br/>              metadata = {<br/>                link_owner = "infra-team"<br/>              }<br/>            }<br/>          }<br/><br/>          rules = {<br/>            "google-forward" = {<br/>              name        = "forward-google"<br/>              domain_name = "google.com."<br/>              enabled     = true<br/>              metadata = {<br/>                team = "dns"<br/>              }<br/>              destination_ip_addresses = {<br/>                "8.8.8.8" = 53<br/>                "8.8.4.4" = 53<br/>              }<br/>            }<br/>          }<br/>        }<br/>      }<br/>    }<br/>  }</pre> | <pre>map(object({<br/>    name      = string<br/>    subnet_id = string<br/>    forwarding_ruleset = optional(map(object({<br/>      name = optional(string)<br/>      virtual_network_link = optional(map(object({<br/>        name               = string<br/>        virtual_network_id = string<br/>        metadata           = optional(map(string))<br/>      })))<br/>      rule = optional(map(object({<br/>        name        = string<br/>        domain_name = string<br/>        enabled     = optional(bool)<br/>        metadata    = optional(map(string))<br/>        target_dns_servers = list(object({<br/>          ip_address = string<br/>          port       = optional(number)<br/>        }))<br/>      })))<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | * `tags` - (Optional) A map of tags to associate with the network and subnets.<br/><br/>  Example Input:<pre>tags = {<br/>    "environment" = "production"<br/>    "department"  = "IT"<br/>  }</pre> | `map(string)` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:<br/>    * `create` - (Defaults to 30 minutes) Used when creating the Container App.<br/>    * `delete` - (Defaults to 30 minutes) Used when deleting the Container App.<br/>    * `read` - (Defaults to 5 minutes) Used when retrieving the Container App.<br/>    * `update` - (Defaults to 30 minutes) Used when updating the Container App.<br/><br/>  Example Input:<pre>container_app_timeouts = {<br/>    create = "45m"<br/>    delete = "30m"<br/>    read   = "10m"<br/>    update = "40m"<br/>  }</pre> | <pre>object({<br/>    create = optional(string, "90")<br/>    read   = optional(string, "5")<br/>    update = optional(string, "60")<br/>    delete = optional(string, "60")<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_resolver"></a> [dns\_resolver](#output\_dns\_resolver) | Outputs details for the Azure Private DNS Resolver.<br/>  * `name` - The name of the DNS Resolver.<br/>  * `resource_group_name` - The name of the resource group where the DNS Resolver is deployed.<br/>  * `location` - The Azure region where the DNS Resolver is created.<br/>  * `id` - The resource ID of the DNS Resolver.<br/>  * `tags` - A mapping of tags assigned to the DNS Resolver.<br/><br/>  Example output:<pre>output "dns_resolver_name" {<br/>    value = module.module_name.dns_resolver.name<br/>  }</pre> |

## Modules

No modules.

## 🌐 Additional Information  

For comprehensive guidance on Azure Private DNS and configuration scenarios, refer to the [Azure Private DNS documentation](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview/).  
This module allows you to manage private DNS zones and dynamically link them to one or more virtual networks for name resolution within your Azure environment.

## 📚 Resources  

- [Terraform AzureRM Provider – `azurerm_private_dns_zone`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)  
- [Azure Private DNS Overview](https://learn.microsoft.com/en-us/azure/dns/private-dns-overview)  
- [Azure DNS Concepts](https://learn.microsoft.com/en-us/azure/dns/dns-overview)

## ⚠️ Notes  

- A single Private DNS zone can be linked to multiple VNets across different regions.
- DNS resolution and billing are impacted by the number of zones, query volume, and linked virtual networks.
- Always validate and review your Terraform plans to ensure accurate creation and association of DNS resources.

## 🧾 License  

This module is licensed under the **MIT License**. See the [LICENSE](./LICENSE) file for more details.
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->