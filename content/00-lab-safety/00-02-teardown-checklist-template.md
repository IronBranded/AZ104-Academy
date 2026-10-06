---
objective: "(Project prerequisite - not an AZ-104 exam objective)"
sub_objectives: []
domain: "Safe Lab Foundations"
domain_weight: "n/a"
status: GA
prerequisites: ["00-00"]
ms_learn_source: "https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104"
product_docs:
  - "https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview"
  - "https://learn.microsoft.com/en-us/azure/azure-monitor/logs/delete-workspace"
  - "https://learn.microsoft.com/en-us/azure/backup/backup-azure-delete-vault"
  - "https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources"
  - "https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing"
last_verified: "2026-09-29"
portal: "Azure portal > Resource groups; Microsoft Entra admin center"
powershell_module: "Az.Resources, Az.RecoveryServices, Az.KeyVault, Microsoft.Graph"
az_cli_command: "az group delete"
kql_tables: []
licensing: ""
azure_resources: []
lab_cost_estimate: "$0"
free_practice_available: true
---

# Reusable Teardown Checklist

> Every lab in this guide ends with a `## Teardown` section that inherits from
> this template. Read it once, here, so the pattern is familiar later.

## Why deleting the resource group is not enough

The instinct is `Remove-AzResourceGroup -Force` and move on. That handles most
resources, but the resource group is only one of several scopes a lab touches,
and the things that live elsewhere are the ones that keep costing money or keep
granting access.

Sort everything you create into four buckets:

| Bucket | Lives at | Survives RG deletion? |
| --- | --- | --- |
| **Resources** | Resource group | No — deleted with it, unless a lock or a dependency stops the delete |
| **Subscription-scope config** | Subscription or management group | **Yes** — policy assignments, role assignments, budgets, diagnostic settings |
| **Directory objects and settings** | Microsoft Entra tenant | **Yes** — users, groups, guests, and tenant-wide settings such as SSPR |
| **Soft-deleted remains** | Varies | **Yes** — backup items, deleted users, Log Analytics workspaces, key vaults |

The checklist is organised in that order, widest blast radius last.

## The traps, specifically

**Resource locks.** A delete lock on a resource or its resource group makes the
delete fail, and a lock set at a higher scope applies to everything below it.
Locks are an AZ-104 skill (module 01-03); in teardown, remove the lab's locks
first, then delete.

**Recovery Services vaults.** A vault can't be deleted while it holds protected
items or backup data, and that includes backup items in the **soft-deleted**
state. Soft delete is on by default for Recovery Services vaults, and soft-deleted
items are permanently removed 14 days after you delete them. Until then the vault
blocks its own deletion, and with it the resource group. Plan backup labs around
that wait.

**Deallocated is not deleted.** A deallocated VM stops billing for compute, but
its disks keep billing until they are deleted. A stopped-but-allocated VM bills
for compute as well.

**Azure Policy assignments.** Usually scoped to the subscription or a management
group, not the resource group. They keep evaluating and can deny later labs'
deployments, with an error you've forgotten the source of.

**Role assignments.** Deleting a resource or an identity leaves role assignments
that reference it as orphaned entries with an unresolved principal. Clean them;
reading and cleaning assignments is part of module 01-02.

**Microsoft Entra objects and settings.** Users, groups and guest accounts are
never in a resource group. A deleted user waits 30 days in **Deleted users** before
permanent deletion. Tenant-wide settings such as self-service password reset and
external collaboration apply to every user: record their values before a lab
changes them, and restore them in teardown.

**Log Analytics workspaces.** Soft-deleted for 14 days after deletion. Creating a
workspace with the same name in the same resource group and region during that
window *recovers the old one*, data and all, rather than creating a fresh one.

**Key vaults.** They appear in AZ-104 only as a supporting resource, but when a lab
uses one: soft delete is on by default, a deleted vault's name stays reserved for
its retention period, and **purge protection can't be disabled once enabled**.
Leave purge protection off unless the lab needs it.

**Diagnostic settings.** Attached to a resource, pointing at a destination.
Subscription activity-log settings survive resource-group deletion.

## The template

Copy this into any new lab file. Delete the lines that don't apply; keep the
section headings so the shape is consistent across every lab.

