<div style="background-color:#b71c1c; color:#fff; padding:12px; border-radius:6px; font-weight:bold;">
⚠️ <strong>WARNING:</strong> The content below is AI generated. Please review and validate before using in production.
</div>

# CA-Automation-01

Conditional Access Policy Automation

## Overview

This repository provides **Infrastructure-as-Code automation** for Entra ID Conditional Access (CA) policies using PowerShell and Microsoft Graph API. It enables IT administrators to declaratively define CA policies, named locations, and security groups as code, then deploy them consistently across Microsoft 365 tenants.

**Key Principle**: Policies are defined as `.ps1` files in the `data/` folders, discovered automatically, and orchestrated through a single entry point (`main_script.ps1`). This enables version control, code review, and repeatability for identity security infrastructure.

### Policy Numbering by Persona

Each CA policy number range maps to a specific user persona:

| Range | Persona | Description |
|-------|---------|-------------|
| **CA000–CA099** | Global | Foundational controls applied to all users |
| **CA100–CA149** | Admins | Privileged access hardening for admin roles |
| **CA150–CA152** | Break-Glass | Emergency access account protections |
| **CA200–CA299** | Internals | Controls for internal employees (devices, risk, apps) |
| **CA300–CA399** | Guests & External | Restrictions for B2B guests, service providers, and external users |
| **CA800–CA899** | Custom | Targeted policies for specific groups or scenarios (e.g. IP restrictions for a subset of users) |

> **Recommendation — Piloting new controls for an existing persona**: Start from the **ceiling** of that persona's range and work **backwards**. For example, if you want to pilot a new control for Internal Users, start at CA299 and decrement (CA299, CA298, ...). This keeps pilot/experimental policies separated from the established baseline at the lower end of the range.

> **Recommendation — Custom per-group policies**: Use the **CA800** range for policies that target a specific group of users with a unique condition — for example, restricting a particular team's access to a set of IPs. This avoids polluting the persona ranges with one-off rules.

### Deployment Tiers

Policies are classified into two deployment tiers. **Core** policies form the security baseline that every tenant must deploy. **Advanced** policies layer on additional controls for organisations with stricter requirements or Entra ID P2 licensing.

#### Core Policies (Baseline)

These policies must be deployed in every tenant.

| Persona | Policies |
|---------|----------|
| **Global** | CA001, CA002, CA004, CA005 |
| **Admins** | CA102, CA104, CA105, CA151, CA152 |
| **Internals** | CA200, CA201, CA205, CA206, CA209, CA218 |
| **Guests & External** | CA300, CA301, CA302, CA303, CA304, CA306, CA307 |

#### Advanced Policies

These policies add defence-in-depth and are recommended for mature environments.

| Persona | Policies | Notes |
|---------|----------|-------|
| **Global** | CA003 | Admin portal blocking |
| **Admins** | CA103 | Phishing-resistant MFA |
| **Internals** | CA202, CA203, CA204, CA207, CA208 | Device management & session controls |
| **Internals** | CA210, CA211, CA212 | Sign-in risk (requires Entra ID P2) |
| **Internals** | CA213, CA214, CA215 | User risk (requires Entra ID P2) |
| **Internals** | CA216, CA217 | Platform-specific device controls |
| **Guests & External** | CA305 | Compliant device for service provider admin access |

## Table of Contents

