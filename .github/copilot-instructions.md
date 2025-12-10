# CA-Automation-01 Codebase Guide

## Repository Overview
This repository automates **Entra ID Conditional Access (CA) policy** creation and management at scale. It's a **PowerShell-driven** framework that declaratively deploys CA policies, named locations (geographic restrictions), security groups, and emergency break-glass accounts to a Microsoft 365 tenant via Microsoft Graph API.

**Key Principle**: Infrastructure-as-Code for identity security—policies are defined as `.ps1` files in data folders, then orchestrated through a single entry point (`main_script.ps1`).

---

## Architecture & Data Flow

### 1. **Orchestration Pattern** (`scripts/main_script.ps1`)
Single entry point that sequences dependent operations in order:
```
Connect to Microsoft Graph → Known Locations → Break-Glass Groups → 
Exclusion Groups → CA Policies
```

**Why this order?**
- Locations must exist before policies reference them
- Security groups must exist before policies can exclude them
- Break-glass accounts get priority (always excluded from CA policies)

### 2. **Script Patterns** (All in `scripts/`)
Each script follows a **discovery-and-apply** model:

- **`create_known_locations.ps1`**: 
  - Scans `data/known_locations/*.psd1` files (PowerShell Data Files)
  - Each `.psd1` contains named location definition (geographic/IP-based restriction)
  - Updates existing locations, creates new ones via `New-MgIdentityConditionalAccessNamedLocation`

- **`create_break_glass_groups.ps1`**:
  - Hardcoded list of break-glass group names (`EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount[1-2]`)
  - Creates security groups if missing; these are **always excluded** from all CA policies
  
- **`create_groups.ps1`**:
  - Auto-generates exclusion groups for EACH CA policy: `EID-SEC-U-A-CAP-{POLICY_ID}-Exclude`
  - Enables per-policy exception management (e.g., service accounts, privileged users)

- **`create_ca_policies.ps1`**:
  - Discovers all `.ps1` files in `data/ca_policies/` (one file per policy)
  - Executes each policy file in sequence; each file is self-contained

### 3. **Policy Definition Model** (`data/ca_policies/{CAxxxxx}/CAxxxxx_Creation.ps1`)
Each policy is a standalone PowerShell script that:
1. Defines policy parameters (name, state, conditions)
2. **Resolves group/location IDs** by querying Microsoft Graph (not hardcoded)
3. Creates or updates policy using `New/Update-MgIdentityConditionalAccessPolicy`

**State Pattern**: Policies use `"enabledForReportingButNotEnforced"` (audit mode) before enforcement.

---

## Key Files & Naming Conventions

| Component | Location | Pattern | Purpose |
|-----------|----------|---------|---------|
| **Named Locations** | `data/known_locations/` | `CL{nnn}.psd1` | IP ranges/country restrictions |
| **CA Policies** | `data/ca_policies/{CA###}/` | `CA{nnn}_Creation.ps1` + `ReadMe.md` | Policy definition & documentation |
| **Exclusion Groups** | Auto-generated in Entra | `EID-SEC-U-A-CAP-{CA###}-Exclude` | Per-policy exception members |
| **Break-Glass Groups** | Auto-generated in Entra | `EID-SEC-U-A-ROLE-EmergencyBreakGlass*` | Always-excluded admin accounts |
| **Template** | `Templates/` | `CAPolicy_Skeleton.ps1` | Reference structure for new policies |

---

## Development Workflows

### Adding a New Conditional Access Policy
1. **Create policy folder**: `data/ca_policies/CA{nnn}/` (use next available number)
2. **Create policy file** from template: `CAPolicy_Skeleton.ps1` → `CA{nnn}_Creation.ps1`
3. **Define policy parameters**:
   - `$DisplayName`: Use format `{POLICY_ID}-{Threat/Control}-For:{Users}-When:{Conditions}`
   - `$State`: Use `"enabledForReportingButNotEnforced"` (audit first)
   - `$IncludedUsers`, `$ClientAppTypes`, `$IncludedApplications`, `$IncludedLocations` (if needed)
