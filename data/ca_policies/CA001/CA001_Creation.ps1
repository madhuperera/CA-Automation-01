# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess'

$PolicyID = "CA001"
$DisplayName = "$PolicyID-AllApps:Block-For:AllUsers-When:UnknownLocations&Algeria"
$State = "enabledForReportingButNotEnforced"
$IncludedLocations = @("CL001-CN-B-M365Apps-AllUsers-UnknownLocations&Algeria")
$ExcludedGroups = 
@(
    "EID-SEC-U-A-CAP-$PolicyID-Exclude"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
)

$LocationIds = @()
$ExcludedGroupIds = @()

foreach ($location in $IncludedLocations)
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
                }
                locations = 
                @{
                        includeLocations = $LocationIds
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
