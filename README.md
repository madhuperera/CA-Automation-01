<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:1d4ed8,100:38bdf8&height=180&section=header&text=CA-Automation-01&fontSize=42&fontColor=ffffff&animation=fadeIn&fontAlignY=35&desc=Entra%20ID%20Conditional%20Access%20%7C%20PowerShell%20%7C%20Microsoft%20Graph%20%7C%20Security%20Baseline&descAlignY=55&descSize=15" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Entra%20ID-2563eb?style=for-the-badge&logo=microsoftazure&logoColor=white" />
  <img src="https://img.shields.io/badge/Conditional%20Access-Automation-0f766e?style=for-the-badge&logo=microsoft&logoColor=white" />
  <img src="https://img.shields.io/badge/PowerShell-Required-2E76C7?style=for-the-badge&logo=powershell&logoColor=white" />
  <img src="https://img.shields.io/badge/Microsoft%20Graph-API-0891b2?style=for-the-badge&logo=microsoft&logoColor=white" />
</p>

<h2 align="center">Conditional Access policy automation for Microsoft Entra ID</h2>

<p align="center">
  Infrastructure-as-Code style deployment for Conditional Access policies, named locations, security groups, and baseline identity controls.
</p>

---

## What this repository does

`CA-Automation-01` provides PowerShell-based automation for deploying Microsoft Entra ID Conditional Access policies using Microsoft Graph.

The repository is designed around a simple model:

```text
Define policies as code
        ↓
Store policy definitions in Git
        ↓
Deploy through a controlled PowerShell entry point
        ↓
Validate in report-only mode
        ↓
Move to enforcement after review
```

The main goal is to make Conditional Access deployments more consistent, reviewable, repeatable, and easier to maintain across Microsoft 365 tenants.

---

## Quick navigation

<p align="center">
  <a href="#architecture">
    <img src="https://img.shields.io/badge/Architecture-View-1d4ed8?style=for-the-badge" />
  </a>
  <a href="#deployment-tiers">
    <img src="https://img.shields.io/badge/Deployment%20Tiers-Core%20%7C%20Advanced-0f766e?style=for-the-badge" />
  </a>
  <a href="#how-to-run">
    <img src="https://img.shields.io/badge/How%20to%20Run-PowerShell-2E76C7?style=for-the-badge" />
  </a>
  <a href="#policy-catalogue">
    <img src="https://img.shields.io/badge/Policy%20Catalogue-CA001%20to%20CA307-334155?style=for-the-badge" />
  </a>
</p>

---

## Key capabilities