```markdown
## Teardown

**Mandatory.** Run before closing the session.

### 1. Resources
- [ ] Remove any resource locks this lab created
- [ ] Delete the lab resource group `rg-az104-lab-<moduleId>`
- [ ] Confirm no tagged resources remain outside it

### 2. Subscription scope
- [ ] Remove Azure Policy assignments created by this lab
- [ ] Remove role assignments created by this lab
- [ ] Remove subscription-level diagnostic settings created by this lab

### 3. Directory scope
- [ ] Delete users, groups and guests created by this lab
- [ ] Restore any tenant-wide setting this lab changed, to the value you recorded

### 4. Soft-deleted remains
- [ ] Note any soft-deleted backup items and the date the vault becomes deletable
- [ ] Permanently delete lab users from Deleted users, if their names are needed again

### 5. Access
- [ ] Remove the roles you assigned to your working account for this lab

### 6. Verify
- [ ] `Get-AzResource -TagName 'az104-module' -TagValue '<moduleId>'` returns nothing
- [ ] Cost Management shows no new daily run rate tomorrow
```

## The verification sweep

Run this at the end of any study session, whichever labs you did. Teardown you
believe you did and teardown you verified are different things.

```powershell
$SubId = (Get-AzContext).Subscription.Id

# 1. Anything tagged but homeless
Get-AzResource -TagName 'az104-module' |
    Where-Object ResourceGroupName -notlike 'rg-az104-lab-*' |
    Format-Table Name, ResourceType, ResourceGroupName

# 2. Lab resource groups still standing
Get-AzResourceGroup -Name 'rg-az104-lab-*' | Format-Table ResourceGroupName, Location

# 3. Locks that will block the next teardown
Get-AzResourceLock | Format-Table Name, LockLevel, ResourceGroupName, ResourceName

# 4. Policy assignments this guide created at subscription scope
Get-AzPolicyAssignment -Scope "/subscriptions/$SubId" |
    Where-Object { $_.Name -like 'az104-*' } | Format-Table Name, Scope

# 5. Role assignments whose principal no longer resolves, at ANY scope in the
#    subscription. (With -Scope /subscriptions/..., Get-AzRoleAssignment returns only
#    assignments at that scope and above, and misses resource-group-scope orphans.)
Get-AzRoleAssignment |
    Where-Object { -not $_.DisplayName } | Format-Table RoleDefinitionName, ObjectId, Scope

# 6. Microsoft Entra roles your working account still holds
#    (principalId takes an object id, not a sign-in name)
$me = Get-MgUser -UserId (Get-MgContext).Account
Get-MgRoleManagementDirectoryRoleAssignment -Filter "principalId eq '$($me.Id)'" -ExpandProperty RoleDefinition |
    Select-Object @{ n = 'Role'; e = { $_.RoleDefinition.DisplayName } }, DirectoryScopeId
```

Scripted version:
[`scripts/teardown/Remove-LabResourceGroup.ps1`](../../scripts/teardown/Remove-LabResourceGroup.ps1).

## The weekly habit

Teardown per lab handles the lab. Once a week, run the sweep above against the
whole subscription and reconcile it against Cost Management's daily view.
Anything you can't account for is either an orphan you missed or something you
didn't create, and both are worth knowing about.

## Check yourself

1. `Remove-AzResourceGroup` fails on a lab resource group. Name two different
   causes this checklist predicts, and how you'd tell them apart.
2. You stopped protection and deleted the backup data for the only item in a
   Recovery Services vault. Why can't you delete the vault today, and when can you?
3. A lab changed the tenant's SSPR scope from **None** to **Selected**. Which bucket
   is that in, and why can't a script safely restore it for you?
4. You deleted a lab user yesterday and want to reuse the same user principal name
   today. What must you do first?
5. Which items in the verification sweep would a resource-group-scoped teardown
   never catch?

## Sources

- Delete an Azure Backup Recovery Services vault: <https://learn.microsoft.com/en-us/azure/backup/backup-azure-delete-vault>
- Soft delete for Azure Backup, FAQ: <https://learn.microsoft.com/en-us/azure/backup/soft-delete-azure-backup-faq>
- Lock your resources to protect your infrastructure: <https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/lock-resources>
- Power states and billing for Azure virtual machines: <https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing>
- Restore or remove a recently deleted user: <https://learn.microsoft.com/en-us/entra/fundamentals/users-restore>
- Delete and recover an Azure Monitor Log Analytics workspace: <https://learn.microsoft.com/en-us/azure/azure-monitor/logs/delete-workspace>
- Azure Key Vault soft-delete overview: <https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview>
