# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

# Shared deployment helpers (create / update / skip rules and run report)
. (Join-Path $PSScriptRoot "..\..\..\scripts\deployment_helpers.ps1")

# Core Variables
$PolicyID = "CA300"
$DisplayName = "$PolicyID-AllApps:Block-For:UnallowedGuestTypes-When:AnyNetwork"
$State = "enabledForReportingButNotEnforced"
$ExcludedGroups = 
@(
    "EID-SEC-U-A-CAP-$PolicyID-Exclude"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
)

# User Persona: Guests
$GuestMembershipKind = "all"
$IncludedGuestTypes = "internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider"
$ExcludedGuestTypes = "b2bCollaborationGuest,serviceProvider"

# Applications
$ClientAppTypes = "all"
$IncludedApplications = "All"

# Locations


# Devices


# Grant Controls
$Operator = "OR"
$BuiltInControls = "block"

# Session Contols


# Generating missing IDs
$ExcludedGroupIds = @()

foreach ($group in $ExcludedGroups)
{
    $groupId = Get-MgGroup -Filter "displayName eq '$group'" | Select-Object -ExpandProperty Id
    if ($groupId -ne $null)
    {
        $ExcludedGroupIds += $groupId
    }
}



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
                        excludeGuestsOrExternalUsers = 
                        @{
                            externalTenants =
                            @{
                                membershipKind = $GuestMembershipKind
                            }
                            guestOrExternalUserTypes = $ExcludedGuestTypes
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