- [Overview](#overview)
  - [Policy Numbering by Persona](#policy-numbering-by-persona)
  - [Deployment Tiers](#deployment-tiers)
- [Architecture](#architecture)
- [File Structure](#file-structure)
- [How to Run](#how-to-run)
- [Permissions Required](#permissions-required)
- [Scripts](#scripts)
- [CA Policies](#ca-policies)
  - [Global — Foundational Controls (CA0xx)](#global--foundational-controls-ca0xx)
  - [Admins — Privileged Access (CA1xx)](#admins--privileged-access-ca1xx)
  - [Internals — Standard Users (CA2xx)](#internals--standard-users-ca2xx)
  - [Guests & External — B2B and Service Providers (CA3xx)](#guests--external--b2b-and-service-providers-ca3xx)
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
│   │   ├── CA102/
│   │   ├── CA103/
│   │   ├── CA104/
│   │   ├── CA105/
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
│   │   ├── CA217/
│   │   ├── CA218/
│   │   ├── CA300/
│   │   ├── CA301/
│   │   ├── CA302/
│   │   ├── CA303/
│   │   ├── CA304/
│   │   ├── CA305/
│   │   ├── CA306/
│   │   ├── CA307/
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
   # Deploy ALL policies (Core + Advanced) — this is the default
   .\main_script.ps1

   # Deploy only the Core baseline policies (22 policies)
   .\main_script.ps1 -Mode Core
   ```

   | Mode | Policies Deployed | Use Case |
   |------|-------------------|----------|
   | `Advanced` (default) | All 38 policies | Full deployment for mature environments |
   | `Core` | 22 baseline policies | New tenant onboarding or minimum security baseline |

   The Core policy list is defined in `data/policy_tiers.psd1`. When running in Core mode, only the policies listed there (and their exclusion groups) are created.

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

Policies are organized into **four personas** based on the user population they target. Each policy folder contains a `CA###_Creation.ps1` (deployment script) and a `ReadMe.md` (business rationale).

#### Global — Foundational Controls (CA0xx)

Policies that apply to **all users** across the tenant.

| Policy | Display Name | Description | Docs |
|--------|-------------|-------------|------|
| CA001 | `CA001-AllApps:Block-For:Global-When:UnknownLocations&BouvetIsland` | Blocks access from unknown locations and Bouvet Island (proxy for Algeria via CL001) | [ReadMe](data/ca_policies/CA001/ReadMe.md) |
| CA002 | `CA002-AzureManagement:RequireMFA-For:Global-When:AnyNetwork` | Requires MFA for Azure Management access | [ReadMe](data/ca_policies/CA002/ReadMe.md) |
| CA003 | `CA003-AdminPortals:Block-For:Global-When:AnyNetwork` | Blocks non-admin users from Admin Portals | [ReadMe](data/ca_policies/CA003/ReadMe.md) |
| CA004 | `CA004-AllApps:Block-For:Global-When:DeviceCodeAuthTransfer` | Blocks device code authentication transfer flow | [ReadMe](data/ca_policies/CA004/ReadMe.md) |
| CA005 | `CA005-AllApps:Block-For:Global-When:DeviceCodeFlow` | Blocks device code flow authentication | [ReadMe](data/ca_policies/CA005/ReadMe.md) |

#### Admins — Privileged Access (CA1xx)

Policies targeting **admin roles** and **emergency break-glass accounts**.

| Policy | Display Name | Description | Docs |
|--------|-------------|-------------|------|
| CA102 | `CA102-AllApps:RequireMFA-For:Admins-When:AnyNetwork` | Requires MFA for all admin role holders | [ReadMe](data/ca_policies/CA102/ReadMe.md) |
| CA103 | `CA103-AllApps:PhishingResistantMFA-For:Admins-When:AnyNetwork` | Requires phishing-resistant MFA (FIDO2/WHfB) for admins | [ReadMe](data/ca_policies/CA103/ReadMe.md) |
| CA104 | `CA104-AllApps:SessionFrequency-For:Admins-When:AnyNetwork` | Enforces 4-hour sign-in frequency for admin sessions | [ReadMe](data/ca_policies/CA104/ReadMe.md) |
| CA105 | `CA105-AllApps:Block-For:Admins-When:LegacyProtocols` | Blocks legacy authentication protocols for admin roles | [ReadMe](data/ca_policies/CA105/ReadMe.md) |
| CA151 | `CA151-AllApps:AuthStrength-For:EmergencyBreakGlassAccount1-When:AnyNetwork` | Enforces authentication strength for break-glass account 1 | [ReadMe](data/ca_policies/CA151/ReadMe.md) |
| CA152 | `CA152-AllApps:AuthStrength-For:EmergencyBreakGlassAccount2-When:AnyNetwork` | Enforces authentication strength for break-glass account 2 | [ReadMe](data/ca_policies/CA152/ReadMe.md) |

#### Internals — Standard Users (CA2xx)

Policies targeting **internal employees** across device types, risk levels, and app scenarios.

| Policy | Display Name | Description | Docs |
|--------|-------------|-------------|------|
| CA200 | `CA200-O365:RequireAppProtectionPolicy-For:AllUsers-When:OnMobileDevices` | Requires app protection policy for Office 365 on mobile (iOS/Android) | [ReadMe](data/ca_policies/CA200/ReadMe.md) |
| CA201 | `CA201-AllApps:Block-For:Internals-When:UnsupportedDeviceType` | Blocks access from unsupported device platforms | [ReadMe](data/ca_policies/CA201/ReadMe.md) |
| CA202 | `CA202-SecurityInformation:RequireMFAorCompliant-For:Internals-When:OutsideOfOffice` | Requires MFA or compliant device for security info registration outside office | [ReadMe](data/ca_policies/CA202/ReadMe.md) |
| CA203 | `CA203-AllApps:SessionFrequency-For:Internals-When:OnUnmanagedDevices` | Enforces 3-hour sign-in frequency on unmanaged/non-compliant devices | [ReadMe](data/ca_policies/CA203/ReadMe.md) |
| CA204 | `CA204-AllApps:ManagedDevice-For:Internals-When:AnyNetwork` | Blocks access from unmanaged devices (device filter) | [ReadMe](data/ca_policies/CA204/ReadMe.md) |
| CA205 | `CA205-AllApps:Block-For:Internals-When:LegacyProtocols` | Blocks legacy authentication protocols | [ReadMe](data/ca_policies/CA205/ReadMe.md) |
| CA206 | `CA206-AllApps:RequireMFA-For:Internals-When:AnyNetwork` | Requires MFA for all internal users | [ReadMe](data/ca_policies/CA206/ReadMe.md) |
| CA207 | `CA207-AllApps:RequirePasswordless-For:Internals-When:AnyNetwork` | Requires passwordless authentication (auth strength) | [ReadMe](data/ca_policies/CA207/ReadMe.md) |
| CA208 | `CA208-O365:RequireManagedDevice-For:Internals-When:OnWindowsDevices` | Blocks non-company Windows devices from Office 365 (device filter) | [ReadMe](data/ca_policies/CA208/ReadMe.md) |
| CA209 | `CA209-DeviceEnrollment:RequireMFA-For:Internals-When:OutsideOfOffice` | Requires MFA for Intune device enrollment outside office network | [ReadMe](data/ca_policies/CA209/ReadMe.md) |
| CA210 | `CA210-AllApps:RequireMFA-For:Internals-When:RiskySignIn:Low` | Requires MFA when sign-in risk is low (Entra ID P2) | [ReadMe](data/ca_policies/CA210/ReadMe.md) |
| CA211 | `CA211-AllApps:RequireMFA+EverySignIn-For:Internals-When:RiskySignIn:Medium` | Requires MFA + every-time reauthentication when sign-in risk is medium (Entra ID P2) | [ReadMe](data/ca_policies/CA211/ReadMe.md) |
| CA212 | `CA212-AllApps:Block-For:Internals-When:RiskySignIn:High` | Blocks access when sign-in risk is high (Entra ID P2) | [ReadMe](data/ca_policies/CA212/ReadMe.md) |
| CA213 | `CA213-AllApps:RequireMFA-For:Internals-When:RiskyUser:Low` | Requires MFA when user risk is low (Entra ID P2) | [ReadMe](data/ca_policies/CA213/ReadMe.md) |
| CA214 | `CA214-AllApps:RequireMFA+EverySignIn-For:Internals-When:RiskyUser:Medium` | Requires MFA + every-time reauthentication when user risk is medium (Entra ID P2) | [ReadMe](data/ca_policies/CA214/ReadMe.md) |
| CA215 | `CA215-AllApps:RequireMFA+PwdReset+EverySignIn-For:Internals-When:RiskyUser:High` | Requires MFA + password reset + every-time reauthentication when user risk is high (Entra ID P2) | [ReadMe](data/ca_policies/CA215/ReadMe.md) |
| CA216 | `CA216-O365:RequireCompliantDevice-For:Internals-When:OnWindowsDevices` | Requires compliant device for Office 365 on Windows devices | [ReadMe](data/ca_policies/CA216/ReadMe.md) |
| CA217 | `CA217-O365:Block-For:Internals-When:OnmacOSDevices` | Blocks Office 365 access from macOS devices | [ReadMe](data/ca_policies/CA217/ReadMe.md) |
| CA218 | `CA218-AllApps:Block-For:Internals-When:OutsideOfTrustedCountries` | Blocks internal users from outside trusted countries (CL004) | [ReadMe](data/ca_policies/CA218/ReadMe.md) |

#### Guests & External — B2B and Service Providers (CA3xx)

Policies targeting **guest users**, **B2B collaboration partners**, and **service provider accounts**.

| Policy | Display Name | Description | Docs |
|--------|-------------|-------------|------|
| CA300 | `CA300-AllApps:Block-For:Guests-When:UnallowedGuestType` | Blocks local guest, other external, and service provider users | [ReadMe](data/ca_policies/CA300/ReadMe.md) |
| CA301 | `CA301-AllApps:Block-For:B2BCollaborationGuests-When:OutsideOfTrustedCountries` | Blocks B2B collaboration guests from outside trusted countries (CL004) | [ReadMe](data/ca_policies/CA301/ReadMe.md) |
| CA302 | `CA302-AllApps:RequireMFA-For:B2BCollaborationGuests-When:AnyNetwork` | Requires MFA (auth strength) for B2B collaboration guests | [ReadMe](data/ca_policies/CA302/ReadMe.md) |
| CA303 | `CA303-AllApps:Block-For:ServiceProviderUsers-When:OutsideOfTrustedCountries` | Blocks service provider users from outside trusted countries (CL004) | [ReadMe](data/ca_policies/CA303/ReadMe.md) |
| CA304 | `CA304-AllApps:RequireMFA-For:ServiceProviderUsers-When:AnyNetwork` | Requires MFA (auth strength) for service provider users | [ReadMe](data/ca_policies/CA304/ReadMe.md) |
| CA305 | `CA305-AdminPortals:RequireCompliant-For:ServiceProviderUsers` | Requires compliant device for service providers accessing admin portals | [ReadMe](data/ca_policies/CA305/ReadMe.md) |
| CA306 | `CA306-AllApps:Block-For:AllGuests-When:UnsupportedDeviceType` | Blocks all guest/external users from unsupported device platforms | [ReadMe](data/ca_policies/CA306/ReadMe.md) |
| CA307 | `CA307-AllApps:Block-For:AllGuests-When:LegacyProtocols` | Blocks legacy authentication for all guest/external users | [ReadMe](data/ca_policies/CA307/ReadMe.md) |

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

- `CA001-AllApps:Block-For:Global-When:UnknownLocations&BouvetIsland`
- `CA102-AllApps:RequireMFA-For:Admins-When:AnyNetwork`

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