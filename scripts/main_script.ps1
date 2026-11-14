param(
    [ValidateSet("Core","Advanced")]
    [string]$Mode = "Advanced"
)

$RequireScopes = 'Policy.Read.All','Policy.ReadWrite.ConditionalAccess','Group.ReadWrite.All','Application.Read.All','AuthenticationContext.ReadWrite.All','LicenseAssignment.Read.All'
Disconnect-MgGraph -ErrorAction SilentlyContinue
Connect-MgGraph -Scopes $RequireScopes

$CurrentSession = Get-MgContext -ErrorAction SilentlyContinue
if ($CurrentSession)
{
    Write-Host "Connected to Microsoft Graph as $($CurrentSession.Account)" -ForegroundColor Red
    Write-Output "This script will execute changes in the current tenant. If this is not the intended tenant, press Ctrl + C to exit immediately."
    for ($i = 60; $i -ge 1; $i--)
    {
        Write-Host "Continuing in $i seconds..." -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
}
else
{
    Write-Output "Failed to connect to Microsoft Graph."
    exit 1
}
$scriptDir = $PSScriptRoot

# Load policy filter if Core mode selected
if ($Mode -eq "Core")
{
    $tiers = Import-PowerShellDataFile (Join-Path $scriptDir "..\data\policy_tiers.psd1")
    $script:PolicyFilter = $tiers.Core
    Write-Output "Mode: Core - deploying $($script:PolicyFilter.Count) baseline policies"
}
else
{
    $script:PolicyFilter = $null
    Write-Output "Mode: Advanced - deploying all policies"
}

# Collects one entry per object processed (Created / Updated / Skipped / Failed).
# The sub-scripts and policy scripts add to this list through Add-DeploymentResult in deployment_helpers.ps1.
$DeploymentResults = [System.Collections.Generic.List[object]]::new()

# IMPORTANT: Use dot-sourcing (.) not the call operator (&) for child scripts.
# Dot-sourcing runs them in this script's scope so they can read $script:PolicyFilter.
# Using & would create a new scope where $script:PolicyFilter is $null, ignoring the Core/Advanced filter.

Write-Output "Creating Authentication Strengths ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_auth_strengths.ps1"
. $createLocationsScript
$createLocationsScript = $null

Write-Output "Creating Authentication Contexts ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_auth_contexts.ps1"
. $createLocationsScript
$createLocationsScript = $null

Write-Output "Creating Known Locations ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_known_locations.ps1"
. $createLocationsScript
$createLocationsScript = $null

Write-Output "Creating Break Glass Groups ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_break_glass_groups.ps1"
. $createLocationsScript
$createLocationsScript = $null

Write-Output "Creating Exclusion Groups ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_groups.ps1"
. $createLocationsScript
$createLocationsScript = $null

Write-Output "Creating Conditonal Access Policies ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_ca_policies.ps1"
. $createLocationsScript
$createLocationsScript = $null

# ---- Deployment report -------------------------------------------------
Write-Host ""
Write-Host "Deployment summary" -ForegroundColor Cyan

if ($DeploymentResults.Count -eq 0)
{
    Write-Host "No results were recorded."
}
else
{
    $DeploymentResults |
        Group-Object -Property Type, Action |
        Select-Object @{ Name = "Type"; Expression = { $_.Group[0].Type } },
                      @{ Name = "Action"; Expression = { $_.Group[0].Action } },
                      Count |
        Sort-Object -Property Type, Action |
        Format-Table -AutoSize |
        Out-Host

    $NotApplied = $DeploymentResults | Where-Object { $_.Action -in "Skipped", "Failed" }
    if ($NotApplied)
    {
        Write-Host "Skipped or failed:" -ForegroundColor Yellow
        foreach ($Item in $NotApplied)
        {
            $ItemColour = if ($Item.Action -eq "Failed") { "Red" } else { "Yellow" }
            Write-Host ("{0,-8} {1}: {2}" -f $Item.Action.ToUpper(), $Item.Type, $Item.Name) -ForegroundColor $ItemColour
            Write-Host ("         {0}" -f $Item.Reason)
        }
        Write-Host ""
    }

    # The report is always written to the folder the script is being run from (the current
    # working directory), not the folder the script is stored in.
    # CA-Deployment_*.csv is excluded from Git because the file name identifies the tenant.
    $reportDir = (Get-Location -PSProvider FileSystem).ProviderPath
    $reportFile = Join-Path -Path $reportDir -ChildPath ("CA-Deployment_{0}_{1}.csv" -f $CurrentSession.TenantId, (Get-Date -Format "yyyyMMdd-HHmmss"))
    $DeploymentResults | Export-Csv -LiteralPath $reportFile -NoTypeInformation -Encoding UTF8
    Write-Host "Report saved to $reportFile"
}
