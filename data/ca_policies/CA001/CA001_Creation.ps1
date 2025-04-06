# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess'

# Core Variables
$PolicyID = "CA001"
$DisplayName = "$PolicyID-AllApps:Block-For:AllUsers-When:UnknownLocations&Algeria"
$State = "enabledForReportingButNotEnforced"
$ExcludedGroups = 
@(
    "EID-SEC-U-A-CAP-$PolicyID-Exclude"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
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

# User Persona: All Users
$IncludedUsers = "All"


# Applications
$ClientAppTypes = "all"
$IncludedApplications = "All"


# Locations
$IncludedLocations = @("CL001-CN-B-M365Apps-AllUsers-UnknownLocations&Algeria")
$LocationIds = @()
foreach ($location in $IncludedLocations)
{
    $locationId = Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$location'" | Select-Object -ExpandProperty Id
    if ($locationId -ne $null)
    {
        $LocationIds += $locationId
    }
}


# Devices


# Grant Controls
$Operator = "OR"
$BuiltInControls = "block"
            

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
                        includeUsers = $IncludedUsers
                        excludeGroups = $ExcludedGroupIds
                }
                locations = 
                @{
                        includeLocations = $LocationIds
                }
        }
        grantControls = 
        @{
            operator = $Operator
            builtInControls = $BuiltInControls
        }
}

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
