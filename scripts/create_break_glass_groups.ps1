# Connect-MgGraph -Scopes 'Group.ReadWrite.All'

$EBGGroups = 
@(
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
)

foreach ($group in $EBGGroups)
{
    if (Get-MgGroup -Filter "displayName eq '$group'" -ErrorAction SilentlyContinue)
    {
        Write-Output "Group $group already exists. Skipping ...."
    }
    else
    {
        Write-Output "Creating group $group ...."
        New-MgGroup -BodyParameter @{
            DisplayName = $group
            Description = "Break Glass Group for Conditional Access Policy Management"
            MailEnabled = $false
            MailNickname = $group
            SecurityEnabled = $true
        } -ErrorAction Stop
    }
}

