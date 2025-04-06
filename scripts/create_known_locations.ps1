# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess'

$scriptDir = $PSScriptRoot
$locationsFolder = Join-Path -Path $scriptDir -ChildPath "..\data\known_locations"

$AllLocations = Get-ChildItem -Path $locationsFolder -Recurse -File | Where-Object { $_.Name -like "*.psd1" }

if ($AllLocations.Count -eq 0)
{
    Write-Output "No known locations found in $locationsFolder"
    return
}

$TotalCount = $AllLocations.Count
$CurrentCount = 0

foreach ($Location in $AllLocations)
{
    $CurrentCount++
    Write-Progress -Activity "Processing Known Locations" `
                   -Status "Processing $CurrentCount of $TotalCount" `
                   -PercentComplete (($CurrentCount / $TotalCount) * 100)
    
    $params = Import-PowerShellDataFile -Path $Location.FullName

    $NamedLocationId = (Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$($params.DisplayName)'" -ErrorAction SilentlyContinue).Id

    if ($NamedLocationId)
    {
        Write-Output "Location $($params.displayName) already exists. Attempting to update it ...."
        Update-MgIdentityConditionalAccessNamedLocation -NamedLocationId $NamedLocationId -BodyParameter $params
        $NamedLocationId = $null
    }
    else
    {
        New-MgIdentityConditionalAccessNamedLocation -BodyParameter $params
    } 
}