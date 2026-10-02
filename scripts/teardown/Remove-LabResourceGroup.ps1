<#
.SYNOPSIS
    Tears down one AZ-104 lab across all four scopes and verifies the result.

.DESCRIPTION
    Implements the checklist in content/00-lab-safety/00-02-teardown-checklist-template.md:

      1. Resources            - delete the lab resource group
      2. Subscription scope   - policy assignments, orphaned role assignments
      3. Directory scope      - reported, never auto-deleted
      4. Soft-deleted remains - key vaults holding a name hostage
      5. Access               - roles on your own account are reported, not removed
      6. Verify               - a sweep that proves the teardown worked

    Directory objects and resource locks are deliberately NOT removed
    automatically. A script that deletes users, groups or tenant settings on
    your behalf can lock you out of your own tenant, and a lock exists precisely
    to make deletion a deliberate act. Both are reported instead.

.PARAMETER LabId
    Module identifier, e.g. '02-04'. Matches the rg-az104-lab-<LabId> convention
    and the az104-module tag.

.PARAMETER SweepOnly
    Skip deletion. Run the end-of-session verification sweep across the whole
    subscription and report anything outstanding.

.EXAMPLE
    .\Remove-LabResourceGroup.ps1 -LabId '02-04' -WhatIf

.EXAMPLE
    .\Remove-LabResourceGroup.ps1 -SweepOnly
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(ParameterSetName = 'Lab', Mandatory)]
    [ValidatePattern('^\d{2}-\d{2}$')]
    [string]$LabId,

    [Parameter(ParameterSetName = 'Sweep', Mandatory)]
    [switch]$SweepOnly,

    [string]$Prefix = 'rg-az104-lab',
    [switch]$PurgeKeyVaults
)

$ErrorActionPreference = 'Stop'

$ctx = Get-AzContext
if (-not $ctx) { throw 'No Azure context. Run Connect-AzAccount first.' }
$SubId = $ctx.Subscription.Id
$SubScope = "/subscriptions/$SubId"

Write-Host "Subscription: $($ctx.Subscription.Name)" -ForegroundColor Cyan

function Write-Section { param([string]$T) Write-Host "`n--- $T ---" -ForegroundColor Cyan }

#region -------------------------------------------------------------- Teardown

