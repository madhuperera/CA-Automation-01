$RequireScopes = 'Policy.Read.All','Policy.ReadWrite.ConditionalAccess','Group.ReadWrite.All','Application.Read.All'
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


Write-Output "Creating Known Locations ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_known_locations.ps1"
& $createLocationsScript
$createLocationsScript = $null

Write-Output "Creating Break Glass Groups ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_break_glass_groups.ps1"
& $createLocationsScript
$createLocationsScript = $null

Write-Output "Creating Exclusion Groups ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_groups.ps1"
& $createLocationsScript
$createLocationsScript = $null

Write-Output "Creating Conditonal Access Policies ...."
$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_ca_policies.ps1"
& $createLocationsScript
$createLocationsScript = $null
