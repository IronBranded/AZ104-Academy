---
objective: "(Project prerequisite - not an AZ-104 exam objective)"
sub_objectives: []
domain: "Lab Safety and Environment Setup"
domain_weight: "n/a"
status: GA
prerequisites: []
ms_learn_source: "https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104"
product_docs:
  - "https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access"
  - "https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview"
last_verified: "2026-09-15"
portal: "Azure portal > Subscriptions; Microsoft Entra admin center"
powershell_module: "Az.Accounts, Microsoft.Graph.Authentication"
az_cli_command: "az account show"
kql_tables: []
licensing: "Azure subscription with a payment method. Microsoft Entra ID Free is enough for Module 0."
azure_resources: []
lab_cost_estimate: "$0"
free_practice_available: true
---

# Module 0 Overview: Lab Topology and Conventions

> **Read this before you create a single resource.**

## Why this module exists first

Everything else in this guide creates billable Azure resources or privileged
Microsoft Entra objects. Two failure modes wreck a self-funded lab, and both are
silent:

1. **Spend you didn't notice.** AZ-104 is an administrator exam, so its labs build
   real infrastructure: virtual machines, scale sets, load balancers, App Service
   plans, backup vaults. Some of these bill for *existing*, not for *being used*.
   Even the simplest case catches people: a VM shut down from inside its operating
   system still bills for compute, and only a *deallocated* VM stops. Each lab that
   meets an hourly meter names it in its header.
2. **Privilege you left behind.** A lab that grants Owner at subscription scope
   and never revokes it is not a lab, it's a permanent misconfiguration you
   built yourself. Worse, it teaches your hands the opposite of what the exam
   tests.

Module 0 is the control plane for both. It is not exam content. It is what makes
the exam content survivable.

## The mental model: blast radius and time

Every lab in this guide is designed around two questions:

- **What is the blast radius of this change?** A resource group is disposable.
  A subscription-scope Azure Policy or role assignment is not. A tenant-wide
  Microsoft Entra setting, such as self-service password reset or external
  collaboration, applies to every user, including the account you are signed in
  with.
- **How long does it persist?** A deallocated VM stops billing for compute but
  its disks keep billing. A Recovery Services vault can't be deleted while it
  holds backup items, including soft-deleted ones, which stay for 14 days. A
  deleted Microsoft Entra user waits 30 days in Deleted users. None of these end
  when you close the portal.

Scope and persistence, not the portal blade, are what determine whether a lab is
safe. The teardown checklist in
[00-02](./00-02-teardown-checklist-template.md) is organised the same way.

## Lab topology

```
Microsoft Entra tenant  (az104lab.onmicrosoft.com)
│
├── break-glass-01@…          Permanent Global Administrator.
│                             Password stored offline. Never used for lab work.
│                             Signs in only to recover the tenant.
│
├── break-glass-02@…          Second emergency account, different auth method.
│
└── you@…                     Your working account.
                              NO standing Global Administrator.
                              Each lab lists the roles it needs: assign them at
                              the start, remove them in teardown.

Azure subscription
│
├── rg-az104-core             Long-lived. Survives teardown.
│   ├── ag-az104-budget-brake      Action group
│   └── aa-az104-brake             Automation account running the compute brake
│
├── rg-az104-lab-01-02        One resource group per lab. Disposable.
├── rg-az104-lab-03-02        Created at lab start, deleted at teardown.
└── rg-az104-lab-…
```

Two emergency access accounts is Microsoft's own guidance, not a lab
convention: it is how you get back into a tenant when a setting you changed
locks your working account out. Set them up first.

**Why no just-in-time access here?** Privileged Identity Management needs
Microsoft Entra ID P2 and isn't part of the AZ-104 skills outline; it belongs to
identity-administrator study. The AZ-104 habit is simpler and exam-relevant: hold
only the roles the current lab needs, at the narrowest scope that works, and
remove them when you finish. Module 01-02 teaches the role model behind it.

## Naming convention

| Thing | Pattern | Example |
| --- | --- | --- |
| Lab resource group | `rg-az104-lab-<moduleId>` | `rg-az104-lab-02-04` |
| Long-lived resource group | `rg-az104-core` | — |
| Resource | `<abbrev>-az104-<moduleId>-<n>` | `vm-az104-03-04-1` |
| Entra object | `az104-<moduleId>-<purpose>` | `az104-01-01-app-reg` |
| Policy assignment | `az104-<moduleId>-<policy>` | `az104-01-03-require-https` |
| Tag on every lab resource | `az104-module = <moduleId>` | `az104-module = 02-04` |

The tag is what makes an orphan hunt possible later. Resource group names cover
resources; the tag covers the ones that end up somewhere unexpected.

```powershell
# Find anything you created that is no longer in a lab resource group
Get-AzResource -TagName 'az104-module' |
    Where-Object ResourceGroupName -notlike 'rg-az104-lab-*' |
    Select-Object Name, ResourceType, ResourceGroupName, @{n='Module';e={$_.Tags['az104-module']}}
```

## The one thing Global Administrator does not give you

A brand new tenant admin usually trips over this in the first hour: **Global
Administrator is an Entra ID role and grants no access to Azure resources.**
The two are separate authorization systems. Global Admin controls the
directory; Azure RBAC controls subscriptions and everything in them.

If your subscription was created under a different account, you can grant
yourself access from the directory side with the "Access management for Azure
resources" elevation, which temporarily gives your Global Admin account User
Access Administrator at root scope (`/`):

```powershell
# Portal: Entra admin center > Roles & admins > (your account) > toggle
# "Access management for Azure resources" to Yes, then sign out and back in.

# Verify what you actually hold at subscription scope
Get-AzRoleAssignment -SignInName (Get-AzContext).Account.Id |
    Select-Object RoleDefinitionName, Scope
```

Turn the elevation off again once you have granted yourself a normal Azure role.
It is root-scope access; leaving it on is exactly the kind of overprivileged
assignment module 01-02 teaches you to find and remove.

## Order of operations

Do these in order. Each one depends on the one before it.

1. Create the two emergency access accounts and store their credentials
   outside the tenant.
2. **[00-01 - Cost guardrails](./00-01-cost-guardrails-and-budgets.md).**
   Budget, action group, and the compute brake. Before any billable resource
   exists. It is also early practice for the budgets and alerts in the AZ-104
   governance skills (module 01-03), which this guide covers properly there.
3. **[00-02 - Teardown checklist](./00-02-teardown-checklist-template.md).**
   Read it now so you recognise the pattern when every later lab ends with it.

Only then start Domain 1.

## Check yourself

1. You delete `rg-az104-lab-03-02` after a VM lab. Name two things that can keep
   costing money or keep granting access, and the scope each lives at.
2. Why does a budget alert not prevent overspend? What is the minimum you have
   to add to make it actually stop something?
3. A VM shows **Stopped** in the portal after you shut it down from inside Windows.
   Is it still billing for compute? What would you do differently?
4. You hold Global Administrator. `Get-AzResource` returns nothing. What is
   wrong, and what are the two different ways to fix it?

## Sources

- Microsoft Learn - AZ-104 skills measured: <https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104>
- Manage emergency access accounts in Microsoft Entra ID: <https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access>
- Elevate access to manage all Azure subscriptions and management groups: <https://learn.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin>
- Power states and billing for Azure virtual machines: <https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing>
- Delete an Azure Backup Recovery Services vault: <https://learn.microsoft.com/en-us/azure/backup/backup-azure-delete-vault>
- Restore or remove a recently deleted user: <https://learn.microsoft.com/en-us/entra/fundamentals/users-restore>
