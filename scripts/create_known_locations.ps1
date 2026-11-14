# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess'

$scriptDir = $PSScriptRoot
$locationsFolder = Join-Path -Path $scriptDir -ChildPath "..\data\known_locations"
$ResultType = "Named Location"

# Shared deployment helpers (run report)
. (Join-Path -Path $scriptDir -ChildPath "deployment_helpers.ps1")

# Re-run rule: a named location that already exists (matched by DisplayName) is never modified,
# so tenant-specific countries and IP ranges are preserved.

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

    # A failed lookup must never be treated as "location does not exist",
    # otherwise a duplicate named location would be created.
    try
    {
        $ExistingLocations = @(Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$($params.DisplayName)'" -ErrorAction Stop)
    }
    catch
    {
        Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Failed" -Reason "Could not check for an existing location: $($_.Exception.Message)"
        continue
    }

    if ($ExistingLocations.Count -gt 0)
    {
        Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Skipped" -Reason "Already exists; left unchanged"
    }
    else
    {
        try
        {
            New-MgIdentityConditionalAccessNamedLocation -BodyParameter $params -ErrorAction Stop | Out-Null
            Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Created" -Reason "Did not exist"
        }
        catch
        {
            Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Failed" -Reason "Create failed: $($_.Exception.Message)"
        }
    }
}
