# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess'

$PolicyID = "CA006"
$DisplayName = "$PolicyID-AllApps:Block-For:AllUsers-When:OutsideOfTrustedCountries"
$State = "enabledForReportingButNotEnforced"
$ExcludedLocations = @("CL004-CN-A-AllApps-InternalUsers-TrustedCountries")
$ExcludedGroups = 
@(
    "EID-SEC-U-A-CAP-$PolicyID-Exclude"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
)
$ExcludedGuestTypes = "internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider"
$ExcludedRoles =
@(
    "62e90394-69f5-4237-9190-012177145e10"
)

$LocationIds = @()
$ExcludedGroupIds = @()

foreach ($location in $ExcludedLocations)
{
    $locationId = Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$location'" | Select-Object -ExpandProperty Id
    if ($locationId -ne $null)
    {
        $LocationIds += $locationId
    }
}

foreach ($group in $ExcludedGroups)
{
    $groupId = Get-MgGroup -Filter "displayName eq '$group'" | Select-Object -ExpandProperty Id
    if ($groupId -ne $null)
    {
        $ExcludedGroupIds += $groupId
    }
}


$params = 
@{
	displayName = $DisplayName
	state = $State
	conditions = 
        @{
                clientAppTypes = "all"
                applications = 
                @{
                        includeApplications = "All"
                }
                users = 
                @{
                        includeUsers = "All"
                        excludeGroups = $ExcludedGroupIds
                        excludeGuestsOrExternalUsers =
                        @{
                            externalTenants = 
                            @{
                                membershipKind = "all"
                            }
                            guestOrExternalUserTypes = $ExcludedGuestTypes
                        }
                        excludeRoles = $ExcludedRoles
                }
                locations = 
                @{
                        includeLocations = "All"
                        excludeLocations = $LocationIds
                }
        }
        grantControls = 
        @{
                operator = "OR"
                builtInControls = "block"
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
