# CA211 - Require MFA + Every Sign-In on Medium-Risk Sign-Ins for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA211 |
| **Display Name** | CA211-AllApps:RequireMFA+EverySignIn-For:Internals-When:RiskySignIn:Medium |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Identity Protection - Risk-Based Access Control |
| **License Requirement** | Entra ID P2 |

---

## Business Objective

Enforce stronger interactive verification for medium-risk sign-ins by combining MFA with every-time reauthentication, limiting token persistence for internal users when Identity Protection detects elevated risk.

## Security Rationale

- **Threat Mitigated**: Credential compromise detected as medium-risk by Identity Protection
- **Attack Scenario**: Attacker uses stolen credentials from a moderately suspicious pattern (e.g. impossible travel, unfamiliar IP, anonymous IP)
- **Control Type**: Preventive (requires MFA and forces reauthentication every time on medium-risk sign-ins)
- **Risk Level**: Medium

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
| **Grant Type** | Require MFA |

## Session Controls

| Control | Setting |
|---------|---------|
| **Sign-In Frequency** | Every time |
| **Authentication Type** | Primary and secondary |
| **Enabled** | Yes |

---

## User Impact
- Users with normal or low-risk sign-ins are unaffected
- Users triggering medium-risk signals must complete MFA and reauthenticate every session
- Token caching is disabled during medium-risk events to limit exposure window

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
- [ ] Medium-risk sign-ins trigger MFA prompt
- [ ] Sign-in frequency is enforced every time
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
| 1.1 | 2026-02-20 | Updated controls to MFA + every-time sign-in and P2 validation logic |
| 1.2 | 2026-03-27 | Expanded with full policy conditions, session controls, and testing checklist |
