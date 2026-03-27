# CA211 - Require Compliant Device on Medium-Risk Sign-Ins for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA211 |
| **Display Name** | CA211-AllApps:Compliant-For:Internals-When:RiskySignIn:Medium |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Identity Protection - Risk-Based Access Control |
| **License Requirement** | Entra ID P2 |

---

## Business Objective

Require internal users to access from a compliant device when a medium-risk sign-in is detected by Entra ID Identity Protection, escalating the security requirement beyond MFA for more suspicious sign-in events.

## Security Rationale

- **Threat Mitigated**: Credential compromise detected as medium-risk by Identity Protection
- **Attack Scenario**: Attacker uses stolen credentials from a moderately suspicious pattern (e.g. impossible travel, unfamiliar IP, anonymous IP)
- **Control Type**: Preventive (requires compliant device to verify trusted endpoint on medium-risk sign-ins)
- **Risk Level**: Medium

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types
  - Admin roles (16 built-in admin role IDs)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA211-Exclude`)

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Sign-In Risk
- **Risk Levels**: `medium`

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require Compliant Device |

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
- Users with normal or low-risk sign-ins are unaffected
- Users triggering medium-risk signals must use a compliant device
- Users on unmanaged devices during a medium-risk event will be blocked

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
- [ ] Medium-risk sign-ins require compliant device
- [ ] Normal and low-risk sign-ins are unaffected by this policy
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

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
