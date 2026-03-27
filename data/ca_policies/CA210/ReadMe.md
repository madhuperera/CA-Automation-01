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

## License Prerequisite

The script validates Entra ID P2 capability by:

1. Filtering subscribed SKUs to those where `CapabilityStatus` is `Enabled`
2. Ensuring `PrepaidUnits.Enabled -gt 0`
3. Checking included `ServicePlans` for `ServicePlanName = AAD_PREMIUM_P2`

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

## User Impact
- Users with normal sign-ins are unaffected
- Users triggering low-risk signals are prompted for MFA
- Low-risk signals typically cause minimal disruption

---

## Related Policies

| Policy ID | Risk Level | Action |
|-----------|-----------|--------|
| CA210 | Low | Require MFA |
| CA211 | Medium | Require MFA + Every Sign-In |
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
| 1.1 | 2026-02-20 | Updated to risk-based sign-in documentation and P2 validation logic |
| 1.2 | 2026-03-27 | Expanded with full policy conditions, grant controls, and testing checklist |
