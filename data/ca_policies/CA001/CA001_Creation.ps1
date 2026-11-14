# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess'

# Shared deployment helpers (create / update / skip rules and run report)
. (Join-Path $PSScriptRoot "..\..\..\scripts\deployment_helpers.ps1")

# Core Variables
$PolicyID = "CA001"
$DisplayName = "$PolicyID-AllApps:Block-For:Global-When:UnknownLocations&BouvetIsland"
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
$IncludedLocations = @("CL001-CN-B-M365Apps-AllUsers-UnknownLocations&BouvetIsland")
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

# Create, update or skip the policy (see scripts/deployment_helpers.ps1 for the rules)
Deploy-CAPolicy -DisplayName $DisplayName -Params $params
