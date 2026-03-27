# CA210 - Require MFA on Low-Risk Sign-Ins for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA210 |
| **Display Name** | CA210-AllApps:RequireMFA-For:Internals-When:RiskySignIn:Low |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Identity Protection - Risk-Based Access Control |
| **License Requirement** | Entra ID P2 |

---

## Business Objective

Require MFA for internal users when a low-risk sign-in is detected by Entra ID Identity Protection, adding a verification step for suspicious but not critical sign-in events.

## Security Rationale

- **Threat Mitigated**: Credential compromise detected as low-risk by Identity Protection
- **Attack Scenario**: Attacker uses stolen credentials from a slightly unusual pattern (e.g. unfamiliar browser, atypical sign-in time)
- **Control Type**: Preventive (requires MFA to verify identity on low-risk sign-ins)
- **Risk Level**: Low-Medium

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types
  - Admin roles (16 built-in admin role IDs)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA210-Exclude`)

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Sign-In Risk
- **Risk Levels**: `low`

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require MFA |

---

## Prerequisites

This policy requires **Entra ID P2** licensing. The creation script checks for the following SKUs before deployment:
- AAD_PREMIUM_P2
- EMS_PREMIUM_P2
- ENTERPRISEPREMIUM
- M365EDU_A5_FACULTY
- M365EDU_A5_STUDENT

---

## User Impact
- Users with normal sign-ins are unaffected
- Users triggering low-risk signals are prompted for MFA
- Low-risk signals typically cause minimal disruption

---

## Related Policies

| Policy ID | Risk Level | Action |
|-----------|-----------|--------|
| CA210 | Low | Require MFA |
| CA211 | Medium | Require Compliant Device |
| CA212 | High | Block |

---

## Testing Checklist

- [ ] Entra ID P2 license is present in tenant
- [ ] Low-risk sign-ins trigger MFA prompt
- [ ] Normal sign-ins are unaffected
- [ ] Admin roles are excluded
- [ ] Guest users are excluded
- [ ] Break-glass accounts excluded and functional

---

## References

- **Identity Protection**: [Entra ID Identity Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)
- **Risk-Based Policies**: [Risk-Based Conditional Access](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Rewrote stub with full documentation matching PS1 script |

- [ ] Policy correctly identifies target users/devices
- [ ] Grant controls applied as expected
- [ ] No impact on break-glass accounts

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
