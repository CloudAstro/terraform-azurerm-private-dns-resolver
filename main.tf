resource "azurerm_private_dns_resolver" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.virtual_network_id
  tags                = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  for_each = var.inbound_endpoint != null ? var.inbound_endpoint : {}

  name                    = each.value.name
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = each.value.location
  tags                    = var.tags

  dynamic "ip_configurations" {
    for_each = each.value.ip_configurations

    content {
      subnet_id                    = ip_configurations.value.subnet_id
      private_ip_address           = ip_configurations.value.private_ip_address
      private_ip_allocation_method = ip_configurations.value.private_ip_allocation_method
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "this" {
  for_each = var.outbound_endpoint != null ? var.outbound_endpoint : {}

  name                    = each.value.name
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  subnet_id               = each.value.subnet_id
  tags                    = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}


resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "this" {
  for_each = local.forwarding_ruleset != null ? local.forwarding_ruleset : {}

  name                                       = each.value.name
  location                                   = var.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.this[each.value.parent_key].id]
  resource_group_name                        = var.resource_group_name
  tags                                       = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_private_dns_resolver_forwarding_rule" "this" {
  for_each = local.forwarding_rule != null ? local.forwarding_rule : {}

  domain_name               = each.value.domain_name
  name                      = each.value.rule_name
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this[each.value.parent_key].id
  enabled                   = each.value.enabled
  metadata                  = each.value.metadata

  dynamic "target_dns_servers" {
    for_each = each.value.target_dns_servers != null ? each.value.target_dns_servers : []

    content {
      ip_address = target_dns_servers.value.ip_address
      port       = target_dns_servers.value.port
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_private_dns_resolver_virtual_network_link" "this" {
  for_each = local.virtual_network_link != null ? local.virtual_network_link : {}

  name                      = each.value.link_name
  virtual_network_id        = each.value.virtual_network_id
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this[each.value.parent_key].id
  metadata                  = each.value.metadata

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
