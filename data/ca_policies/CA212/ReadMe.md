# CA212 - Block High-Risk Sign-Ins for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA212 |
| **Display Name** | CA212-AllApps:Block-For:Internals-When:RiskySignIn:High |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Identity Protection - Risk-Based Access Control |
| **License Requirement** | Entra ID P2 |

---

## Business Objective

Block internal users when a high-risk sign-in is detected by Entra ID Identity Protection, preventing access entirely for the most suspicious sign-in events.

## Security Rationale

- **Threat Mitigated**: Credential compromise detected as high-risk by Identity Protection
- **Attack Scenario**: Attacker uses stolen credentials with strong indicators of compromise (e.g. known malicious IP, leaked credentials, token anomaly)
- **Control Type**: Preventive (blocks access entirely on high-risk sign-ins)
- **Risk Level**: High

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types
  - Admin roles (16 built-in admin role IDs)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA212-Exclude`)

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Sign-In Risk
- **Risk Levels**: `high`

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Block |

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
- Users with normal, low, or medium-risk sign-ins are unaffected
- Users triggering high-risk signals are blocked entirely
- Blocked users must contact IT/security for investigation and remediation

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
- [ ] High-risk sign-ins are blocked
- [ ] Normal, low, and medium-risk sign-ins are unaffected by this policy
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
