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

## User Impact
- Users with normal, low, or medium-risk sign-ins are unaffected
- Users triggering high-risk signals are blocked entirely
- Blocked users must contact IT/security for investigation and remediation

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
| 1.1 | 2026-02-20 | Updated to risk-based sign-in documentation and P2 validation logic |
| 1.2 | 2026-03-27 | Expanded with full policy conditions, grant controls, and testing checklist |
