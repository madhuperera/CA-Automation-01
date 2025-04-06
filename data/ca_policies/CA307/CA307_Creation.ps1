# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

# Core Variables
$PolicyID = "CA307"
$DisplayName = "$PolicyID-AllApps:Block-For:AllGuests-When:LegacyProtocols"
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

# User Persona: Guests
$GuestMembershipKind = "all"
$IncludedGuestTypes = "internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider"

# Applications
$ClientAppTypes = 
@(
    "exchangeActiveSync"
    "other"
)
$IncludedApplications = "All"

# Locations


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
