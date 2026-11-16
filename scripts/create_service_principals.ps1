# Connect-MgGraph -Scopes 'Application.Read.All'
# 'Application.ReadWrite.All' is requested only when a service principal is missing and you choose to create it.

$scriptDir       = $PSScriptRoot
$principalsDir   = Join-Path -Path $scriptDir -ChildPath "..\data\service_principals"
$graphBaseUri    = "https://graph.microsoft.com/v1.0/servicePrincipals"
$ResultType      = "Service Principal"
$CreateScope     = "Application.ReadWrite.All"

# Shared deployment helpers (run report)
. (Join-Path -Path $scriptDir -ChildPath "deployment_helpers.ps1")

# Some Conditional Access policies target a Microsoft application that has no service principal in
# every tenant. Microsoft Graph rejects a policy that targets an application without one.
#
# Re-run rule: a service principal that already exists is never modified.
# A missing one is only created after you answer Y to the prompt below. If you answer N, the
# policies that need it are reported as Skipped instead of failing.

function Add-UnavailableApplication
{
    param([string]$AppId, [string]$Reason)

    # $UnavailableApplications is created by main_script.ps1 and read by Deploy-CAPolicy.
    # When this script is run on its own the table does not exist and nothing is recorded.
    if ($UnavailableApplications -is [hashtable])
    {
        $UnavailableApplications[$AppId] = $Reason
    }
}

function Show-MissingServicePrincipalPrompt
{
    param([string]$DisplayName, [string]$AppId, [string[]]$RequiredBy)

    $Width = 78
    $Lines = @(
        ""
        "  ACTION REQUIRED: A SERVICE PRINCIPAL IS MISSING IN THIS TENANT"
        ""
        "  Application : $DisplayName"
        "  App ID      : $AppId"
        "  Needed by   : $($RequiredBy -join ', ')"
        ""
        "  Y = Create the service principal now. You are asked to sign in again"
        "      to grant one extra permission: $CreateScope"
        "  N = Do not create it. $($RequiredBy -join ', ') will be skipped."
        ""
        "  The deployment is paused until you answer."
        ""
    )

    try { [console]::Beep() } catch { }

    Write-Host ""
    Write-Host ""
    foreach ($Line in $Lines)
    {
        Write-Host $Line.PadRight($Width) -ForegroundColor White -BackgroundColor DarkRed
    }
    Write-Host ""

    do
    {
        $Answer = "$(Read-Host -Prompt ">>> Create '$DisplayName' now? (Y/N)")".Trim()
    }
    while ($Answer -notmatch '^(y|yes|n|no)$')

    Write-Host ""
    return ($Answer -match '^y')
}

$AllPrincipals = Get-ChildItem -Path $principalsDir -Recurse -File | Where-Object { $_.Name -like "*.psd1" } | Sort-Object Name

if ($AllPrincipals.Count -eq 0)
{
    Write-Output "No service principals found in $principalsDir"
    return
}

foreach ($Principal in $AllPrincipals)
{
    $params = Import-PowerShellDataFile -Path $Principal.FullName

    # ---- Validation ------------------------------------------------------
    $parsedAppId = [guid]::Empty
    if ([string]::IsNullOrWhiteSpace($params.AppId) -or -not [guid]::TryParse($params.AppId, [ref]$parsedAppId))
    {
        Add-DeploymentResult -Type $ResultType -Name $Principal.Name -Action "Skipped" -Reason "Invalid definition: AppId must be a GUID"
        continue
    }
    if ([string]::IsNullOrWhiteSpace($params.DisplayName))
    {
        Add-DeploymentResult -Type $ResultType -Name $Principal.Name -Action "Skipped" -Reason "Invalid definition: DisplayName is required"
        continue
    }

    $AppId      = $params.AppId
    $RequiredBy = @($params.RequiredBy)
    $ResultName = "$($params.DisplayName) ($AppId)"

    # ---- Only relevant when a policy that needs it is being deployed -----
    # $script:PolicyFilter is set by main_script.ps1 in Core mode and is $null in Advanced mode.
    if ($script:PolicyFilter -and -not ($RequiredBy | Where-Object { $_ -in $script:PolicyFilter }))
    {
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Skipped" -Reason "Not needed by the policies in this mode"
        continue
    }

    # ---- Lookup existing by AppId (the matching key) ---------------------
    $lookupUri = "$graphBaseUri`?`$filter=appId eq '$AppId'&`$select=id,appId,displayName"

    try
    {
        $existing = Invoke-MgGraphRequest -Method GET -Uri $lookupUri -ErrorAction Stop
    }
    catch
    {
        # The policies are left to run as normal; Microsoft Graph reports the outcome for each of them.
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Failed" -Reason "Could not check for an existing service principal: $($_.Exception.Message)"
        continue
    }

    if (($existing.value | Select-Object -First 1).id)
    {
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Skipped" -Reason "Already exists; left unchanged"
        continue
    }

    # ---- Missing: stop and ask -------------------------------------------
    $CreateIt = Show-MissingServicePrincipalPrompt -DisplayName $params.DisplayName -AppId $AppId -RequiredBy $RequiredBy

    if (-not $CreateIt)
    {
        Add-UnavailableApplication -AppId $AppId -Reason "Service principal '$($params.DisplayName)' does not exist in this tenant and you chose not to create it"
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Skipped" -Reason "Does not exist; you chose not to create it. Skipped policies: $($RequiredBy -join ', ')"
        continue
    }

    # ---- Sign in again with the extra permission -------------------------
    $TenantBefore = (Get-MgContext -ErrorAction SilentlyContinue).TenantId
    $BaseScopes   = if ($RequireScopes) { @($RequireScopes) } else { @("Application.Read.All") }
    $ConnectError = $null

    try
    {
        Connect-MgGraph -Scopes ($BaseScopes + $CreateScope) -ErrorAction Stop
    }
    catch
    {
        $ConnectError = $_.Exception.Message
    }

    # The second sign-in must land in the same tenant. If it does not, nothing further may run.
    $TenantAfter = (Get-MgContext -ErrorAction SilentlyContinue).TenantId
    if (-not $TenantAfter -or $TenantAfter -ne $TenantBefore)
    {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
        throw "Deployment stopped: after the second sign-in the session is no longer connected to the original tenant ($TenantBefore). No further changes were made. Run the deployment again."
    }

    if ($ConnectError)
    {
        Add-UnavailableApplication -AppId $AppId -Reason "Service principal '$($params.DisplayName)' does not exist in this tenant and the sign-in to create it did not complete"
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Failed" -Reason "Sign-in for $CreateScope did not complete: $ConnectError"
        continue
    }

    # ---- Create ----------------------------------------------------------
    try
    {
        Invoke-MgGraphRequest -Method POST -Uri $graphBaseUri -Body (@{ appId = $AppId } | ConvertTo-Json) -ContentType 'application/json' -ErrorAction Stop | Out-Null
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Created" -Reason "Did not exist; created on request"
    }
    catch
    {
        Add-UnavailableApplication -AppId $AppId -Reason "Service principal '$($params.DisplayName)' does not exist in this tenant and could not be created"
        Add-DeploymentResult -Type $ResultType -Name $ResultName -Action "Failed" -Reason "Create failed: $($_.Exception.Message) (the account needs the Application Administrator, Cloud Application Administrator or Global Administrator role)"
    }
}
