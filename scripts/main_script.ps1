# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess,Group.ReadWrite.All'

$scriptDir = $PSScriptRoot

$createLocationsScript = Join-Path -Path $scriptDir -ChildPath "create_known_locations.ps1"



& $createLocationsScript
