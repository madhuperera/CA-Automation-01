# Shared helpers for the CA-Automation-01 deployment scripts.
#
#   Add-DeploymentResult  Records what happened to one object: Created, Updated, Skipped or Failed.
#   Deploy-CAPolicy       Creates, updates or skips one Conditional Access policy.
#
# Re-run rules for Conditional Access policies:
#   Policy does not exist in the tenant        -> Create from the repo definition
#   Policy exists and is in report-only mode   -> Update from the repo definition
#   Policy exists and is switched on or off    -> Skip. The policy is never modified.

function Add-DeploymentResult
{
    param(
        [string]$Type,
        [string]$Name,
        [ValidateSet("Created","Updated","Skipped","Failed")]
        [string]$Action,
        [string]$Reason
    )

    $Result = [pscustomobject]@{
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Type      = $Type
        Name      = $Name
        Action    = $Action
        Reason    = $Reason
    }

    # $DeploymentResults is created by main_script.ps1 and collects the results for the end-of-run report.
    # When a script is run on its own the list does not exist, so the result is only shown on screen.
    if ($DeploymentResults -is [System.Collections.IList])
    {
        [void]$DeploymentResults.Add($Result)
    }

    $Colour = switch ($Action)
    {
        "Created" { "Green" }
        "Updated" { "Cyan" }
        "Skipped" { "Yellow" }
        "Failed"  { "Red" }
    }

    $Message = "{0,-8} {1}: {2}" -f $Action.ToUpper(), $Type, $Name
    if ($Reason)
    {
        $Message = "$Message ($Reason)"
    }
    Write-Host $Message -ForegroundColor $Colour
}

function Deploy-CAPolicy
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,

        [Parameter(Mandatory = $true)]
        [hashtable]$Params
    )

    $Type            = "Conditional Access Policy"
    $ReportOnlyState = "enabledForReportingButNotEnforced"

    # ---- Look for an existing policy with the same display name ----------
    # A failed lookup must never be treated as "policy does not exist",
    # otherwise a duplicate policy would be created.
    try
    {
        $Existing = @(Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq '$DisplayName'" -ErrorAction Stop)
    }
    catch
    {
        Add-DeploymentResult -Type $Type -Name $DisplayName -Action "Failed" -Reason "Could not check for an existing policy: $($_.Exception.Message)"
        return
    }

    if ($Existing.Count -gt 1)
    {
        Add-DeploymentResult -Type $Type -Name $DisplayName -Action "Skipped" -Reason "$($Existing.Count) policies with this name exist in the tenant; none were changed"
        return
    }

    # ---- Create ----------------------------------------------------------
    if ($Existing.Count -eq 0)
    {
        try
        {
            New-MgIdentityConditionalAccessPolicy -BodyParameter $Params -ErrorAction Stop | Out-Null
            Add-DeploymentResult -Type $Type -Name $DisplayName -Action "Created" -Reason "Policy did not exist"
        }
        catch
        {
            Add-DeploymentResult -Type $Type -Name $DisplayName -Action "Failed" -Reason "Create failed: $($_.Exception.Message)"
        }
        return
    }

    # ---- Skip policies that are switched on or off -----------------------
    $CurrentState = "$($Existing[0].State)"

    if ($CurrentState -ne $ReportOnlyState)
    {
        Add-DeploymentResult -Type $Type -Name $DisplayName -Action "Skipped" -Reason "Existing policy state is '$CurrentState'; only report-only policies are updated"
        return
    }

    # ---- Update policies that are in report-only mode --------------------
    try
    {
        Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $Existing[0].Id -BodyParameter $Params -ErrorAction Stop
        Add-DeploymentResult -Type $Type -Name $DisplayName -Action "Updated" -Reason "Existing policy was in report-only mode"
    }
    catch
    {
        Add-DeploymentResult -Type $Type -Name $DisplayName -Action "Failed" -Reason "Update failed: $($_.Exception.Message)"
    }
}