if (-not $SweepOnly) {
    $rgName = "$Prefix-$LabId"

    # 1. Resources -------------------------------------------------------------
    Write-Section "1. Resources ($rgName)"
    $rg = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Host "  Not present - nothing to delete." -ForegroundColor DarkGray
    } else {
        $contents = Get-AzResource -ResourceGroupName $rgName
        Write-Host "  $($contents.Count) resource(s):"
        $contents | ForEach-Object { Write-Host "    $($_.ResourceType)  $($_.Name)" }
        # A delete lock here, or on the subscription, makes the delete fail.
        $locks = Get-AzResourceLock -ResourceGroupName $rgName -ErrorAction SilentlyContinue
        if ($locks) {
            Write-Host '  Locks that will block deletion - remove them first, deliberately:' -ForegroundColor Yellow
            $locks | ForEach-Object { Write-Host "    $($_.Properties.level)  $($_.Name)" }
        }
        if ($PSCmdlet.ShouldProcess($rgName, 'Remove resource group')) {
            try {
                Remove-AzResourceGroup -Name $rgName -Force | Out-Null
                Write-Host "  Deleted." -ForegroundColor Green
            } catch {
                Write-Host "  Delete FAILED: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host '  Usual causes: a resource lock, or a Recovery Services vault still holding' -ForegroundColor DarkGray
                Write-Host '  backup items, including soft-deleted ones (kept 14 days). See 00-02.' -ForegroundColor DarkGray
            }
        }
    }

    # 2. Subscription scope ----------------------------------------------------
    Write-Section '2. Subscription scope'

    $policies = Get-AzPolicyAssignment -Scope $SubScope |
        Where-Object { $_.Name -like "az104-$LabId*" }
    foreach ($pol in $policies) {
        Write-Host "  Policy assignment: $($pol.Name)"
        if ($PSCmdlet.ShouldProcess($pol.Name, 'Remove policy assignment')) {
            Remove-AzPolicyAssignment -Id $pol.Id
            Write-Host '      removed' -ForegroundColor Green
        }
    }
    if (-not $policies) { Write-Host '  No matching policy assignments.' -ForegroundColor DarkGray }

    # Orphaned role assignments show an empty DisplayName: the principal or the
    # scope they referenced no longer resolves. No -Scope: that parameter returns
    # assignments at the scope and ABOVE, which would miss resource-group orphans.
    $orphans = Get-AzRoleAssignment |
        Where-Object { [string]::IsNullOrWhiteSpace($_.DisplayName) }
    if ($orphans) {
        Write-Host "  $($orphans.Count) orphaned role assignment(s):" -ForegroundColor Yellow
        foreach ($o in $orphans) {
            Write-Host "    $($o.RoleDefinitionName) -> $($o.ObjectId)"
            if ($PSCmdlet.ShouldProcess($o.RoleAssignmentId, 'Remove orphaned role assignment')) {
                Remove-AzRoleAssignment -ObjectId $o.ObjectId `
                                        -RoleDefinitionName $o.RoleDefinitionName `
                                        -Scope $o.Scope -ErrorAction SilentlyContinue
                Write-Host '      removed' -ForegroundColor Green
            }
        }
    } else {
        Write-Host '  No orphaned role assignments.' -ForegroundColor DarkGray
    }

    # 3. Directory scope - report only -----------------------------------------
    Write-Section '3. Directory scope (manual)'
    $users  = Get-AzADUser  -DisplayNameStartsWith "az104-$LabId" -ErrorAction SilentlyContinue
    $groups = Get-AzADGroup -DisplayNameStartsWith "az104-$LabId" -ErrorAction SilentlyContinue
    if ($users -or $groups) {
        Write-Host '  Directory objects to review and delete by hand (see the lab''s teardown):' -ForegroundColor Yellow
        $users  | ForEach-Object { Write-Host "    user   $($_.DisplayName)  $($_.UserPrincipalName)" }
        $groups | ForEach-Object { Write-Host "    group  $($_.DisplayName)" }
    } else {
        Write-Host '  No users or groups named for this lab.' -ForegroundColor DarkGray
    }
    Write-Host '  Tenant-wide settings (SSPR, external collaboration) are never changed by this script.' -ForegroundColor DarkGray

    # 4. Soft-deleted remains ---------------------------------------------------
    Write-Section '4. Soft-deleted remains'
    $deadVaults = Get-AzKeyVault -InRemovedState -ErrorAction SilentlyContinue |
        Where-Object VaultName -like "*az104*$LabId*"
    if ($deadVaults) {
        foreach ($v in $deadVaults) {
            $pp = if ($v.PurgeProtectionEnabled) { ' PURGE PROTECTION ON - cannot purge' } else { '' }
            Write-Host "  $($v.VaultName)  deleted $($v.DeletionDate)$pp" -ForegroundColor Yellow
            if ($PurgeKeyVaults -and -not $v.PurgeProtectionEnabled) {
                if ($PSCmdlet.ShouldProcess($v.VaultName, 'Purge soft-deleted key vault')) {
                    Remove-AzKeyVault -VaultName $v.VaultName -Location $v.Location -InRemovedState -Force
                    Write-Host '      purged' -ForegroundColor Green
                }
            }
        }
        if (-not $PurgeKeyVaults) {
            Write-Host '  Re-run with -PurgeKeyVaults to free these names.' -ForegroundColor DarkGray
        }
    } else {
        Write-Host '  None.' -ForegroundColor DarkGray
    }
}

#endregion

#region ----------------------------------------------------------------- Sweep

Write-Section '6. Verification sweep'

$homeless = Get-AzResource -TagName 'az104-module' -ErrorAction SilentlyContinue |
    Where-Object ResourceGroupName -notlike "$Prefix-*"
if ($homeless) {
    Write-Host "  $($homeless.Count) tagged resource(s) outside a lab resource group:" -ForegroundColor Yellow
    $homeless | ForEach-Object {
        Write-Host "    [$($_.Tags['az104-module'])] $($_.ResourceType)  $($_.Name)  in $($_.ResourceGroupName)"
    }
} else {
    Write-Host '  No homeless tagged resources.' -ForegroundColor Green
}

$labRgs = Get-AzResourceGroup -Name "$Prefix-*" -ErrorAction SilentlyContinue
if ($labRgs) {
    Write-Host "  Lab resource groups still present: $($labRgs.ResourceGroupName -join ', ')" -ForegroundColor Yellow
} else {
    Write-Host '  No lab resource groups remain.' -ForegroundColor Green
}

# Anything not deallocated still bills for compute - including a VM shut down
# from inside its operating system, which shows as 'VM stopped'.
$allocatedVMs = Get-AzVM -Status -ErrorAction SilentlyContinue |
    Where-Object { $_.PowerState -ne 'VM deallocated' }
if ($allocatedVMs) {
    Write-Host "  $($allocatedVMs.Count) VM(s) still allocated: $(($allocatedVMs | ForEach-Object { "$($_.Name) ($($_.PowerState))" }) -join ', ')" -ForegroundColor Yellow
} else {
    Write-Host '  No allocated VMs.' -ForegroundColor Green
}

Write-Host "`nNot covered by this script - check by hand:" -ForegroundColor DarkGray
Write-Host '  Microsoft Entra roles on your own account, tenant-wide settings a lab changed,' -ForegroundColor DarkGray
Write-Host '  soft-deleted backup items (14 days) and deleted users (30 days).' -ForegroundColor DarkGray

#endregion
