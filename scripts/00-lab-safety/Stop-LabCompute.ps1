<#
.SYNOPSIS
    Emergency cost brake for the AZ-104 lab subscription.

.DESCRIPTION
    Deallocates every running virtual machine and every virtual machine scale set
    tagged 'az104-module', then lists every other tagged resource so the output
    shows what is still there.

    Designed to run as an Azure Automation PowerShell runbook under a
    system-assigned managed identity holding Contributor at subscription scope,
    triggered by a webhook attached to a budget alert action group. It also runs
    interactively for testing.

    This is a BACKSTOP, not the primary control. Azure cost data lags actual
    usage by hours, so by the time a budget alert fires the spend has already
    happened. Per-lab teardown discipline is the real control.

    Deallocate, not stop. A VM shut down from inside the guest OS is "Stopped"
    and still incurs compute charges. A deallocated VM does not. Its disks, and
    any static public IP, still bill: deallocation is a brake, not a teardown.
    Stop-AzVM and Stop-AzVmss deallocate by default; -StayProvisioned is the
    opt-out, and this script never passes it.

.PARAMETER WhatIfMode
    Report what would change without changing it. Use this for the first run.
    Named WhatIfMode rather than using SupportsShouldProcess because Automation
    runbook webhook parameters are passed as plain values.

.PARAMETER TagName
    The lab tag. Defaults to the Academy convention, 'az104-module'.

.NOTES
    Required modules in the Automation account: Az.Accounts, Az.Compute, Az.Resources.
    Deallocation behaviour verified against Microsoft Learn on 2026-09-29:
      https://learn.microsoft.com/azure/virtual-machines/states-billing
      https://learn.microsoft.com/powershell/module/az.compute/stop-azvmss
#>
[CmdletBinding()]
param(
    [bool]$WhatIfMode = $false,
    [string]$TagName  = 'az104-module'
)

$ErrorActionPreference = 'Stop'
function Write-Line { param([string]$Text) Write-Output "$(Get-Date -Format 'u')  $Text" }

Write-Line '=== AZ-104 lab cost brake ==='
if ($WhatIfMode) { Write-Line 'WHATIF MODE - no changes will be made' }

# --- Authenticate ------------------------------------------------------------
# In Automation, connect with the managed identity. Interactively, reuse the
# existing context.
if ($env:AUTOMATION_ASSET_ACCOUNTID) {
    Write-Line 'Authenticating with the Automation account managed identity'
    Disable-AzContextAutosave -Scope Process | Out-Null
    $ctx = (Connect-AzAccount -Identity).Context
} else {
    Write-Line 'Using the current interactive Azure context'
    $ctx = Get-AzContext
    if (-not $ctx) { throw 'No Azure context. Run Connect-AzAccount first.' }
}
Write-Line "Subscription: $($ctx.Subscription.Name) ($($ctx.Subscription.Id))"

# --- 1. Running lab VMs --------------------------------------------------------
Write-Line ''
Write-Line "--- Virtual machines tagged $TagName ---"
$running = Get-AzVM -Status |
    Where-Object { $_.Tags -and $_.Tags.ContainsKey($TagName) -and $_.PowerState -ne 'VM deallocated' }

if (-not $running) {
    Write-Line 'No allocated tagged VMs.'
} else {
    foreach ($vm in $running) {
        $module = $vm.Tags[$TagName]
        if ($WhatIfMode) {
            Write-Line "  WOULD DEALLOCATE $($vm.Name) [module $module, now: $($vm.PowerState)]"
            continue
        }
        try {
            Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force | Out-Null
            Write-Line "  DEALLOCATED $($vm.Name) [module $module]"
        } catch {
            Write-Line "  FAILED $($vm.Name): $($_.Exception.Message)"
        }
    }
}

# --- 2. Lab scale sets ---------------------------------------------------------
Write-Line ''
Write-Line "--- Virtual machine scale sets tagged $TagName ---"
$sets = Get-AzVmss | Where-Object { $_.Tags -and $_.Tags.ContainsKey($TagName) }

if (-not $sets) {
    Write-Line 'No tagged scale sets.'
} else {
    foreach ($ss in $sets) {
        $module = $ss.Tags[$TagName]
        if ($WhatIfMode) {
            Write-Line "  WOULD DEALLOCATE ALL INSTANCES OF $($ss.Name) [module $module]"
            continue
        }
        try {
            # No -InstanceId: every instance. No -StayProvisioned: deallocated.
            Stop-AzVmss -ResourceGroupName $ss.ResourceGroupName -VMScaleSetName $ss.Name -Force | Out-Null
            Write-Line "  DEALLOCATED ALL INSTANCES OF $($ss.Name) [module $module]"
        } catch {
            Write-Line "  FAILED $($ss.Name): $($_.Exception.Message)"
        }
    }
}

# --- 3. What this does NOT stop -----------------------------------------------
# Stated explicitly so the output is honest about the gap. The brake only
# deallocates compute; everything else below keeps existing, and some of it
# keeps billing, until you tear the lab down.
Write-Line ''
Write-Line "--- Everything else tagged $TagName (still present, not changed) ---"
$others = Get-AzResource -TagName $TagName |
    Where-Object { $_.ResourceType -notin @('Microsoft.Compute/virtualMachines', 'Microsoft.Compute/virtualMachineScaleSets') }

if (-not $others) {
    Write-Line 'Nothing else tagged.'
} else {
    $others | Sort-Object { $_.Tags[$TagName] }, ResourceType | ForEach-Object {
        Write-Line ("  [{0}] {1}  {2}  (rg: {3})" -f $_.Tags[$TagName], $_.ResourceType, $_.Name, $_.ResourceGroupName)
    }
    Write-Line 'Deallocated VMs still bill for disks. Tear down each lab to stop the rest.'
}

Write-Line ''
Write-Line '=== Brake complete ==='
