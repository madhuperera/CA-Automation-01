# Connect-MgGraph -Scopes 'AuthenticationContext.ReadWrite.All'

$scriptDir    = $PSScriptRoot
$contextsDir  = Join-Path -Path $scriptDir -ChildPath "..\data\auth_contexts"
$graphBaseUri = "https://graph.microsoft.com/v1.0/identity/conditionalAccess/authenticationContextClassReferences"
$ResultType   = "Authentication Context"

# Shared deployment helpers (run report)
. (Join-Path -Path $scriptDir -ChildPath "deployment_helpers.ps1")

$AllContexts = Get-ChildItem -Path $contextsDir -Recurse -File | Where-Object { $_.Name -like "*.psd1" }

if ($AllContexts.Count -eq 0)
{
    Write-Output "No authentication contexts found in $contextsDir"
    return
}

# ---- Read the authentication contexts that already exist in the tenant ----
# Re-run rule: a context is only created when both its Id (c1..c25) and its DisplayName are unused.
# An existing context is never modified, even if the Id is in use under a different name.
$ExistingContexts = @()
$ExistingLookupOk = $true
$nextUri          = $graphBaseUri

try
{
    while ($nextUri)
    {
        $page              = Invoke-MgGraphRequest -Method GET -Uri $nextUri -ErrorAction Stop
        $ExistingContexts += @($page.value)
        $nextUri           = $page.'@odata.nextLink'
    }
}
catch
{
    $ExistingLookupOk  = $false
    $ExistingLookupErr = $_.Exception.Message
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
        Add-DeploymentResult -Type $ResultType -Name $Context.Name -Action "Skipped" -Reason "Invalid definition: Id '$($params.Id)' is invalid. Allowed values are c1..c25 (lowercase)"
        continue
    }
    if ([string]::IsNullOrWhiteSpace($params.DisplayName))
    {
        Add-DeploymentResult -Type $ResultType -Name $Context.Name -Action "Skipped" -Reason "Invalid definition: DisplayName is required"
        continue
    }

    $ResultName = "$($params.Id) - $($params.DisplayName)"

    # ---- Skip if the Id or the DisplayName is already in use -------------
    if (-not $ExistingLookupOk)
    {
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Failed" -Reason "Could not read existing authentication contexts: $ExistingLookupErr"
        continue
    }

    $SameId   = $ExistingContexts | Where-Object { $_.id -eq $params.Id } | Select-Object -First 1
    $SameName = $ExistingContexts | Where-Object { $_.displayName -eq $params.DisplayName } | Select-Object -First 1

    if ($SameId)
    {
        if ($SameId.displayName -eq $params.DisplayName)
        {
            Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Skipped" -Reason "Already exists; left unchanged"
        }
        else
        {
            Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Skipped" -Reason "Id $($params.Id) is already in use under a different name ('$($SameId.displayName)'); left unchanged"
        }
        continue
    }
    if ($SameName)
    {
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Skipped" -Reason "The name already exists under a different Id ($($SameName.id)); left unchanged"
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
        # PATCH creates the context when the Id does not exist. The checks above make sure it does not.
        Invoke-MgGraphRequest -Method PATCH -Uri $uri -Body $body -ContentType 'application/json' -ErrorAction Stop | Out-Null
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Created" -Reason "Did not exist"
    }
    catch
    {
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Failed" -Reason "Create failed: $($_.Exception.Message)"
    }
}
