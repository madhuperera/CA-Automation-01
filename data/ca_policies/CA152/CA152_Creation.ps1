# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

# Core Variables
$PolicyID = "CA152"
$DisplayName = "$PolicyID-AllApps:AuthStrength-For:EmergencyBreakGlassAccount2-When:AnyNetwork"
$State = "enabledForReportingButNotEnforced"
$ExcludedGroups = 
@(
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
)
$ExcludedGroupIds = @()
foreach ($group in $ExcludedGroups)
{
    $groupId = Get-MgGroup -Filter "displayName eq '$group'" | Select-Object -ExpandProperty Id
    if ($groupId -ne $null)
    {
        $ExcludedGroupIds += $groupId
    }
}

# User Persona: EmergencyBreakGlassAccount1
$IncludedGroups = "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
$IncludedGroupIds = @()
foreach ($group in $IncludedGroups)
{
    $groupId = Get-MgGroup -Filter "displayName eq '$group'" | Select-Object -ExpandProperty Id
    if ($groupId -ne $null)
    {
        $IncludedGroupIds += $groupId
    }
}

# Applications
$ClientAppTypes = "all"
$IncludedApplications = "All"

# Locations


# Devices


# Grant Controls
$Operator = "OR"
$AuthStrengthDefinition = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot "..\..\auth_strengths\AS02.psd1")
$AuthStrengthName = $AuthStrengthDefinition.DisplayName
$FallbackAuthStrengthId = "00000000-0000-0000-0000-000000000004"  # Built-in: Phishing-resistant MFA

$AuthStrengthId    = $null
$RetryTimeoutSecs  = 120
$RetryIntervalSecs = 10
$Stopwatch         = [System.Diagnostics.Stopwatch]::StartNew()

while ($Stopwatch.Elapsed.TotalSeconds -lt $RetryTimeoutSecs)
{
    $AuthStrengthId = Get-MgPolicyAuthenticationStrengthPolicy -Filter "displayName eq '$AuthStrengthName'" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id
    if ($AuthStrengthId)
    {
        Write-Host "Authentication Strength '$AuthStrengthName' resolved to $AuthStrengthId."
        break
    }
    Write-Host "Authentication Strength '$AuthStrengthName' not yet available. Retrying in $RetryIntervalSecs seconds... ($([int]$Stopwatch.Elapsed.TotalSeconds)s elapsed)"
    Start-Sleep -Seconds $RetryIntervalSecs
}
$Stopwatch.Stop()

if (-not $AuthStrengthId)
{
    Write-Warning "Authentication Strength '$AuthStrengthName' not found after $RetryTimeoutSecs seconds. Falling back to built-in Phishing-resistant MFA ($FallbackAuthStrengthId)."
    $AuthStrengthId = $FallbackAuthStrengthId
}

# Session Contols


# Setting up the policy parameters
$params = 
@{
	displayName = $DisplayName
	state = $State
	conditions = 
        @{
                clientAppTypes = $ClientAppTypes
                applications =
                @{
                        includeApplications = $IncludedApplications
                }
                users = 
                @{
                        excludeGroups = $ExcludedGroupIds
                        includeGroups = $IncludedGroupIds
                }
        }
        grantControls = 
        @{
                operator = $Operator
                authenticationStrength =
                @{
                    id = $AuthStrengthId
                }
        }
    }

# Creating the policy
$CAPolicyID = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq '$DisplayName'" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id

if ($CAPolicyID)
{
    Write-Host "Updating existing policy with ID: $CAPolicyID"
    Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $CAPolicyID -BodyParameter $params
    $CAPolicyID = $null
}
else
{
    Write-Host "Creating new policy with display name: $DisplayName"
    New-MgIdentityConditionalAccessPolicy -BodyParameter $params
}
