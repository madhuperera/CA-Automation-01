# CA213 - Risky User (Low) Require MFA

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA213 |
| **Display Name** | CA213-AllApps:RequireMFA-For:Internals-When:RiskyUser:Low |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Risk-Based Access |
| **Risk Signal** | User risk (`low`) |
| **Applies To** | Internal users, all cloud apps |
| **Grant Controls** | Require MFA |
| **Session Controls** | None |

---

## Business Objective

Require MFA for internal users assessed as low user risk so suspicious accounts receive an additional verification step before risk escalates further.

---

## Security Rationale

Low user risk indicates early compromise signals may already exist against the account. Requiring MFA adds a verification step while avoiding the stronger disruption used at medium and high user-risk levels.

---

## License Prerequisite

The script validates Entra ID P2 capability by:

1. Filtering subscribed SKUs to those where `CapabilityStatus` is `Enabled`
2. Ensuring `PrepaidUnits.Enabled -gt 0`
3. Checking included `ServicePlans` for `ServicePlanName = AAD_PREMIUM_P2`

---

## Policy Conditions

### Users
- **Scope**: All users
- **Excluded**:
  - All guest and external user types
  - Privileged admin roles (16 built-in role IDs)
  - `EID-SEC-U-A-CAP-CA213-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All applications
- **Client App Types**: All

### Risk Condition
- **User Risk Levels**: `low`

### Locations and Devices
- Not configured — this policy does not use named locations, platforms, or device filters

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require MFA |

---

## User Impact

- Internal users with normal user risk are unaffected
- Internal users assessed as low user risk must complete MFA
- Break-glass accounts and excluded admin roles remain outside scope

---

## Testing Checklist

- [ ] Entra ID P2 capability is present in the tenant
- [ ] Low-risk users are challenged for MFA
- [ ] Normal-risk users are unaffected
- [ ] Admin roles are excluded
- [ ] Guest and external user types are excluded
- [ ] Break-glass accounts excluded and functional

---

## Rollout Notes

- Review Identity Protection detections in report-only mode before enforcement
- Confirm MFA registration coverage for the internal user population
- Roll out alongside CA214 and CA215 so user-risk responses remain consistent by severity

---

## Operational Cautions

- User risk is an Entra ID Identity Protection signal and may change over time without script changes
- This policy applies to all cloud apps once a user is classified as low risk
- Validate that operational teams understand the distinction between sign-in risk and user risk before enforcement

---

## References

- **Identity Protection**: [Entra ID Identity Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)
- **Risk-Based Policies**: [Configure user and sign-in risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial documentation |
| 1.1 | 2026-07-05 | Expanded exclusions, app scope, user impact, rollout notes, and operational cautions |
