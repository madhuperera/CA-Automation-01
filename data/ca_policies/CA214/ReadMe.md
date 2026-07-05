# CA214 - Risky User (Medium) Require MFA + Every Sign-In

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA214 |
| **Display Name** | CA214-AllApps:RequireMFA+EverySignIn-For:Internals-When:RiskyUser:Medium |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Risk-Based Access |
| **Risk Signal** | User risk (`medium`) |
| **Applies To** | Internal users, all cloud apps |
| **Grant Controls** | Require MFA |
| **Session Controls** | Sign-in frequency: every time |

---

## Business Objective

Require MFA and force reauthentication on every sign-in for internal users assessed as medium user risk.

---

## Security Rationale

Medium user risk indicates stronger compromise indicators than the low-risk scenario. Combining MFA with every-time sign-in frequency reduces token persistence and increases assurance before access continues.

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
  - `EID-SEC-U-A-CAP-CA214-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All applications
- **Client App Types**: All

### Risk Condition
- **User Risk Levels**: `medium`

### Locations and Devices
- Not configured — this policy does not use named locations, platforms, or device filters

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

- Medium-risk users must complete MFA on every sign-in
- Token reuse is reduced because repeated reauthentication is enforced
- Break-glass accounts and excluded admin roles remain outside scope

---

## Testing Checklist

- [ ] Entra ID P2 capability is present in the tenant
- [ ] Medium-risk users are challenged for MFA
- [ ] Sign-in frequency is enforced every time
- [ ] Normal and low-risk users are unaffected by this policy
- [ ] Admin roles are excluded
- [ ] Guest and external user types are excluded
- [ ] Break-glass accounts excluded and functional

---

## Rollout Notes

- Start in report-only mode and review medium-risk events in Identity Protection and Conditional Access reporting
- Coordinate user communications because every-time reauthentication is more disruptive than CA213
- Keep CA213, CA214, and CA215 aligned so each user-risk severity has a clear remediation path

---

## Operational Cautions

- User risk is calculated dynamically by Entra ID and can change independently of repository changes
- Every-time sign-in frequency can materially increase user friction during genuine medium-risk investigations
- Confirm support teams can distinguish user-risk remediation from device or location-based policy failures

---

## References

- **Identity Protection**: [Entra ID Identity Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)
- **Risk-Based Policies**: [Configure user and sign-in risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial documentation |
| 1.1 | 2026-07-05 | Expanded exclusions, session control detail, user impact, rollout notes, and operational cautions |
