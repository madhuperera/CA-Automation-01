$RequireScopes = 'Policy.ReadWrite.ConditionalAccess,Group.ReadWrite.All','Application.Read.All'
# Check for existing Microsoft Graph session
if (Get-MgContext)
{
    $currentContext = Get-MgContext
    Write-Output "You are currently connected to Microsoft Graph with the following details:"
    Write-Output "Tenant ID: $($currentContext.TenantId)"
    Write-Output "Scopes: $($currentContext.Scopes -join ', ')"
    Write-Output "Environment: $($currentContext.Environment)"
    
    $userResponse = Read-Host "Do you want to disconnect and reconnect with the required scopes? (yes/no)"
    if ($userResponse -eq "yes")
    {
        Disconnect-MgGraph
        Connect-MgGraph -Scopes $RequireScopes
    }
    else
    {
        Write-Output "Continuing with the current session..."
    }
}
else
{
    Write-Output "No active Microsoft Graph session found. Connecting with the required scopes..."
    Connect-MgGraph -Scopes $RequireScopes
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
