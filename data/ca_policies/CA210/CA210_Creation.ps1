# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

# Check for Entra ID P2 license
$skus = Get-MgSubscribedSku
$p2Skus = 
@(
    "AAD_PREMIUM_P2",
    "EMS_PREMIUM_P2",
    "ENTERPRISEPREMIUM",
    "M365EDU_A5_FACULTY",
    "M365EDU_A5_STUDENT"
)
$hasP2 = $skus | Where-Object { $p2Skus -contains $_.SkuPartNumber -and $_.PrepaidUnits.Enabled -gt 0 }

if (-not $hasP2) 
{
    Write-Warning "Tenant does NOT have Entra ID P2 license. Risk-based conditional access policies are not supported."
    exit
}

Write-Output "Tenant has Entra ID P2 capabilities. Proceeding with policy creation."

# Core Variables
$PolicyID = "CA210"
$DisplayName = "$PolicyID-AllApps:RequireMFA-For:Internals-When:RiskySignIn:Low"
$State = "enabledForReportingButNotEnforced"
$ExcludedGroups = 
@(
    "EID-SEC-U-A-CAP-$PolicyID-Exclude"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
)

# User Persona: Internals
$IncludedUsers = "All"
$GuestMembershipKind = "all"
$ExcludedGuestTypes = "internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider"
$ExcludedRoles = 
@(
    "62e90394-69f5-4237-9190-012177145e10"
    "f2ef992c-3afb-46b9-b7cf-a126ee74c451"
    "194ae4cb-b126-40b2-bd5b-6091b380977d"
    "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
    "29232cdf-9323-42fd-ade2-1d097af3e4de"
    "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9"
    "729827e3-9c14-49f7-bb1b-9608f156bbb8"
    "b0f54661-2d74-4c50-afa3-1ec803f12efe"
    "fe930be7-5e62-47db-91af-98c3a49a38b1"
    "c4e39bd9-1100-46d3-8c65-fb160da0071f"
    "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3"
    "158c047a-c907-4556-b7ef-446551a6b5f7"
    "966707d0-3269-4727-9be2-8c3a10f19b9d"
    "7be44c8a-adaf-4e2a-84d6-ab2649e08a13"
    "e8611ab8-c189-46e8-94e1-60213ab1f814"
    "f2ef992c-3afb-46b9-b7cf-a126ee74c451"
)

# Applications
$ClientAppTypes = "all"
$IncludedApplications = "All"

# Risky Sign-In Conditions
$SignInRiskLevels = @("low")

# Locations


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
                        includeUsers = $IncludedUsers
                        excludeGroups = $ExcludedGroupIds
                        excludeGuestsOrExternalUsers = 
                        @{
                            externalTenants =
                            @{
                                membershipKind = $GuestMembershipKind
                            }
                            guestOrExternalUserTypes = $ExcludedGuestTypes
                        }
                        excludeRoles = $ExcludedRoles
                }
                signInRiskLevels = $SignInRiskLevels   
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
