# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

# Core Variables
$PolicyID = "CA301"
$DisplayName = "$PolicyID-AllApps:Block-For:B2BCollaborationGuests-When:OutsideOfTrustedCountries"
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
$IncludedGuestTypes = "b2bCollaborationGuest"

# Applications
$ClientAppTypes = "all"
$IncludedApplications = "All"

# Locations
$ExludedLocations = 
@(
    "CL002-CN-A-AllApps-B2BCollaborationGuests-TrustedCountries"
)
$IncludedLocations = "All"
$ExcludedLocationIds = @()
foreach ($location in $ExludedLocations)
{
    $locationId = Get-MgGroup -Filter "displayName eq '$location'" | Select-Object -ExpandProperty Id
    if ($locationId -ne $null)
    {
        $ExcludedLocationIds += $locationId
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
