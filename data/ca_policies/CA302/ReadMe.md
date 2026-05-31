# CA302 - Require MFA for B2B Collaboration Guests

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA302 |
| **Display Name** | CA302-AllApps:RequireMFA-For:B2BCollaborationGuests-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Authentication |

---

## Business Objective

Require multi-factor authentication for B2B collaboration guest users accessing any application. The script intends to exclude trusted countries from this requirement, but a variable naming issue in the creation script means the location exclusion does not take effect — MFA is applied from all locations as scripted.

## Security Rationale

- **Threat Mitigated**: Credential compromise of B2B collaboration guest accounts
- **Attack Scenario**: Attacker obtains B2B guest credentials and attempts to sign in
- **Control Type**: Preventive (MFA via built-in control)
- **Risk Level**: High

---

## Policy Conditions

### Users
- **Included Guest/External Types**: `b2bCollaborationGuest`
- **External Tenants**: All (membershipKind = all)
- **Exclusion Groups**:
  - `EID-SEC-U-A-CAP-CA302-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All locations
- **Excluded**: Not applied — the script initialises `$ExcludedLocationIds = @()` and the location loop appends to `$LocationIds` (a different variable). The policy params reference `excludeLocations = $ExcludedLocationIds`, which remains empty. The CL002 location exclusion does not take effect as scripted.

**Note**: The intended behaviour (exclude CL002 trusted countries) is not achieved by the creation script as written. MFA is required for B2B collaboration guests from all locations.

---

## Grant Controls

| Control | Setting |
|---------|--------|
| **Operator** | OR |
| **Grant Type** | Multi-Factor Authentication (`builtInControls = "mfa"`) |

---

## User Impact
- B2B collaboration guests must complete MFA when accessing resources from any location
- The CL002 location exclusion does not take effect in the current script (see Locations note above)
- Setup: Guest users must register an MFA method (10–20 minutes)

---

## Dependent Resources

None. The CL002 location exclusion is referenced in the script but does not take effect due to a variable naming issue — the deployed policy does not exclude any named location.

---

## Testing Checklist

- [ ] B2B guests are prompted for MFA on sign-in from any location
- [ ] Break-glass accounts excluded and functional

---

## References

- **B2B Collaboration**: [Azure AD B2B](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/what-is-b2b)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: policy requires MFA for B2B guests using builtInControls (not authentication strength) |
| 1.2 | 2026-06-18 | Corrected: CL002 location exclusion does not take effect as scripted; policy applies MFA from all locations |
