---
objective: "(Foundation primer - prerequisite knowledge for AZ-104, not an exam objective)"
sub_objectives: []
domain: "Understanding Azure"
domain_weight: "n/a"
status: GA
prerequisites: ["0A-03"]
ms_learn_source: "https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types"
product_docs:
  - "https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types"
  - "https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-register-resource-provider"
  - "https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview"
last_verified: "2026-10-06"
portal: "Subscriptions > Settings > Resource providers"
powershell_module: "Az.Resources"
az_cli_command: "az provider show"
kql_tables: []
licensing: "None. Reading only."
azure_resources: []
lab_cost_estimate: "$0 - reading only; nothing is deployed."
free_practice_available: true
---

# Azure Resources and Resource Providers

> **Foundation primer.** Not an exam objective by itself: it explains what the AZ-104 lessons assume.

## The problem

You deploy a template and it fails with *The subscription is not registered to use namespace Microsoft.X*. A
colleague hands you a long string starting `/subscriptions/...` and asks you to assign a role on it. Both make sense
once you know how Azure names and supplies every resource.

## In plain English

A **resource** is anything you can create and manage in Azure: a VM, a virtual network, a storage account. Resource
groups, subscriptions, management groups and tags are resources too.

Each kind of resource comes from a **resource provider**, a service named by a namespace. `Microsoft.Compute`
supplies virtual machines and disks; `Microsoft.Storage` supplies storage accounts; `Microsoft.Network` supplies
virtual networks. The full type is the namespace plus the type, such as `Microsoft.Compute/virtualMachines`.

A subscription must be **registered** for a provider before it can create that provider's resources. The portal
and template deployments usually register what they need automatically; occasionally you register one yourself,
which takes Contributor or Owner. Register only what you use.

Every resource has a **resource ID**, its full path from subscription to resource. Role assignments, policy
scopes, templates and moves all identify resources by it.

## Words you need to know

| Term | In plain English |
| --- | --- |
| **Resource** | A manageable item in Azure: a VM, network, storage account, and also resource groups and subscriptions. |
| **Resource provider** | The service that supplies a set of resource types, named by a namespace such as Microsoft.Compute. |
| **Resource type** | Namespace plus type, such as Microsoft.Storage/storageAccounts. |
| **Registration** | Enabling a subscription to use a provider. Needs the provider's register action (Contributor or Owner). |
| **Resource ID** | The full path that uniquely identifies a resource. |
| **API version** | The dated version of a provider's API that a template or tool uses for a resource type. |
| **Extension resource** | A resource that adds to another, such as a role assignment applied to a resource. |

## Mental model

A resource ID reads like a postal address, from the largest container to the resource itself:

| Segment | Example | Means |
| --- | --- | --- |
| Subscription | `/subscriptions/1111-...` | Which bill and trust boundary |
| Resource group | `/resourceGroups/rg-app` | Which lifecycle container |
| Provider | `/providers/Microsoft.Compute` | Which service supplies it |
| Type and name | `/virtualMachines/vm-web-1` | Which resource |

| Everyday idea | Azure name |
| --- | --- |
| A department that makes one kind of product | Resource provider |
| A product's catalogue number | Resource type |
| A full delivery address | Resource ID |
| Opening an account with a supplier | Registering a resource provider |

## Where this shows up in AZ-104

- **Templates** name every resource by type and API version ([03-01 ARM Templates and Bicep](../03-compute/03-01-arm-and-bicep.md)).
- **Role assignments and policy** take scopes written as resource IDs ([01-02 Azure Role-Based Access Control](../01-identities-governance/01-02-azure-rbac.md), [01-03 Subscriptions and Governance](../01-identities-governance/01-03-subscriptions-and-governance.md)).
- **Moving resources** between groups and subscriptions works by resource ID and type ([01-03 Subscriptions and Governance](../01-identities-governance/01-03-subscriptions-and-governance.md)).

Check a registration:

```powershell
Get-AzResourceProvider -ProviderNamespace Microsoft.Compute | Select-Object ProviderNamespace, RegistrationState
az provider show --namespace Microsoft.Compute --query registrationState -o tsv
```

## Check yourself

1. Which provider supplies `virtualMachines`, and which supplies `storageAccounts`?
2. A deployment fails with `MissingSubscriptionRegistration`. What do you check, and what role lets you fix it?
3. Read `/subscriptions/x/resourceGroups/rg-data/providers/Microsoft.Storage/storageAccounts/stdata01`. What, where and which type?

## Teach it back

- Explain resource providers as suppliers and registration as opening an account with one.
- Read a resource ID aloud from left to right and explain each part.

## Key takeaways

- Everything you manage is a resource, supplied by a resource provider namespace.
- A subscription must be registered for a provider; the portal and templates usually do it for you.
- The resource ID is the resource's full address and is how scopes are written.

## Sources

- Microsoft Learn: [Azure resource providers and types](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types)
- Microsoft Learn: [Resolve errors for resource provider registration](https://learn.microsoft.com/en-us/azure/azure-resource-manager/troubleshooting/error-register-resource-provider)
- Microsoft Learn: [What is Azure Resource Manager?](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview)
