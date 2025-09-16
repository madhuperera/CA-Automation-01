# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

$PolicyID = "CA200"
$DisplayName = "$PolicyID-O365:RequireAppProtectionPolicy-For:AllUsers-When:OnMobileDevices"
$State = "enabledForReportingButNotEnforced"
$ExcludedGroups = 
@(
    "EID-SEC-U-A-CAP-$PolicyID-Exclude"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
)
$IncludedApplications = "Office365"
$IncludedPlatforms = 
@(
    "android",
    "iOS"
)
$ExcludedGuestTypes = "internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider"

$ExcludedGroupIds = @()

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
                        includeApplications = $IncludedApplications
                }
                platforms =
                @{
                    includePlatforms = $IncludedPlatforms
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
                }
        }
        grantControls = 
        @{
                operator = "OR"
                builtInControls = "compliantApplication"
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
