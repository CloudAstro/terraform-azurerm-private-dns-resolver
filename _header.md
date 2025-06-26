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
