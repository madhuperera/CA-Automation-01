# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

$PolicyID = "CA002"
$DisplayName = "$PolicyID-AzureManagement:RequireMFA-For:Global-When:AnyNetwork"
$State = "enabledForReportingButNotEnforced"
$IncludedApplications = @("797f4846-ba00-4fd7-ba43-dac1f8f63013") # Azure Management (Microsoft)
$AuthStrenthId = "00000000-0000-0000-0000-000000000002" # Multifactor authentication (Built-In)
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
                users = 
                @{
                        includeUsers = "All"
                        excludeGroups = $ExcludedGroupIds
                }
        }
        grantControls = 
        @{
                operator = "OR"
                authenticationStrength = 
                @{
                    id = $AuthStrenthId
                }
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
