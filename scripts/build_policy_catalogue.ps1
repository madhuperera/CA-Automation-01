<#
.SYNOPSIS
    Builds the browsable policy catalogue (docs/index.html) from the policy scripts in this repository.

.DESCRIPTION
    Runs every data/ca_policies/CA###/CA###_Creation.ps1 with the Microsoft Graph commands replaced by
    local stand-ins, captures the policy definition each script would send, and writes one self-contained
    HTML page.

    This script never connects to a tenant and never creates or changes anything in Microsoft Entra ID.
    A policy script that uses a Microsoft Graph command this script has no stand-in for is not run;
    it is listed on the page with an error instead.

    Re-run this script whenever a policy, named location, authentication strength or authentication
    context is added or changed, and commit the regenerated docs/index.html.

.EXAMPLE
    ./build_policy_catalogue.ps1
#>
param(
    # Where the page is written. Defaults to docs/index.html in the repository.
    [string]$OutputPath = (Join-Path $PSScriptRoot "..\docs\index.html"),

    # Used for the links to each policy's ReadMe and script.
    [string]$RepositoryUrl = "https://github.com/madhuperera/CA-Automation-01"
)

$ErrorActionPreference = "Stop"
$repoRoot     = Join-Path $PSScriptRoot ".."
$policiesDir  = Join-Path $repoRoot "data\ca_policies"
$templatePath = Join-Path $PSScriptRoot "policy_catalogue_template.html"

# ---- Stand-ins for Microsoft Graph commands ------------------------------------------------
# Functions take precedence over module commands, so the policy scripts call these instead of
# the real ones. Lookups return a readable placeholder ("group:<name>") in place of an object id.

function Get-NameFromFilter
{
    param([string]$Filter)
    return ($Filter -replace "^.*?'(.*)'.*$", '$1')
}

function Get-MgGroup
{
    param($Filter)
    [pscustomobject]@{ Id = "group:" + (Get-NameFromFilter $Filter) }
}

function Get-MgIdentityConditionalAccessNamedLocation
{
    param($Filter)
    [pscustomobject]@{ Id = "location:" + (Get-NameFromFilter $Filter) }
}

function Get-MgPolicyAuthenticationStrengthPolicy
{
    param($Filter)
    [pscustomobject]@{ Id = "strength:" + (Get-NameFromFilter $Filter) }
}

function Get-MgSubscribedSku
{
    # Reports an Entra ID P2 licence so the risk-based policy scripts run through to their definition.
    [pscustomobject]@{
        CapabilityStatus = "Enabled"
        PrepaidUnits     = @{ Enabled = 1 }
        ServicePlans     = @(@{ ServicePlanName = "AAD_PREMIUM_P2" })
    }
}

function Get-MgIdentityConditionalAccessPolicy { }      # "no existing policy", so the script takes the create path
function Update-MgIdentityConditionalAccessPolicy { }
function New-MgIdentityConditionalAccessPolicy
{
    param($BodyParameter)
    # $CatalogueCapture is created per policy further down and found here through the scope chain.
    $CatalogueCapture.Definition = $BodyParameter
}

$StubbedCommands = @(
    "Get-MgGroup"
    "Get-MgIdentityConditionalAccessNamedLocation"
    "Get-MgPolicyAuthenticationStrengthPolicy"
    "Get-MgSubscribedSku"
    "Get-MgIdentityConditionalAccessPolicy"
    "Update-MgIdentityConditionalAccessPolicy"
    "New-MgIdentityConditionalAccessPolicy"
)

# ---- Helpers -------------------------------------------------------------------------------

function Get-ScriptCommandNames
{
    # Names of all commands a script calls, read from its syntax tree without running it.
    param([string]$Path)
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$parseErrors)
    if ($parseErrors.Count -gt 0)
    {
        throw "Script has $($parseErrors.Count) syntax error(s)"
    }
    $ast.FindAll({ param($node) $node -is [System.Management.Automation.Language.CommandAst] }, $true) |
        ForEach-Object { $_.GetCommandName() } |
        Where-Object { $_ } |
        Sort-Object -Unique
}

