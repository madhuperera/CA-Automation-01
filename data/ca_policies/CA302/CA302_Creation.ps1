# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

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
$AuthStrengthId = "00000000-0000-0000-0000-000000000002"

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
