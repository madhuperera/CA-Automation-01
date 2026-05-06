# Connect-MgGraph -Scopes 'AuthenticationContext.ReadWrite.All'

$scriptDir    = $PSScriptRoot
$contextsDir  = Join-Path -Path $scriptDir -ChildPath "..\data\auth_contexts"
$graphBaseUri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/authenticationContextClassReferences"

$AllContexts = Get-ChildItem -Path $contextsDir -Recurse -File | Where-Object { $_.Name -like "*.psd1" }

if ($AllContexts.Count -eq 0)
{
    Write-Output "No authentication contexts found in $contextsDir"
    return
}

$TotalCount   = $AllContexts.Count
$CurrentCount = 0

foreach ($Context in $AllContexts)
{
    $CurrentCount++
    Write-Progress -Activity "Processing Authentication Contexts" `
                   -Status "Processing $CurrentCount of $TotalCount" `
                   -PercentComplete (($CurrentCount / $TotalCount) * 100)

    $params = Import-PowerShellDataFile -Path $Context.FullName

    # ---- Validation ------------------------------------------------------
    if ([string]::IsNullOrWhiteSpace($params.Id) -or $params.Id -notmatch '^c([1-9]|1\d|2[0-5])$')
    {
        Write-Warning "Skipping $($Context.Name): Id '$($params.Id)' is invalid. Allowed values are c1..c25 (lowercase)."
        continue
    }
    if ([string]::IsNullOrWhiteSpace($params.DisplayName))
    {
        Write-Warning "Skipping $($Context.Name): DisplayName is required."
        continue
    }

    $body = @{
        displayName = $params.DisplayName
        description = $params.Description
        isAvailable = [bool]$params.IsAvailable
    } | ConvertTo-Json -Depth 5

    $uri = "$graphBaseUri/$($params.Id)"

    try
    {
        # PATCH performs an upsert: creates if the Id doesn't exist, updates if it does.
        Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body -ContentType 'application/json' | Out-Null
        Write-Output "OK  $($params.Id) - $($params.DisplayName)"
    }
    catch
    {
        Write-Warning "Failed $($params.Id) - $($params.DisplayName): $($_.Exception.Message)"
    }
}
