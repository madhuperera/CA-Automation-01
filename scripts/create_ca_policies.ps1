# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

$scriptDir = $PSScriptRoot
$CAPolicyFolder = Join-Path -Path $scriptDir -ChildPath "..\data\ca_policies"

$AllCAPolicies = Get-ChildItem -Path $CAPolicyFolder -Recurse -File -Include "*.ps1" | Select-Object -ExpandProperty FullName
$TotalCount = $AllCAPolicies.Count
$CurrentCount = 0

foreach ($Policy in $AllCAPolicies)
{
    $CurrentCount++
    Write-Progress -Activity "Processing Conditional Access Policies" `
                   -Status "Processing $CurrentCount of $TotalCount" `
                   -PercentComplete (($CurrentCount / $TotalCount) * 100)

    & $Policy -ErrorAction Stop
}