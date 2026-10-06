---
objective: "(Foundation primer - prerequisite knowledge for AZ-104, not an exam objective)"
sub_objectives: []
domain: "Understanding Azure"
domain_weight: "n/a"
status: GA
prerequisites: []
ms_learn_source: "https://learn.microsoft.com/en-us/training/paths/microsoft-azure-fundamentals-describe-cloud-concepts/"
product_docs:
  - "https://learn.microsoft.com/en-us/training/paths/microsoft-azure-fundamentals-describe-cloud-concepts/"
  - "https://learn.microsoft.com/en-us/azure/security/fundamentals/shared-responsibility"
last_verified: "2026-10-06"
portal: "Azure portal > Cost Management"
powershell_module: "Az.Accounts"
az_cli_command: "az account show"
kql_tables: []
licensing: "None. Reading only."
azure_resources: []
lab_cost_estimate: "$0 - reading only; nothing is deployed."
free_practice_available: true
---

# Cloud Computing and Datacenters

> **Foundation primer.** Not an exam objective by itself: it explains what the AZ-104 lessons assume.

## The problem

A company launches a new service next month. It needs twenty servers for launch week and perhaps five afterwards.
Buying hardware means weeks of lead time, a server room, power, cooling and staff, and fifteen machines sitting
idle once the rush is over. Renting capacity instead solves that, but only if the company knows exactly which
parts it still has to look after.

## In plain English

Cloud computing is renting computing power, storage and networking from a provider's datacenters, over a network,
when you need it, and paying for what you use. The provider owns the buildings, the hardware, the power and the
physical security. You decide what runs, how it's configured and who can reach it.

Azure is Microsoft's cloud. As an Azure administrator you never touch a physical server: every server, disk and
network you manage is a software object that you create, change and delete through Azure's management service.

What you rent decides what you still maintain. Rent a bare virtual server and the operating system, its patches and
everything on top are yours. Rent a ready-made platform for web apps and only the app, its data and its settings are.

## Words you need to know

| Term | In plain English |
| --- | --- |
| **Datacenter** | A building full of servers, storage and network equipment, with its own power and cooling. |
| **Cloud provider** | The company that runs the datacenters and rents out capacity: here, Microsoft. |
| **Consumption-based pricing** | Paying for what you use (per second, hour, gigabyte or operation) instead of buying hardware up front. |
| **IaaS** | Infrastructure as a service: you rent virtual hardware and manage the operating system and everything above it. |
| **PaaS** | Platform as a service: you rent a managed platform and manage only your application, data and settings. |
| **SaaS** | Software as a service: you use a finished application, such as Microsoft 365. |
| **Shared responsibility model** | Who manages and secures what, you or the provider. The split moves with IaaS, PaaS and SaaS. |

## Mental model

Think of renting a place to live. An empty apartment (IaaS): you bring and maintain the furniture. A furnished
apartment (PaaS): you bring only your belongings. A hotel room (SaaS): you check in. Whichever you rent, your
belongings and the keys you hand out are always your responsibility.

| Who looks after it? | On-premises | IaaS | PaaS | SaaS |
| --- | --- | --- | --- | --- |
| Buildings, hosts, physical network | You | Microsoft | Microsoft | Microsoft |
| Operating system and its patches | You | You | Microsoft | Microsoft |
| Application and its settings | You | You | You | You configure it |
| Your data, accounts, identities and devices | You | You | You | You |

**Azure translation**

| Everyday idea | Azure name |
| --- | --- |
| A rented server | A virtual machine (IaaS), [03-02 Virtual Machines](../03-compute/03-02-virtual-machines.md) |
| A managed place to run a web app | Azure App Service (PaaS), [03-04 Azure App Service](../03-compute/03-04-app-service.md) |
| A managed place to run containers | Container Instances and Container Apps, [03-03 Containers: Registry, Container Instances and Container Apps](../03-compute/03-03-containers.md) |
| The organization's sign-in and address book | Microsoft Entra ID, [01-01 Microsoft Entra Users and Groups](../01-identities-governance/01-01-entra-users-and-groups.md) |
| The bill | Your subscription's costs, [00-01 Cost Guardrails and Budget Alerts](../00-lab-safety/00-01-cost-guardrails-and-budgets.md) |

This is a teaching simplification: each Azure service documents precisely which parts Microsoft manages.

## Where this shows up in AZ-104

- **IaaS:** virtual machines are yours to size, patch and protect ([03-02 Virtual Machines](../03-compute/03-02-virtual-machines.md)).
- **PaaS:** App Service and Container Apps are managed platforms; you manage plans, scaling and settings, not the OS ([03-03 Containers: Registry, Container Instances and Container Apps](../03-compute/03-03-containers.md), [03-04 Azure App Service](../03-compute/03-04-app-service.md)).
- **Consumption pricing:** why every lab ends in a teardown, and why budgets and alerts are an exam objective ([00-02 Reusable Teardown Checklist](../00-lab-safety/00-02-teardown-checklist-template.md), [01-03 Subscriptions and Governance](../01-identities-governance/01-03-subscriptions-and-governance.md)).

## Check yourself

1. A Windows VM needs a security update. Who installs it? Who patches the OS under an App Service app?
2. Name one responsibility that stays yours in every service model.
3. Why does a lab VM left running overnight cost money even if nobody uses it?

## Teach it back

- Explain cloud computing with the renting analogy, then say where the analogy stops working.
- Explain why the same company might use IaaS for one workload and PaaS for another.

## Key takeaways

- Cloud computing is rented capacity, managed through software and paid for by use.
- IaaS leaves you the operating system; PaaS leaves you the app and data; SaaS leaves you configuration, data and access.
- Your data, accounts and access are always your responsibility.
- Paying for use makes cleanup part of an administrator's job.

## Sources

- Microsoft Learn: [Microsoft Azure Fundamentals: Describe cloud concepts](https://learn.microsoft.com/en-us/training/paths/microsoft-azure-fundamentals-describe-cloud-concepts/)
- Microsoft Learn: [Shared responsibility in the cloud](https://learn.microsoft.com/en-us/azure/security/fundamentals/shared-responsibility)
