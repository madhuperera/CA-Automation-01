# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess'

$scriptDir    = $PSScriptRoot
$strengthsDir = Join-Path -Path $scriptDir -ChildPath "..\data\auth_strengths"
$graphBaseUri = "https://graph.microsoft.com/v1.0/policies/authenticationStrengthPolicies"

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
        Write-Warning "Skipping $($Strength.Name): DisplayName is required."
        continue
    }
    if (-not $params.AllowedCombinations -or $params.AllowedCombinations.Count -eq 0)
    {
        Write-Warning "Skipping $($Strength.Name): AllowedCombinations must contain at least one value."
        continue
    }

    # ---- Lookup existing by DisplayName (the upsert key) -----------------
    $escapedName = $params.DisplayName.Replace("'", "''")
    $lookupUri   = "$graphBaseUri`?`$filter=displayName eq '$escapedName'&`$select=id,displayName"

    try
    {
        $existing = Invoke-MgGraphRequest -Method GET -Uri $lookupUri -ErrorAction Stop
    }
    catch
    {
        Write-Warning "Failed lookup for '$($params.DisplayName)': $($_.Exception.Message)"
        continue
    }

    $existingId = ($existing.value | Select-Object -First 1).id

    if ($existingId)
    {
        # ---- Update ------------------------------------------------------
        $body = @{
            description         = $params.Description
            allowedCombinations = @($params.AllowedCombinations)
        } | ConvertTo-Json -Depth 5

        $uri = "$graphBaseUri/$existingId"

        try
        {
            Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body -ContentType 'application/json' | Out-Null
            Write-Output "UPD $($params.DisplayName) ($existingId)"
        }
        catch
        {
            Write-Warning "Failed update for '$($params.DisplayName)': $($_.Exception.Message)"
        }
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
            $created = Invoke-MgGraphRequest -Method POST -Uri $graphBaseUri -Body $body -ContentType 'application/json'
            Write-Output "NEW $($params.DisplayName) ($($created.id))"
        }
        catch
        {
            Write-Warning "Failed create for '$($params.DisplayName)': $($_.Exception.Message)"
        }
    }
}
