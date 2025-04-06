# Connect-MgGraph -Scopes 'Group.ReadWrite.All'

$GroupNamePrefix = "EID-SEC-U-A-CAP-"

$scriptDir = $PSScriptRoot
$CAPolicyFolder = Join-Path -Path $scriptDir -ChildPath "..\data\ca_policies"

$AllCAPolicies = Get-ChildItem -Path $CAPolicyFolder -Directory | Select-Object -ExpandProperty Name

if ($AllCAPolicies.Count -eq 0)
{
    Write-Output "No CA Policies found in $CAPolicyFolder"
    return
}

$TotalCount = $AllCAPolicies.Count
$CurrentCount = 0

foreach ($Policy in $AllCAPolicies)
{
    $CurrentCount++
    Write-Progress -Activity "Processing Known Locations" `
                   -Status "Processing $CurrentCount of $TotalCount" `
                   -PercentComplete (($CurrentCount / $TotalCount) * 100)

    $GroupName = $GroupNamePrefix + $Policy + "-Exclude"

    if (Get-MgGroup -Filter "displayName eq '$($GroupName)'" -ErrorAction SilentlyContinue)
    {
        Write-Output "Group $GroupName already exists. Skipping ...."
    }
    else
    {
        Write-Output "Creating group $GroupName ...."
        New-MgGroup -BodyParameter @{
            DisplayName = $GroupName
            Description = "Managed Policy exclusions for $Policy"
            MailEnabled = $false
            MailNickname = $Policy
            SecurityEnabled = $true
        } -ErrorAction Stop | Out-Null
    }
}

