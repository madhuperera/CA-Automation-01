# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

# Shared deployment helpers (create / update / skip rules and run report)
. (Join-Path $PSScriptRoot "..\..\..\scripts\deployment_helpers.ps1")

$PolicyID = "CA004"
$DisplayName = "$PolicyID-AllApps:Block-For:Global-When:DeviceCodeAuthTransfer"
$State = "enabledForReportingButNotEnforced"
$ExcludedGroups = 
@(
    "EID-SEC-U-A-CAP-$PolicyID-Exclude"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
)
$TransferMethods = "authenticationTransfer"


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
                        includeApplications = "All"
                }
                authenticationFlows = 
                @{
                    transferMethods = $TransferMethods
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
                builtInControls = "block"
        }
}


# Create, update or skip the policy (see scripts/deployment_helpers.ps1 for the rules)
Deploy-CAPolicy -DisplayName $DisplayName -Params $params
