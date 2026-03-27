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

Require multi-factor authentication (via authentication strength) for B2B collaboration guest users accessing any application, with an exclusion for trusted countries.

## Security Rationale

- **Threat Mitigated**: Credential compromise of B2B collaboration guest accounts
- **Attack Scenario**: Attacker obtains B2B guest credentials and attempts to sign in
- **Control Type**: Preventive (MFA via authentication strength)
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
- **Excluded**: `CL002-CN-A-AllApps-B2BCollaborationGuests-TrustedCountries` (trusted countries for B2B guests)

---

## Grant Controls

| Control | Setting |
|---------|--------|
| **Operator** | OR |
| **Grant Type** | Authentication Strength — Multi-Factor Authentication |
| **Auth Strength ID** | `00000000-0000-0000-0000-000000000002` (built-in MFA strength) |

---

## User Impact
- B2B collaboration guests must complete MFA when accessing resources
- Guests signing in from trusted countries (CL002) are excluded from this requirement
- Setup: Guest users must register an MFA method (10–20 minutes)

---

## Dependent Resources

| Resource | Name | Purpose |
|----------|------|---------|
| Named Location | `CL002-CN-A-AllApps-B2BCollaborationGuests-TrustedCountries` | Defines countries excluded from MFA requirement |

---

## Testing Checklist

- [ ] B2B guests are prompted for MFA on sign-in
- [ ] B2B guests from trusted countries (CL002) bypass MFA requirement
- [ ] Authentication strength enforces acceptable MFA methods
- [ ] Break-glass accounts excluded and functional

---

## References

- **Authentication Strength**: [Conditional Access Authentication Strength](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
- **B2B Collaboration**: [Azure AD B2B](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/what-is-b2b)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: policy requires MFA for B2B guests (not country restriction) |
