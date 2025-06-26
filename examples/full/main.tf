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
