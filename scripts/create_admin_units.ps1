# Connect-MgGraph -Scopes 'AdministrativeUnit.ReadWrite.All'

$scriptDir    = $PSScriptRoot
$unitsDir     = Join-Path -Path $scriptDir -ChildPath "..\data\admin_units"
$graphBaseUri = "https://graph.microsoft.com/v1.0/directory/administrativeUnits"
$ResultType   = "Administrative Unit"

# Shared deployment helpers (run report)
. (Join-Path -Path $scriptDir -ChildPath "deployment_helpers.ps1")

# Re-run rule: an administrative unit that already exists (matched by DisplayName) is never modified.
# This script only creates the units. It never adds or removes members.

$AllUnits = Get-ChildItem -Path $unitsDir -Recurse -File | Where-Object { $_.Name -like "*.psd1" } | Sort-Object Name

if ($AllUnits.Count -eq 0)
{
    Write-Output "No administrative units found in $unitsDir"
    return
}

$TotalCount   = $AllUnits.Count
$CurrentCount = 0

foreach ($Unit in $AllUnits)
{
    $CurrentCount++
    Write-Progress -Activity "Processing Administrative Units" `
                   -Status "Processing $CurrentCount of $TotalCount" `
                   -PercentComplete (($CurrentCount / $TotalCount) * 100)

    $params = Import-PowerShellDataFile -Path $Unit.FullName

    # ---- Validation ------------------------------------------------------
    if ([string]::IsNullOrWhiteSpace($params.DisplayName))
    {
        Add-DeploymentResult -Type $ResultType -Name $Unit.Name -Action "Skipped" -Reason "Invalid definition: DisplayName is required"
        continue
    }
    if ($params.RestrictedManagement -isnot [bool])
    {
        Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Skipped" -Reason "Invalid definition: RestrictedManagement must be `$true or `$false"
        continue
    }
    if ($params.MembershipType -notin "Assigned", "Dynamic")
    {
        Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Skipped" -Reason "Invalid definition: MembershipType must be Assigned or Dynamic"
        continue
    }
    if ($params.MembershipType -eq "Dynamic" -and [string]::IsNullOrWhiteSpace($params.MembershipRule))
    {
        Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Skipped" -Reason "Invalid definition: MembershipRule is required when MembershipType is Dynamic"
        continue
    }

    # ---- Lookup existing by DisplayName (the matching key) ---------------
    $escapedName = [uri]::EscapeDataString($params.DisplayName.Replace("'", "''"))
    $lookupUri   = "$graphBaseUri`?`$filter=displayName eq '$escapedName'&`$select=id,displayName"

    try
    {
        $existing = Invoke-MgGraphRequest -Method GET -Uri $lookupUri -ErrorAction Stop
    }
    catch
    {
        Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Failed" -Reason "Could not check for an existing administrative unit: $($_.Exception.Message)"
        continue
    }

    $existingId = ($existing.value | Select-Object -First 1).id

    if ($existingId)
    {
        # ---- Skip: already exists, leave unchanged -----------------------
        Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Skipped" -Reason "Already exists; left unchanged"
    }
    else
    {
        # ---- Create ------------------------------------------------------
        # isMemberManagementRestricted can only be set when the unit is created.
        $body = @{
            displayName                  = $params.DisplayName
            description                  = $params.Description
            isMemberManagementRestricted = $params.RestrictedManagement
        }
        if ($params.MembershipType -eq "Dynamic")
        {
            $body.membershipType                = "Dynamic"
            $body.membershipRule                = $params.MembershipRule
            $body.membershipRuleProcessingState = "On"
        }

        try
        {
            Invoke-MgGraphRequest -Method POST -Uri $graphBaseUri -Body ($body | ConvertTo-Json -Depth 5) -ContentType 'application/json' -ErrorAction Stop | Out-Null
            Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Created" -Reason "Did not exist"
        }
        catch
        {
            Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Failed" -Reason "Create failed: $($_.Exception.Message)"
        }
    }
}
