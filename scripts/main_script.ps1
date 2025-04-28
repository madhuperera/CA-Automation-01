$RequireScopes = 'Policy.ReadWrite.ConditionalAccess','Group.ReadWrite.All','Application.Read.All'
Disconnect-MgGraph -ErrorAction SilentlyContinue
Connect-MgGraph -Scopes $RequireScopes

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