4. **Query for group/location IDs** (don't hardcode):
   ```powershell
   $locationId = Get-MgIdentityConditionalAccessNamedLocation -Filter "displayName eq '$location'" | Select-Object -ExpandProperty Id
   ```
5. **Always include exclusions**:
   - Policy-specific exclusion group: `EID-SEC-U-A-CAP-{CAxxxxx}-Exclude`
   - Both break-glass groups
6. **Add documentation**: Create `ReadMe.md` in policy folder explaining business logic
7. **Test**: Run `main_script.ps1` in reporting mode before enforcement

### Adding a New Named Location
1. Create `.psd1` file in `data/known_locations/` following pattern: `CL{nnn}.psd1`
2. Define hash table with Microsoft Graph `NamedLocation` properties:
   ```powershell
   @{
       DisplayName = "CL{nnn}-{Description}"
       OdataType = "#microsoft.graph.ipNamedLocation"
       IpRanges = @( @{ CIDRAddress = "xxx.xxx.xxx.xxx/xx" }, ... )
   }
   ```
3. File will be auto-discovered and imported by `create_known_locations.ps1`

### Modifying Existing Policies
- **Never delete** `.ps1` files from `data/ca_policies/` (breaks tracking)
- **Update state**: Change `$State = "enabled"` to enforce (after validation in reporting mode)
- **Add exclusions**: Append to `$ExcludedGroups` array
- **Modify conditions**: Edit `$params.conditions` object before Graph API call
- Always test in a non-production tenant first

---

## Critical Patterns & Conventions

### 1. **Microsoft Graph API Usage**
- All scripts require `Connect-MgGraph -Scopes {...}` (already done in `main_script.ps1`)
- Required scopes: `Policy.ReadWrite.ConditionalAccess`, `Group.ReadWrite.All`, `Application.Read.All`
- ID resolution pattern: Always query by display name, extract ID, then reference ID in API calls
  ```powershell
  $Id = Get-Mg* -Filter "displayName eq '$Name'" | Select-Object -ExpandProperty Id
  ```

### 2. **Error Handling**
- Scripts use `-ErrorAction Stop` on critical operations to prevent partial deployments
- Idempotent checks prevent duplicate creation:
  ```powershell
  if (Get-MgGroup -Filter "displayName eq '$GroupName'" -ErrorAction SilentlyContinue) { ... }
  ```

### 3. **Progress Indication**
- Multi-item operations use `Write-Progress` with percentage completion
- Helps monitor long-running policy batches

### 4. **State Management**
- **Audit mode**: `enabledForReportingButNotEnforced` - policy tracked but not enforced
- **Enforcement**: `enabled` - policy actively blocks/allows actions
- Break-glass groups ALWAYS excluded to prevent lockout scenarios

---

## Running & Debugging

### Prerequisites
- PowerShell 7+ (cross-platform) or Windows PowerShell 5.1+
- Interactive login (requires user consent for Graph API scopes)
- Entra ID Global Administrator or Conditional Access Administrator role

### Execution
```powershell
cd scripts
.\main_script.ps1
# Script will:
# - Connect to Graph (prompts for MFA)
# - Show current tenant (60-second confirmation pause)
# - Execute ordered sub-scripts
```

### Testing Single Component
```powershell
# Test just known locations
.\scripts\create_known_locations.ps1

# Test just policies  
.\scripts\create_ca_policies.ps1
```

### Troubleshooting
- **Group creation fails**: Ensure `MailNickname` is unique (hint: use policy ID)
- **Location not found in policy**: Verify `data/known_locations/` file exists and runs first
- **Policy update fails**: Check policy `displayName` matches exactly (case-sensitive?)
- **Missing scopes**: Re-run `Connect-MgGraph -Scopes ...` with required scopes list

---

## Important Notes

⚠️ **AI-Generated Content**: README and some templates were generated by language models—verify logic before production deployment

- **No rollback mechanism**: Policies deployed via Graph API must be manually deleted in Entra
- **Idempotency**: All scripts safely re-run (won't create duplicates)
- **Naming conventions**: Strictly follow `EID-SEC-U-A-*` prefix for group discoverability
- **Testing strategy**: Always deploy in `enabledForReportingButNotEnforced` state first; validate 24-48 hours before `enabled`
- **Break-glass importance**: Never deploy policies without break-glass group exclusions

---

## Key Files to Reference

| File | Purpose |
|------|---------|
| `scripts/main_script.ps1` | Entry point, orchestrates execution order |
| `data/ca_policies/CA001/CA001_Creation.ps1` | Example policy (reference implementation) |
| `Templates/CAPolicy_Skeleton.ps1` | Template for new policies |
| `data/known_locations/` | Geographic/IP restrictions (discovery-based) |
