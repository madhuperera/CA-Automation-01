# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess'

$scriptDir = $PSScriptRoot
$locationsFolder = Join-Path -Path $scriptDir -ChildPath "..\data\known_locations"

$AllLocations = Get-ChildItem -Path $locationsFolder -Recurse -File | Where-Object { $_.Name -like "*.json" }

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
                   
    $locationData = Get-Content -Path $location.FullName -Raw | ConvertFrom-Json

    switch ($locationData.type)
    {
        "CountryBased"
        {
            $params = @{
                "@odata.type"                     = "#microsoft.graph.countryNamedLocation"
                DisplayName                       = $locationData.displayName
                CountriesAndRegions               = $locationData.countriesAndRegions
                IncludeUnknownCountriesAndRegions = $locationData.includeUnknownCountriesAndRegions
            }
        }
        Default
        {
            Write-Output "Unknown location type: $($locationData.type)"
        }
    }
    
    $NamedLocationId = (Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$($locationData.displayName)'" -ErrorAction SilentlyContinue).Id

    if ($NamedLocationId)
    {
        Write-Output "Location $($locationData.displayName) already exists. Attempting to update it ...."
        Update-MgIdentityConditionalAccessNamedLocation -NamedLocationId $NamedLocationId -BodyParameter $params
        $NamedLocationId = $null
    }
    else
    {
        New-MgIdentityConditionalAccessNamedLocation -BodyParameter $params
    }
}