# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

# Shared deployment helpers (create / update / skip rules and run report)
. (Join-Path $PSScriptRoot "..\..\..\scripts\deployment_helpers.ps1")

# Core Variables
$PolicyID = "CA302"
$DisplayName = "$PolicyID-AllApps:RequireMFA-For:B2BCollaborationGuests-When:AnyNetwork"
$State = "enabledForReportingButNotEnforced"
$ExcludedGroups = 
@(
    "EID-SEC-U-A-CAP-$PolicyID-Exclude"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
)

# User Persona: Guests
$GuestMembershipKind = "all"
$IncludedGuestTypes = "b2bCollaborationGuest"

# Applications
$ClientAppTypes = "all"
$IncludedApplications = "All"

# Locations
$IncludedLocations = "All"
$ExcludedLocations = @("CL002-CN-A-AllApps-B2BCollaborationGuests-TrustedCountries")
$ExcludedLocationIds = @()
foreach ($location in $ExcludedLocations)
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
$BuiltInControls = "mfa"

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
                }
                locations = 
                @{
                        includeLocations = $IncludedLocations
                        excludeLocations = $ExcludedLocationIds
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
