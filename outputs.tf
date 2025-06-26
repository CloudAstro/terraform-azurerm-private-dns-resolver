output "dns_resolver" {
  value       = azurerm_private_dns_resolver.this
  description = <<DESCRIPTION
  Outputs details for the Azure Private DNS Resolver.
  * `name` - The name of the DNS Resolver.
  * `resource_group_name` - The name of the resource group where the DNS Resolver is deployed.
  * `location` - The Azure region where the DNS Resolver is created.
  * `id` - The resource ID of the DNS Resolver.
  * `tags` - A mapping of tags assigned to the DNS Resolver.

  Example output:
  ```
  output "dns_resolver_name" {
    value = module.module_name.dns_resolver.name
  }
  ```
  DESCRIPTION
}
