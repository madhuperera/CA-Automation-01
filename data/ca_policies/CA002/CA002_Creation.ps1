# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

# Shared deployment helpers (create / update / skip rules and run report)
. (Join-Path $PSScriptRoot "..\..\..\scripts\deployment_helpers.ps1")

# Core Variables
$PolicyID = "CA002"
$DisplayName = "$PolicyID-AzureManagement:RequireMFA-For:Global-When:AnyNetwork"
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

# User Persona: Global
$IncludedUsers = "All"


# Applications
$ClientAppTypes = "all"
$IncludedApplications = @("797f4846-ba00-4fd7-ba43-dac1f8f63013") # Azure Management (Microsoft)


# Locations


# Devices


# Grant Controls
$Operator = "OR"
$AuthStrenthId = "00000000-0000-0000-0000-000000000002" # Multifactor authentication (Built-In)
            

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
        }
        grantControls = 
        @{
                operator = $Operator
                authenticationStrength = 
                @{
                    id = $AuthStrenthId
                }
        }
}

# Create, update or skip the policy (see scripts/deployment_helpers.ps1 for the rules)
Deploy-CAPolicy -DisplayName $DisplayName -Params $params
