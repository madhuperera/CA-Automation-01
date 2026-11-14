# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

# Shared deployment helpers (create / update / skip rules and run report)
. (Join-Path $PSScriptRoot "..\..\..\scripts\deployment_helpers.ps1")

# Core Variables
$PolicyID = "CA305"
$DisplayName = "$PolicyID-AdminPortals:RequireCompliant-For:ServiceProviderUsers-When:AnyNetwork"
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

# User Persona: CSP Guests
$GuestMembershipKind = "all"
$IncludedGuestTypes = "serviceProvider"

# Applications
$ClientAppTypes = "all"
$IncludedApplications = "MicrosoftAdminPortals"

# Locations


# Devices


# Grant Controls
$Operator = "OR"
$BuiltInControls = 
@(
    "compliantDevice"
    "domainJoinedDevice"
)
            

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
                        includeGuestsOrExternalUsers = 
                        @{
                            externalTenants =
                            @{
                                membershipKind = $GuestMembershipKind
                            }
                            guestOrExternalUserTypes = $IncludedGuestTypes
                        }
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