function ConvertTo-SortedData
{
    # Hashtables do not keep a stable key order between runs. Sorting the keys keeps the
    # generated page identical when nothing has changed.
    param($Value)
    if ($Value -is [System.Collections.IDictionary])
    {
        $sorted = [ordered]@{}
        foreach ($key in ($Value.Keys | Sort-Object))
        {
            $sorted["$key"] = ConvertTo-SortedData -Value $Value[$key]
        }
        return $sorted
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string])
    {
        $items = @(foreach ($item in $Value) { ConvertTo-SortedData -Value $item })
        return , $items
    }
    return $Value
}

function Get-PolicyCategory
{
    # Follows the policy numbering model in README.md.
    param([string]$PolicyId)
    $number = [int]($PolicyId -replace "\D", "")
    if ($number -lt 100) { return "Global" }
    if ($number -lt 150) { return "Admins" }
    if ($number -lt 200) { return "Break-glass" }
    if ($number -lt 300) { return "Internals" }
    if ($number -lt 400) { return "Guests & External" }
    if ($number -ge 800 -and $number -lt 900) { return "Custom" }
    return "Other"
}

function Get-ReadMeDetails
{
    # Title from the first heading, and the first paragraph under "Business Objective" when present.
    param([string]$Path, [string]$PolicyId)
    $details = @{ Title = ""; Objective = "" }
    if (-not (Test-Path -LiteralPath $Path)) { return $details }

    $lines = @(Get-Content -LiteralPath $Path)
    $heading = $lines | Where-Object { $_ -match "^#\s+" } | Select-Object -First 1
    if ($heading)
    {
        $details.Title = ($heading -replace "^#\s+", "" -replace "^$PolicyId\s*[-:]\s*", "").Trim()
    }

    $inObjective = $false
    $paragraph = @()
    foreach ($line in $lines)
    {
        if ($line -match "^##\s+Business Objective")
        {
            $inObjective = $true
            continue
        }
        if (-not $inObjective) { continue }
        if ($line -match "^(#|---)") { break }
        if ([string]::IsNullOrWhiteSpace($line))
        {
            if ($paragraph.Count -gt 0) { break }
            continue
        }
        $paragraph += $line.Trim()
    }
    # The page style avoids em and en dashes, so they are rewritten in the text taken from the ReadMe.
    $emDash = [string][char]0x2014
    $enDash = [string][char]0x2013
    $details.Objective = (($paragraph -join " ") -replace "\s*$emDash\s*", "; " -replace "\s*$enDash\s*", " to ")
    $details.Title = ($details.Title -replace "\s*$emDash\s*", ", " -replace "\s*$enDash\s*", " to ")
    return $details
}

function ConvertTo-CompactJson
{
    param($Value)
    # "<" is escaped so the data can be embedded safely inside the HTML page.
    return ($Value | ConvertTo-Json -Depth 20 -Compress).Replace("<", "<")
}

function Get-DataFiles
{
    param([string]$Folder)
    Get-ChildItem -Path (Join-Path $repoRoot $Folder) -Filter "*.psd1" | Sort-Object Name
}

# ---- Policies ------------------------------------------------------------------------------

$tiers = Import-PowerShellDataFile (Join-Path $repoRoot "data\policy_tiers.psd1")
$policyFolders = Get-ChildItem -Path $policiesDir -Directory | Sort-Object Name

$policyJson = @()
$errorCount = 0

