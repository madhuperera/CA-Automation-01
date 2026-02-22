<div style="background-color:#b71c1c; color:#fff; padding:12px; border-radius:6px; font-weight:bold;">
⚠️ <strong>WARNING:</strong> The content below is AI generated. Please review and validate before using in production.
</div>

# CA-Automation-01

Conditional Access Policy Automation

## Overview

This repository provides **Infrastructure-as-Code automation** for Entra ID Conditional Access (CA) policies using PowerShell and Microsoft Graph API. It enables IT administrators to declaratively define CA policies, named locations, and security groups as code, then deploy them consistently across Microsoft 365 tenants.

**Key Principle**: Policies are defined as `.ps1` files in the `data/` folders, discovered automatically, and orchestrated through a single entry point (`main_script.ps1`). This enables version control, code review, and repeatability for identity security infrastructure.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [File Structure](#file-structure)
- [How to Run](#how-to-run)
- [Permissions Required](#permissions-required)
- [Scripts](#scripts)
- [CA Policies](#ca-policies)
- [Known Locations](#known-locations)
- [Development Workflows](#development-workflows)
- [Troubleshooting](#troubleshooting)

## Architecture

### Execution Flow

`main_script.ps1` orchestrates a **strict sequencing** of dependent operations:

```text
Connect to Microsoft Graph
  ↓
Create Named Locations (from data/known_locations/*.psd1)
  ↓
Create Break-Glass Groups (hardcoded emergency admin groups)
  ↓
Create Exclusion Groups (auto-generated: EID-SEC-U-A-CAP-{CA###}-Exclude)
  ↓
Create/Update CA Policies (from data/ca_policies/{CA###}/*.ps1)
```

**Why this order matters:**

- Locations must exist before policies reference them
- Groups must exist before policies can exclude them
- Break-glass accounts are created first and always excluded to prevent lockout

### Discovery-and-Apply Pattern

Each script:

1. **Scans** its data folder (e.g., `data/ca_policies/`)
2. **Discovers** all definitions (`.ps1` files)
3. **Applies** to Entra ID via Microsoft Graph API

This enables adding new policies simply by creating new `.ps1` files—no script modifications needed.

### Policy Definition Model

Each policy (`data/ca_policies/{CA###}/CA###_Creation.ps1`):

- Defines policy parameters (name, state, conditions, grant controls)
- **Dynamically resolves** group/location IDs via Graph API queries (no hardcoding)
- Creates or updates the policy atomically
- Includes automatic exclusions for break-glass and policy-specific exclusion groups

## File Structure

```plaintext
CA-Automation-01/

├── README.md
├── data/
│   ├── adminstrative_units/
│   ├── ca_policies/
│   │   ├── CA001/
│   │   ├── CA002/
│   │   ├── CA003/
│   │   ├── CA004/
│   │   ├── CA005/
│   │   ├── CA006/
│   │   ├── CA102/
│   │   ├── CA103/
│   │   ├── CA104/
│   │   ├── CA151/
│   │   ├── CA152/
│   │   ├── CA200/
│   │   ├── CA201/
│   │   ├── CA202/
│   │   ├── CA203/
│   │   ├── CA204/
│   │   ├── CA205/
│   │   ├── CA206/
│   │   ├── CA207/
│   │   ├── CA208/
│   │   ├── CA209/
│   │   ├── CA210/
│   │   ├── CA211/
│   │   ├── CA212/
│   │   ├── CA213/
│   │   ├── CA214/
│   │   ├── CA215/
│   │   ├── CA216/
│   │   ├── CA300/
│   │   ├── CA301/
│   │   ├── CA302/
│   │   ├── CA303/
│   │   ├── CA304/
│   │   ├── CA305/
│   │   ├── CA306/
│   │   ├── CA307/
│   │   └── ... (additional policies)
│   └── known_locations/
│       ├── CL001.psd1
│       ├── CL002.psd1
│       ├── CL003.psd1
│       ├── CL004.psd1
│       └── ... (additional locations)
├── scripts/
│   ├── create_admin_units.ps1
│   ├── create_break_glass_groups.ps1
│   ├── create_ca_policies.ps1
│   ├── create_groups.ps1
│   ├── create_known_locations.ps1
│   └── main_script.ps1
└── Templates/
    ├── CAPolicy_Filled.json
    └── CAPolicy_Skeleton.ps1
```

## How to Run

1. **Clone the repository** to your local machine.
2. **Open PowerShell as Administrator** (recommended for permissions).
3. **Navigate to the `scripts` directory**:

   ```powershell
   cd .\CA-Automation-01\scripts
   ```

4. **Run the main script**:

   ```powershell
   .\main_script.ps1
   ```

   The script will prompt you to confirm your Microsoft Graph session and tenant. It will sequentially execute scripts to create known locations, break glass groups, exclusion groups, and CA policies.

## Permissions Required

To run these scripts, you must have the following Microsoft Graph API permissions:

- `Policy.Read.All`
- `Policy.ReadWrite.ConditionalAccess`
- `Group.ReadWrite.All`
- `Application.Read.All`

You will be prompted to sign in and consent to these permissions when the script connects to Microsoft Graph.

## Scripts

### Entry Point

- **main_script.ps1**:
  - Connects to Microsoft Graph with required scopes
  - Shows current tenant and waits 60 seconds for confirmation (prevents accidental wrong-tenant deployments)
  - Executes subscripts in dependency order
  - All subsequent connections inherit the authenticated session

### Policy & Group Scripts

- **create_known_locations.ps1**:
  - Scans `data/known_locations/` for `.psd1` files
  - Creates or updates named locations (geographic/IP-based CA conditions)
  - Each `.psd1` is a PowerShell hash table with Graph API properties

- **create_break_glass_groups.ps1**:
  - Creates two hardcoded emergency admin groups:
    - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
    - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`
  - Always excluded from all CA policies to prevent lockout
  - Idempotent (safe to re-run)

- **create_groups.ps1**:
  - Auto-discovers CA policy folders
  - Creates one exclusion group per policy: `EID-SEC-U-A-CAP-{CA###}-Exclude`
  - Enables per-policy exception management without modifying policy files

- **create_ca_policies.ps1**:
  - Scans `data/ca_policies/` for `.ps1` files
  - Executes each policy file with `-ErrorAction Stop` (atomic deployment)
  - Displays progress bar showing completion percentage

- **create_admin_units.ps1**:
  - Reserved for administrative unit management if required

## CA Policies

### Policy Structure
Each policy lives in its own folder: `data/ca_policies/{CA###}/`
- **CA###_Creation.ps1**: Policy definition (create/update logic)
- **ReadMe.md**: Business rationale, controls summary, exclusions, and testing checklist

### Policy Definition Pattern
Every policy script follows this structure:
```powershell
# 1. Define policy parameters
$PolicyID = "CA00X"
$DisplayName = "$PolicyID-{ThreatControl}-For:{Users}-When:{Conditions}"
$State = "enabledForReportingButNotEnforced"  # audit mode

# 2. Resolve group IDs (dynamic, not hardcoded)
$ExcludedGroupIds = @()
foreach ($group in $ExcludedGroups) {
    $groupId = Get-MgGroup -Filter "displayName eq '$group'" | Select-Object -ExpandProperty Id
    if ($groupId) { $ExcludedGroupIds += $groupId }
}

# 3. Resolve location IDs (if needed)
foreach ($location in $IncludedLocations) {
    $locationId = Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$location'" | ...
}

# 4. Create/update policy atomically
$params = @{ displayName = $DisplayName; state = $State; conditions = {...}; grantControls = {...} }
$CAPolicyID = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq '$DisplayName'" -ErrorAction SilentlyContinue
if ($CAPolicyID) { Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $CAPolicyID -BodyParameter $params }
else { New-MgIdentityConditionalAccessPolicy -BodyParameter $params }
```

### Included Policies

| Policy | Description | Type |
|--------|-------------|------|
| **CA001–CA006** | Core threat controls (unknown locations, device restrictions, legacy protocol blocking) | Foundational |
| **CA102–CA104** | Admin-specific hardening (MFA, phishing-resistant auth, session frequency) | Privileged Access |
| **CA151–CA152** | Break-glass account protections (emergency admin authentication) | Emergency Access |
| **CA200–CA209, CA216** | Mobile & unmanaged device controls (app protection, managed/compliant device requirement) | Device Management |
| **CA210–CA212** | Risky sign-in controls for internals (low: MFA, medium: MFA + every sign-in, high: block) | Risk-Based Access |
| **CA213–CA215** | Risky user controls for internals (low: MFA, medium: MFA + every sign-in, high: MFA + password reset + every sign-in) | Risk-Based Access |
| CA300–CA307 | Guest and B2B access restrictions (country blocks, device requirements, legacy protocols) | External Access |

### Risk-Based License Prerequisite

Risk-based CA policies (e.g., CA210–CA215) validate Entra ID P2 support by:

1. Getting subscribed SKUs via `Get-MgSubscribedSku`
2. Filtering to SKUs with `CapabilityStatus = Enabled` and `PrepaidUnits.Enabled > 0`
3. Checking SKU `ServicePlans` for `ServicePlanName = AAD_PREMIUM_P2`

### Naming Convention for Policies

Display names follow this pattern for clarity:

```text
{CA###}-{Control/Threat}-For:{UserGroups}-When:{Conditions}
```

Examples:

- `CA001-AllApps:Block-For:AllUsers-When:UnknownLocations&Algeria`
- `CA102-MFA:Require-For:AdminRoles-When:AzureManagement`

## Known Locations

Named locations define **geographic or IP-based conditions** for CA policies. They are stored as PowerShell Data Files (`.psd1`) in `data/known_locations/`.

### File Format
Each `.psd1` is a PowerShell hash table compatible with Microsoft Graph API:

```powershell
# Country-based location (example)
@{
    "@odata.type" = "#microsoft.graph.countryNamedLocation"
    DisplayName = "CL001-CN-B-M365Apps-AllUsers-UnknownLocations&Algeria"
    CountriesAndRegions = @("DZ")
    IncludeUnknownCountriesAndRegions = $true
}

# IP-range location (example)
@{
    "@odata.type" = "#microsoft.graph.ipNamedLocation"
    DisplayName = "CL002-IP-Trusted-Corporate-Network"
    IpRanges = @(
        @{ CIDRAddress = "192.0.2.0/24" }
        @{ CIDRAddress = "198.51.100.0/24" }
    )
}
```

### Naming Convention
```
CL{nnn}-{Type}-{Description}
```
Examples:
- `CL001-CN-B-M365Apps-AllUsers-UnknownLocations&Algeria` (country-based)
- `CL002-IP-Trusted-NZ-HQ` (IP-range-based)

### Discovery

- `create_known_locations.ps1` automatically discovers all `.psd1` files
- Creates or updates locations in Entra ID
- Idempotent (safe to re-run)

## Development Workflows

### Adding a New Conditional Access Policy

1. **Create policy folder**: `data/ca_policies/CA{nnn}/` (use next available policy number)

2. **Create policy file** by copying template:
   ```powershell
   cp .\Templates\CAPolicy_Skeleton.ps1 .\data\ca_policies\CA123\CA123_Creation.ps1
   ```

3. **Define policy parameters** in the new file:
   - `$PolicyID`: Use CA number (e.g., `"CA123"`)
   - `$DisplayName`: Use format `{CA###}-{Control}-For:{Users}-When:{Conditions}`
   - `$State`: Use `"enabledForReportingButNotEnforced"` initially (audit mode before enforcement)
   - Conditions: Set `$IncludedUsers`, `$ClientAppTypes`, `$IncludedApplications`, `$IncludedLocations`, etc.

4. **Always include exclusions**:
   ```powershell
   $ExcludedGroups = @(
       "EID-SEC-U-A-CAP-CA123-Exclude"           # policy-specific exclusion group
       "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
       "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
   )
   ```
   This prevents accidental lockout of admins.

5. **Resolve IDs dynamically** (never hardcode):
   ```powershell
   $locationId = Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$location'" | Select-Object -ExpandProperty Id
   ```

6. **Create documentation**: Add `ReadMe.md` with business rationale:
   - Why this policy exists
   - What threats it mitigates
   - Which groups are excluded and why

7. **Test in audit mode**:
   ```powershell
   .\scripts\main_script.ps1
   ```
   Leave in `enabledForReportingButNotEnforced` for 24-48 hours to validate impact.

8. **Enable enforcement**: Change `$State = "enabled"` only after validation

### Adding a New Named Location

1. Create `.psd1` file in `data/known_locations/`:
   ```powershell
   New-Item -Path "data/known_locations/CL005.psd1" -ItemType File
   ```

2. Define hash table with Graph API properties:
   - For countries: `@odata.type = "#microsoft.graph.countryNamedLocation"` + `CountriesAndRegions`
   - For IP ranges: `@odata.type = "#microsoft.graph.ipNamedLocation"` + `IpRanges`

3. Set `DisplayName` following `CL{nnn}-{Type}-{Description}` convention

4. File is auto-discovered by `create_known_locations.ps1` on next run

### Modifying Existing Policies

**Safe modifications:**

- Change `$State` from `enabledForReportingButNotEnforced` to `enabled` (after validation)
- Add groups to `$ExcludedGroups` array
- Adjust conditions (locations, users, applications)
- Update `ReadMe.md` documentation

**Unsafe modifications:**

- Do NOT delete policy `.ps1` files (breaks tracking and rollback)
- Do NOT remove break-glass group exclusions
- Do NOT refactor query logic without testing in another tenant first

**Testing strategy:**

- Make changes in a non-production tenant first
- Leave in reporting mode for 24-48 hours minimum
- Review audit logs in target tenant before enforcement
- Always keep break-glass groups excluded to prevent lockout scenarios

## Troubleshooting

- **Permissions Errors:** Ensure you are running PowerShell as Administrator and have the required Graph API permissions.
- **Registry/Access Errors:** Some scripts may require elevated permissions to modify registry or system settings.
- **Policy Creation Errors:** Check that all required parameters are provided and that group/application IDs are valid.
- **Session Issues:** If you are connected to the wrong tenant, disconnect and reconnect with the correct scopes.
- **Group Not Found:** If `create_groups.ps1` fails, ensure policy folders exist in `data/ca_policies/` before running
- **Location ID Resolution Fails:** Verify `.psd1` files in `data/known_locations/` are valid PowerShell (run `Import-PowerShellDataFile` to test)
- **Policy Won't Update:** Check `displayName` matches exactly (case-sensitive) in `Get-MgIdentityConditionalAccessPolicy` filter

---

## Key Principles

1. **Infrastructure-as-Code**: All policies and locations are versioned in git for auditability and rollback
2. **Idempotency**: Scripts are safe to run multiple times; they check for existing resources before creation
3. **Progressive Enforcement**: Always deploy in `enabledForReportingButNotEnforced` mode first; validate for 24-48 hours before switching to `enabled`
4. **Break-Glass Priority**: Emergency admin accounts are always excluded from CA policies to prevent lockout
5. **Dynamic ID Resolution**: Group and location IDs are resolved at runtime via Graph API queries—never hardcoded
6. **Strict Sequencing**: Operations have hard dependencies (e.g., locations before policies) enforced by execution order

## References

- [Microsoft Graph Conditional Access API](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccess-overview)
- [Named Locations in Azure AD](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/location-condition)
- [Conditional Access Policy Design](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/plan-conditional-access)
- See `.github/copilot-instructions.md` for AI-assisted development guidance