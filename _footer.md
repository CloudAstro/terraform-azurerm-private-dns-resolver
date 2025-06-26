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