foreach ($folder in $policyFolders)
{
    $policyId   = $folder.Name
    $scriptPath = Join-Path $folder.FullName "$($policyId)_Creation.ps1"
    $readMe     = Get-ReadMeDetails -Path (Join-Path $folder.FullName "ReadMe.md") -PolicyId $policyId

    $policy = [ordered]@{
        id          = $policyId
        category    = Get-PolicyCategory -PolicyId $policyId
        tier        = if ($tiers.Core -contains $policyId) { "Core" } else { "Advanced" }
        title       = $readMe.Title
        objective   = $readMe.Objective
        requiresP2  = $false
        definition  = $null
        error       = $null
    }

    try
    {
        if (-not (Test-Path -LiteralPath $scriptPath))
        {
            throw "Expected script $($policyId)_Creation.ps1 was not found"
        }

        $commands = @(Get-ScriptCommandNames -Path $scriptPath)
        $policy.requiresP2 = $commands -contains "Get-MgSubscribedSku"

        # Safety check: never run a policy script that could reach Microsoft Graph for real.
        $unknown = @($commands | Where-Object { $_ -match "-Mg" -and $StubbedCommands -notcontains $_ })
        if ($unknown.Count -gt 0)
        {
            throw "Script was not run because it uses Microsoft Graph command(s) with no stand-in in build_policy_catalogue.ps1: $($unknown -join ', ')"
        }

        $CatalogueCapture = @{ Definition = $null }
        & $scriptPath *> $null

        if ($null -eq $CatalogueCapture.Definition)
        {
            throw "Script ran but did not produce a policy definition"
        }
        $policy.definition = ConvertTo-SortedData -Value $CatalogueCapture.Definition
    }
    catch
    {
        $policy.error = "$($_.Exception.Message)"
        $errorCount++
        Write-Warning "$($policyId): $($policy.error)"
    }

    $policyJson += ConvertTo-CompactJson $policy
}

# ---- Supporting objects --------------------------------------------------------------------

$locationJson = @(foreach ($file in (Get-DataFiles "data\known_locations"))
{
    ConvertTo-CompactJson (ConvertTo-SortedData -Value (Import-PowerShellDataFile -Path $file.FullName))
})
$strengthJson = @(foreach ($file in (Get-DataFiles "data\auth_strengths"))
{
    ConvertTo-CompactJson (ConvertTo-SortedData -Value (Import-PowerShellDataFile -Path $file.FullName))
})
$contextJson = @(foreach ($file in (Get-DataFiles "data\auth_contexts"))
{
    ConvertTo-CompactJson (ConvertTo-SortedData -Value (Import-PowerShellDataFile -Path $file.FullName))
})

# ---- Page ----------------------------------------------------------------------------------

# One object per line keeps Git diffs of the generated page readable.
$newLine = "`n"
$data = @(
    "{"
    '"repositoryUrl":' + (ConvertTo-CompactJson $RepositoryUrl.TrimEnd("/")) + ","
    '"policies":[' + $newLine + ($policyJson -join ",$newLine") + $newLine + "],"
    '"locations":[' + $newLine + ($locationJson -join ",$newLine") + $newLine + "],"
    '"strengths":[' + $newLine + ($strengthJson -join ",$newLine") + $newLine + "],"
    '"contexts":[' + $newLine + ($contextJson -join ",$newLine") + $newLine + "]"
    "}"
) -join $newLine

$placeholder = "/*__CATALOGUE_DATA__*/"
$template = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $templatePath).Path)
if (-not $template.Contains($placeholder))
{
    throw "Template $templatePath does not contain the data placeholder $placeholder"
}
$page = $template.Replace($placeholder, $data).Replace("`r`n", "`n")

$outputDir = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path -LiteralPath $outputDir))
{
    New-Item -Path $outputDir -ItemType Directory | Out-Null
}
$outputFile = Join-Path (Resolve-Path -LiteralPath $outputDir).Path (Split-Path -Path $OutputPath -Leaf)
[System.IO.File]::WriteAllText($outputFile, $page, [System.Text.UTF8Encoding]::new($false))

Write-Host "Policy catalogue written to $outputFile"
Write-Host "Policies: $($policyFolders.Count)   Named locations: $($locationJson.Count)   Authentication strengths: $($strengthJson.Count)   Authentication contexts: $($contextJson.Count)"
if ($errorCount -gt 0)
{
    Write-Warning "$errorCount policy script(s) could not be read. They are listed on the page with the error."
}
