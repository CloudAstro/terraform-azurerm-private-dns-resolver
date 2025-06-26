locals {
  forwarding_ruleset = merge([
    for key, value in var.outbound_endpoint : (
      value.forwarding_ruleset != null ? {
        for ruleset_key, ruleset_value in value.forwarding_ruleset :
        "${key}_${ruleset_key}" => {
          parent_key           = key
          name                 = ruleset_value.name
          rule                 = ruleset_value.rule
          virtual_network_link = ruleset_value.virtual_network_link
        }
      } : null
    )
  ]...)

  forwarding_rule = merge([
    for key, value in local.forwarding_ruleset : (
      value.rule != null ? {
        for rule_key, rule_value in value.rule : "${key}_${rule_key}" => {
          parent_key         = key
          rule_name          = rule_value.name
          domain_name        = rule_value.domain_name
          enabled            = rule_value.enabled
          metadata           = rule_value.metadata
          target_dns_servers = rule_value.target_dns_servers
        }
      } : null
    )
  ]...)

  virtual_network_link = merge([
    for key, value in local.forwarding_ruleset : (
      value.virtual_network_link != null ? {
        for link_key, link_value in value.virtual_network_link : "${key}_${link_key}" => {
          parent_key         = key
          link_name          = link_value.name
          virtual_network_id = link_value.virtual_network_id
          metadata           = link_value.metadata
        }
      } : null
    )
  ]...)
}
