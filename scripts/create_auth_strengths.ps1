# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess'

$scriptDir    = $PSScriptRoot
$strengthsDir = Join-Path -Path $scriptDir -ChildPath "..\data\auth_strengths"
$graphBaseUri = "https://graph.microsoft.com/v1.0/policies/authenticationStrengthPolicies"
$ResultType   = "Authentication Strength"

# Shared deployment helpers (run report)
. (Join-Path -Path $scriptDir -ChildPath "deployment_helpers.ps1")

# Re-run rule: an authentication strength that already exists (matched by DisplayName) is never modified.

$AllStrengths = Get-ChildItem -Path $strengthsDir -Recurse -File | Where-Object { $_.Name -like "*.psd1" }

if ($AllStrengths.Count -eq 0)
{
    Write-Output "No authentication strengths found in $strengthsDir"
    return
}

$TotalCount   = $AllStrengths.Count
$CurrentCount = 0

foreach ($Strength in $AllStrengths)
{
    $CurrentCount++
    Write-Progress -Activity "Processing Authentication Strengths" `
                   -Status "Processing $CurrentCount of $TotalCount" `
                   -PercentComplete (($CurrentCount / $TotalCount) * 100)

    $params = Import-PowerShellDataFile -Path $Strength.FullName

    # ---- Validation ------------------------------------------------------
    if ([string]::IsNullOrWhiteSpace($params.DisplayName))
    {
        Add-DeploymentResult -Type $ResultType -Name $Strength.Name -Action "Skipped" -Reason "Invalid definition: DisplayName is required"
        continue
    }
    if (-not $params.AllowedCombinations -or $params.AllowedCombinations.Count -eq 0)
    {
        Add-DeploymentResult -Type $ResultType -Name $Strength.Name -Action "Skipped" -Reason "Invalid definition: AllowedCombinations must contain at least one value"
        continue
    }

    # ---- Lookup existing by DisplayName (the matching key) ---------------
    $escapedName = $params.DisplayName.Replace("'", "''")
    $lookupUri   = "$graphBaseUri`?`$filter=displayName eq '$escapedName'&`$select=id,displayName"

    try
    {
        $existing = Invoke-MgGraphRequest -Method GET -Uri $lookupUri -ErrorAction Stop
    }
    catch
    {
        Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Failed" -Reason "Could not check for an existing strength: $($_.Exception.Message)"
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
        $body = @{
            displayName         = $params.DisplayName
            description         = $params.Description
            allowedCombinations = @($params.AllowedCombinations)
        } | ConvertTo-Json -Depth 5

        try
        {
            Invoke-MgGraphRequest -Method POST -Uri $graphBaseUri -Body $body -ContentType 'application/json' -ErrorAction Stop | Out-Null
            Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Created" -Reason "Did not exist"
        }
        catch
        {
            Add-DeploymentResult -Type $ResultType -Name $params.DisplayName -Action "Failed" -Reason "Create failed: $($_.Exception.Message)"
        }
    }
}