<table>
  <tr>
    <td width="50%">
      <h3>Policy-as-code</h3>
      <p>Conditional Access policies are defined as PowerShell files under <code>data/ca_policies/</code>, making them version-controlled and reviewable.</p>
    </td>
    <td width="50%">
      <h3>Microsoft Graph deployment</h3>
      <p>Policies, named locations, and supporting groups are created or updated through Microsoft Graph PowerShell commands.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>Core and Advanced modes</h3>
      <p>Deploy only the baseline Core controls or deploy the full Advanced policy set for more mature environments.</p>
    </td>
    <td width="50%">
      <h3>Dynamic ID resolution</h3>
      <p>Group and named location IDs are resolved at runtime, avoiding hardcoded tenant-specific object IDs.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>Exclusion group model</h3>
      <p>Each policy receives a dedicated exclusion group using the <code>EID-SEC-U-A-CAP-{CA###}-Exclude</code> naming pattern.</p>
    </td>
    <td width="50%">
      <h3>Break-glass protection</h3>
      <p>Emergency access groups are created first and excluded from Conditional Access policies to reduce lockout risk.</p>
    </td>
  </tr>
</table>

---

## Architecture

### Execution flow

```text
main_script.ps1
      │
      ▼
Connect to Microsoft Graph
      │
      ▼
Create named locations
data/known_locations/*.psd1
      │
      ▼
Create break-glass groups
Emergency access exclusions
      │
      ▼
Create policy exclusion groups
EID-SEC-U-A-CAP-{CA###}-Exclude
      │
      ▼
Create or update Conditional Access policies
data/ca_policies/{CA###}/*.ps1
```

### Why the order matters

| Step | Reason |
|---|---|
| Named locations first | Policies may reference country or IP-based locations |
| Break-glass groups second | Emergency access exclusions must exist before policies are deployed |
| Exclusion groups third | Each policy needs a dedicated exclusion group |
| Policies last | Policies depend on all supporting objects being available |

---

## Repository structure

```text
CA-Automation-01/
│
├── README.md
│
├── data/
│   ├── ca_policies/
│   │   ├── CA001/
│   │   ├── CA002/
│   │   ├── CA003/
│   │   ├── ...
│   │   └── CA307/
│   │
│   ├── known_locations/
│   │   ├── CL001.psd1
│   │   ├── CL002.psd1
│   │   ├── CL003.psd1
│   │   ├── CL004.psd1
│   │   └── CL005.psd1
│   │
│   └── policy_tiers.psd1
│
├── scripts/
│   ├── create_admin_units.ps1
│   ├── create_break_glass_groups.ps1
│   ├── create_ca_policies.ps1
│   ├── create_groups.ps1
│   ├── create_known_locations.ps1
│   └── main_script.ps1
│
└── Templates/
    ├── CAPolicy_Filled.json
    └── CAPolicy_Skeleton.ps1
```

---

## Deployment tiers

This repository supports two deployment modes.

<table>
  <tr>
    <td width="50%">
      <h3>Core mode</h3>
      <p>Baseline Conditional Access controls intended for standard tenant onboarding and minimum identity security posture.</p>
      <p><strong>Use when:</strong></p>
      <ul>
        <li>Deploying to a new tenant</li>
        <li>Starting with a controlled baseline</li>
        <li>Minimising user impact during initial rollout</li>
      </ul>
    </td>
    <td width="50%">
      <h3>Advanced mode</h3>
      <p>Full Conditional Access deployment including additional device, session, risk-based, and service provider controls.</p>
      <p><strong>Use when:</strong></p>
      <ul>
        <li>The tenant has stronger security requirements</li>
        <li>Device management is mature</li>
        <li>Entra ID P2 features are available</li>
      </ul>
    </td>
  </tr>
</table>

### Core policies

| Persona | Policies |
|---|---|
| Global | CA001, CA002, CA004, CA005 |
| Admins | CA102, CA104, CA105, CA151, CA152 |
| Internals | CA201, CA205, CA206, CA209, CA218 |
| Guests & External | CA300, CA301, CA302, CA303, CA304, CA306, CA307 |

### Advanced policies

| Persona | Policies | Notes |
|---|---|---|
| Global | CA003 | Admin portal blocking |
| Admins | CA103 | Phishing-resistant MFA |
| Internals | CA200 | App protection policy on mobile devices |
| Internals | CA202, CA203, CA204, CA207, CA208 | Device and session controls |
| Internals | CA210, CA211, CA212 | Sign-in risk controls; requires Entra ID P2 |
| Internals | CA213, CA214, CA215 | User risk controls; requires Entra ID P2 |
| Internals | CA216, CA217 | Platform-specific device controls |
| Guests & External | CA305 | Compliant device requirement for service provider admin access |

---

## Policy numbering model

Each policy number range maps to a user persona or policy category.

| Range | Persona | Description |
|---|---|---|
| CA000–CA099 | Global | Foundational controls applied broadly across the tenant |
| CA100–CA149 | Admins | Privileged access hardening for admin roles |
| CA150–CA152 | Break-glass | Emergency access account protections |
| CA200–CA299 | Internals | Internal user controls for devices, risk, apps, and sessions |
| CA300–CA399 | Guests & External | Controls for B2B guests, service providers, and external users |
| CA800–CA899 | Custom | Targeted policies for specific groups or special scenarios |

### Numbering guidance

For new pilot controls within an existing persona, start from the top of that range and work backwards.

Example:

```text
Internal user pilot policies:
CA299
CA298
CA297
```

For one-off or targeted group policies, use the `CA800` range to avoid polluting the main persona ranges.

---

## How to run

### 1. Clone the repository

```powershell
git clone https://github.com/madhuperera/CA-Automation-01.git
```

### 2. Open PowerShell as Administrator

Administrator mode is recommended.

### 3. Navigate to the scripts folder

```powershell
cd .\CA-Automation-01\scripts
```

### 4. Run the deployment

Deploy all policies using the default Advanced mode:

```powershell
.\main_script.ps1
```

Deploy only the Core baseline:

```powershell
.\main_script.ps1 -Mode Core
```

### Deployment modes

| Mode | Policies deployed | Use case |
|---|---|---|
| Advanced | All policies | Full deployment for mature environments |
| Core | Baseline policies only | New tenant onboarding or minimum security baseline |

The Core policy list is defined in:

```text
data/policy_tiers.psd1
```

---

## Permissions required

The signed-in account must be able to consent to and use the following Microsoft Graph permissions:

| Permission | Purpose |
|---|---|
| Policy.Read.All | Read Conditional Access policy state |
| Policy.ReadWrite.ConditionalAccess | Create and update Conditional Access policies |
| Group.ReadWrite.All | Create and update security groups |
| Application.Read.All | Read application and service principal references |

---

## Script responsibilities

<table>
  <tr>
    <td width="35%"><strong>Script</strong></td>
    <td><strong>Purpose</strong></td>
  </tr>
  <tr>
    <td><code>main_script.ps1</code></td>
    <td>Entry point. Connects to Microsoft Graph, confirms tenant context, and executes sub-scripts in dependency order.</td>
  </tr>
  <tr>
    <td><code>create_known_locations.ps1</code></td>
    <td>Discovers <code>.psd1</code> files under <code>data/known_locations/</code> and creates or updates named locations.</td>
  </tr>
  <tr>
    <td><code>create_break_glass_groups.ps1</code></td>
    <td>Creates emergency access groups used as break-glass exclusions.</td>
  </tr>
  <tr>
    <td><code>create_groups.ps1</code></td>
    <td>Creates one exclusion group per Conditional Access policy folder.</td>
  </tr>
  <tr>
    <td><code>create_ca_policies.ps1</code></td>
    <td>Discovers and executes policy creation scripts under <code>data/ca_policies/</code>.</td>
  </tr>
  <tr>
    <td><code>create_admin_units.ps1</code></td>
    <td>Reserved for administrative unit management if required.</td>
  </tr>
</table>

---

## Policy definition pattern

Each policy lives in its own folder:

```text
data/ca_policies/{CA###}/
```

Each policy folder should contain:

| File | Purpose |
|---|---|
| `CA###_Creation.ps1` | Policy definition and create/update logic |
| `ReadMe.md` | Business rationale, testing guidance, exclusions, and control summary |

### Standard policy pattern

```powershell
# 1. Define policy parameters
$PolicyID = "CA00X"
$DisplayName = "$PolicyID-{ThreatControl}-For:{Users}-When:{Conditions}"
$State = "enabledForReportingButNotEnforced"

# 2. Resolve group IDs dynamically
$ExcludedGroupIds = @()

foreach ($Group in $ExcludedGroups)
{
    $GroupId = Get-MgGroup -Filter "displayName eq '$Group'" | Select-Object -ExpandProperty Id

    if ($GroupId)
    {
        $ExcludedGroupIds += $GroupId
    }
}

# 3. Resolve named location IDs if required
foreach ($Location in $IncludedLocations)
{
    $LocationId = Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$Location'"
}

# 4. Create or update the policy
$Params = @{
    displayName = $DisplayName
    state       = $State
    conditions  = @{
    }
    grantControls = @{
    }
}

$CAPolicyID = Get-MgIdentityConditionalAccessPolicy -Filter "displayName eq '$DisplayName'" -ErrorAction SilentlyContinue

if ($CAPolicyID)
{
    Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $CAPolicyID -BodyParameter $Params
}
else
{
    New-MgIdentityConditionalAccessPolicy -BodyParameter $Params
}
```

---

## Policy catalogue

<details>
<summary><strong>Global — Foundational controls</strong></summary>

| Policy | Display name | Description | Docs |
|---|---|---|---|
| CA001 | `CA001-AllApps:Block-For:Global-When:UnknownLocations&BouvetIsland` | Blocks access from unknown locations and Bouvet Island | [ReadMe](data/ca_policies/CA001/ReadMe.md) |
| CA002 | `CA002-AzureManagement:RequireMFA-For:Global-When:AnyNetwork` | Requires MFA for Azure Management access | [ReadMe](data/ca_policies/CA002/ReadMe.md) |
| CA003 | `CA003-AdminPortals:Block-For:Global-When:AnyNetwork` | Blocks non-admin users from admin portals | [ReadMe](data/ca_policies/CA003/ReadMe.md) |
| CA004 | `CA004-AllApps:Block-For:Global-When:DeviceCodeAuthTransfer` | Blocks device code authentication transfer flow | [ReadMe](data/ca_policies/CA004/ReadMe.md) |
| CA005 | `CA005-AllApps:Block-For:Global-When:DeviceCodeFlow` | Blocks device code flow authentication | [ReadMe](data/ca_policies/CA005/ReadMe.md) |

</details>

<details>
<summary><strong>Admins — Privileged access</strong></summary>

| Policy | Display name | Description | Docs |
|---|---|---|---|
| CA102 | `CA102-AllApps:RequireMFA-For:Admins-When:AnyNetwork` | Requires MFA for all admin role holders | [ReadMe](data/ca_policies/CA102/ReadMe.md) |
| CA103 | `CA103-AllApps:PhishingResistantMFA-For:Admins-When:AnyNetwork` | Requires phishing-resistant MFA for admins | [ReadMe](data/ca_policies/CA103/ReadMe.md) |
| CA104 | `CA104-AllApps:SessionFrequency-For:Admins-When:AnyNetwork` | Enforces 4-hour sign-in frequency for admin sessions | [ReadMe](data/ca_policies/CA104/ReadMe.md) |
| CA105 | `CA105-AllApps:Block-For:Admins-When:LegacyProtocols` | Blocks legacy authentication protocols for admins | [ReadMe](data/ca_policies/CA105/README.md) |
| CA151 | `CA151-AllApps:AuthStrength-For:EmergencyBreakGlassAccount1-When:AnyNetwork` | Enforces authentication strength for break-glass account 1 | [ReadMe](data/ca_policies/CA151/ReadMe.md) |
| CA152 | `CA152-AllApps:AuthStrength-For:EmergencyBreakGlassAccount2-When:AnyNetwork` | Enforces authentication strength for break-glass account 2 | [ReadMe](data/ca_policies/CA152/ReadMe.md) |

</details>

<details>
<summary><strong>Internals — Standard users</strong></summary>

| Policy | Display name | Description | Docs |
|---|---|---|---|
| CA200 | `CA200-O365:RequireAppProtectionPolicy-For:AllUsers-When:OnMobileDevices` | Requires app protection policy for Office 365 on mobile | [ReadMe](data/ca_policies/CA200/ReadMe.md) |
| CA201 | `CA201-AllApps:Block-For:Internals-When:UnsupportedDeviceType` | Blocks unsupported device platforms | [ReadMe](data/ca_policies/CA201/ReadMe.md) |
| CA202 | `CA202-SecurityInformation:RequireMFAorCompliant-For:Internals-When:OutsideOfOffice` | Requires MFA or compliant device for security information registration outside office | [ReadMe](data/ca_policies/CA202/ReadMe.md) |
| CA203 | `CA203-AllApps:SessionFrequency-For:Internals-When:OnUnmanagedDevices` | Enforces sign-in frequency on unmanaged devices | [ReadMe](data/ca_policies/CA203/ReadMe.md) |
| CA204 | `CA204-AllApps:ManagedDevice-For:Internals-When:AnyNetwork` | Blocks unmanaged devices | [ReadMe](data/ca_policies/CA204/ReadMe.md) |
| CA205 | `CA205-AllApps:Block-For:Internals-When:LegacyProtocols` | Blocks legacy authentication protocols | [ReadMe](data/ca_policies/CA205/ReadMe.md) |
| CA206 | `CA206-AllApps:RequireMFA-For:Internals-When:AnyNetwork` | Requires MFA for internal users | [ReadMe](data/ca_policies/CA206/ReadMe.md) |
| CA207 | `CA207-AllApps:RequirePasswordless-For:Internals-When:AnyNetwork` | Requires passwordless authentication | [ReadMe](data/ca_policies/CA207/ReadMe.md) |
| CA208 | `CA208-O365:RequireManagedDevice-For:Internals-When:OnWindowsDevices` | Blocks non-company Windows devices from Office 365 | [ReadMe](data/ca_policies/CA208/ReadMe.md) |
| CA209 | `CA209-DeviceEnrollment:RequireMFA-For:Internals-When:OutsideOfOffice` | Requires MFA for Intune device enrolment outside office | [ReadMe](data/ca_policies/CA209/ReadMe.md) |
| CA210 | `CA210-AllApps:RequireMFA-For:Internals-When:RiskySignIn:Low` | Requires MFA for low sign-in risk | [ReadMe](data/ca_policies/CA210/ReadMe.md) |
| CA211 | `CA211-AllApps:RequireMFA+EverySignIn-For:Internals-When:RiskySignIn:Medium` | Requires MFA and every-time reauthentication for medium sign-in risk | [ReadMe](data/ca_policies/CA211/ReadMe.md) |
| CA212 | `CA212-AllApps:Block-For:Internals-When:RiskySignIn:High` | Blocks high-risk sign-ins | [ReadMe](data/ca_policies/CA212/ReadMe.md) |
| CA213 | `CA213-AllApps:RequireMFA-For:Internals-When:RiskyUser:Low` | Requires MFA for low user risk | [ReadMe](data/ca_policies/CA213/ReadMe.md) |
| CA214 | `CA214-AllApps:RequireMFA+EverySignIn-For:Internals-When:RiskyUser:Medium` | Requires MFA and every-time reauthentication for medium user risk | [ReadMe](data/ca_policies/CA214/ReadMe.md) |
| CA215 | `CA215-AllApps:RequireMFA+PwdReset+EverySignIn-For:Internals-When:RiskyUser:High` | Requires MFA, password reset, and every-time reauthentication for high user risk | [ReadMe](data/ca_policies/CA215/ReadMe.md) |
| CA216 | `CA216-O365:RequireCompliantDevice-For:Internals-When:OnWindowsDevices` | Requires compliant Windows device for Office 365 | [ReadMe](data/ca_policies/CA216/ReadMe.md) |
| CA217 | `CA217-O365:Block-For:Internals-When:OnmacOSDevices` | Blocks Office 365 access from macOS devices | [ReadMe](data/ca_policies/CA217/ReadMe.md) |
| CA218 | `CA218-AllApps:Block-For:Internals-When:OutsideOfTrustedCountries` | Blocks internal users from outside trusted countries | [ReadMe](data/ca_policies/CA218/ReadMe.md) |

</details>

<details>
<summary><strong>Guests & External — B2B and service providers</strong></summary>

| Policy | Display name | Description | Docs |
|---|---|---|---|
| CA300 | `CA300-AllApps:Block-For:UnallowedGuestTypes-When:AnyNetwork` | Blocks unallowed external user types | [ReadMe](data/ca_policies/CA300/ReadMe.md) |
| CA301 | `CA301-AllApps:Block-For:B2BCollaborationGuests-When:OutsideOfTrustedCountries` | Blocks B2B guests from outside trusted countries | [ReadMe](data/ca_policies/CA301/ReadMe.md) |
| CA302 | `CA302-AllApps:RequireMFA-For:B2BCollaborationGuests-When:AnyNetwork` | Requires MFA for B2B collaboration guests | [ReadMe](data/ca_policies/CA302/ReadMe.md) |
| CA303 | `CA303-AllApps:Block-For:ServiceProviderUsers-When:OutsideOfTrustedCountries` | Blocks service provider users from outside trusted countries | [ReadMe](data/ca_policies/CA303/ReadMe.md) |
| CA304 | `CA304-AllApps:RequireMFA-For:ServiceProviderUsers-When:AnyNetwork` | Requires MFA for service provider users | [ReadMe](data/ca_policies/CA304/ReadMe.md) |
| CA305 | `CA305-AdminPortals:RequireCompliant-For:ServiceProviderUsers-When:AnyNetwork` | Requires compliant device for service provider admin portal access | [ReadMe](data/ca_policies/CA305/ReadMe.md) |
| CA306 | `CA306-AllApps:Block-For:AllGuests-When:UnsupportedDeviceType` | Blocks guest and external users from unsupported devices | [ReadMe](data/ca_policies/CA306/ReadMe.md) |
| CA307 | `CA307-AllApps:Block-For:AllGuests-When:LegacyProtocols` | Blocks legacy authentication for guest and external users | [ReadMe](data/ca_policies/CA307/ReadMe.md) |

</details>

---

## Known locations

Named locations define geographic or IP-based conditions used by Conditional Access policies.

Named location definitions are stored here:

```text
data/known_locations/
```

### Country-based location example

```powershell
@{
    "@odata.type" = "#microsoft.graph.countryNamedLocation"
    DisplayName = "CL001-CN-B-M365Apps-AllUsers-UnknownLocations&BouvetIsland"
    CountriesAndRegions = @("BV")
    IncludeUnknownCountriesAndRegions = $true
}
```

### IP-based location example

```powershell
@{
    "@odata.type" = "#microsoft.graph.ipNamedLocation"
    DisplayName = "CL002-IP-Trusted-Corporate-Network"
    IpRanges = @(
        @{ CIDRAddress = "192.0.2.0/24" }
        @{ CIDRAddress = "198.51.100.0/24" }
    )
}
```

### Naming convention

```text
CL{nnn}-{Type}-{Description}
```

Examples:

```text
CL001-CN-B-M365Apps-AllUsers-UnknownLocations&BouvetIsland
CL002-IP-Trusted-NZ-HQ
```

---

## Development workflows

### Add a new Conditional Access policy

1. Create a policy folder.

```powershell
New-Item -Path ".\data\ca_policies\CA123" -ItemType Directory
```

2. Copy the policy template.

```powershell
Copy-Item ".\Templates\CAPolicy_Skeleton.ps1" ".\data\ca_policies\CA123\CA123_Creation.ps1"
```

3. Define the policy parameters.

```powershell
$PolicyID = "CA123"
$DisplayName = "CA123-AllApps:RequireMFA-For:ExampleUsers-When:ExampleCondition"
$State = "enabledForReportingButNotEnforced"
```

4. Include standard exclusions.

```powershell
$ExcludedGroups = @(
    "EID-SEC-U-A-CAP-CA123-Exclude"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1"
    "EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2"
)
```

5. Add a policy `ReadMe.md`.

The policy documentation should explain:

- Why the policy exists
- Which users or personas it targets
- Which threats or risks it mitigates
- Which exclusions are configured
- How it should be tested before enforcement

6. Deploy in report-only mode first.

```powershell
.\scripts\main_script.ps1
```

7. Review sign-in logs and Conditional Access insights.

8. Move the policy to enforcement only after validation.

```powershell
$State = "enabled"
```

---

## Safe and unsafe changes

<table>
  <tr>
    <td width="50%">
      <h3>Safe changes</h3>
      <ul>
        <li>Changing policy state after validation</li>
        <li>Adding groups to policy-specific exclusions</li>
        <li>Updating named locations</li>
        <li>Updating policy documentation</li>
        <li>Adjusting conditions after controlled testing</li>
      </ul>
    </td>
    <td width="50%">
      <h3>Unsafe changes</h3>
      <ul>
        <li>Removing break-glass exclusions</li>
        <li>Deleting policy folders without planning rollback</li>
        <li>Hardcoding tenant-specific object IDs</li>
        <li>Changing Graph query logic without test deployment</li>
        <li>Enabling new controls without report-only validation</li>
      </ul>
    </td>
  </tr>
</table>

---

## Risk-based policy prerequisite

Risk-based Conditional Access policies require Entra ID P2.

This applies to policies such as:

```text
CA210
CA211
CA212
CA213
CA214
CA215
```

The scripts validate P2 support by checking subscribed SKUs and service plans for:

```text
AAD_PREMIUM_P2
```

---

## Troubleshooting

| Issue | What to check |
|---|---|
| Permission errors | Confirm Graph permissions and administrator consent |
| Wrong tenant | Disconnect from Graph and reconnect using the correct account |
| Group not found | Confirm policy folders exist before running group creation |
| Location ID resolution fails | Validate `.psd1` files with `Import-PowerShellDataFile` |
| Policy does not update | Confirm the display name matches exactly |
| Risk policy fails | Confirm Entra ID P2 is available and enabled |
| Policy impact uncertainty | Leave the policy in report-only mode and review sign-in logs |

---

## Key principles

<table>
  <tr>
    <td width="50%">
      <h3>Infrastructure-as-Code</h3>
      <p>Conditional Access policies and named locations are stored in Git for review, tracking, rollback, and repeatability.</p>
    </td>
    <td width="50%">
      <h3>Idempotency</h3>
      <p>Scripts check for existing resources and are designed to be safe to run multiple times.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>Progressive enforcement</h3>
      <p>Policies should be deployed in report-only mode first and enforced only after validation.</p>
    </td>
    <td width="50%">
      <h3>Break-glass priority</h3>
      <p>Emergency access groups are always treated as a priority exclusion to reduce lockout risk.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>Dynamic resolution</h3>
      <p>Group and location IDs are resolved dynamically at runtime instead of being hardcoded.</p>
    </td>
    <td width="50%">
      <h3>Strict sequencing</h3>
      <p>Supporting objects are created before policies to avoid dependency failures during deployment.</p>
    </td>
  </tr>
</table>

---

## References

- [Microsoft Graph Conditional Access API](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccess-overview)
- [Named locations in Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/location-condition)
- [Plan a Conditional Access deployment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access)

---

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f766e,100:1d4ed8&height=110&section=footer" />
</p>
