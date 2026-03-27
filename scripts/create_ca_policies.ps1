# Connect-MgGraph -Scopes 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All'

$ThrottleDelayMilliseconds = 100

$scriptDir = $PSScriptRoot
$CAPolicyFolder = Join-Path -Path $scriptDir -ChildPath "..\data\ca_policies"

$AllCAPolicies = Get-ChildItem -Path $CAPolicyFolder -Recurse -File -Include "*.ps1" | Select-Object -ExpandProperty FullName

if ($script:PolicyFilter) {
    $AllCAPolicies = $AllCAPolicies | Where-Object { (Split-Path (Split-Path $_ -Parent) -Leaf) -in $script:PolicyFilter }
}

$TotalCount = $AllCAPolicies.Count
$CurrentCount = 0

foreach ($Policy in $AllCAPolicies)
{
    $CurrentCount++
    Write-Progress -Activity "Processing Conditional Access Policies" `
                   -Status "Processing $CurrentCount of $TotalCount" `
                   -PercentComplete (($CurrentCount / $TotalCount) * 100)

    & $Policy -ErrorAction Stop
    Start-Sleep -Milliseconds $ThrottleDelayMilliseconds
}