# CA215 - Risky User (High) Require MFA + Password Reset + Every Sign-In

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA215 |
| **Display Name** | CA215-AllApps:RequireMFA+PwdReset+EverySignIn-For:Internals-When:RiskyUser:High |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Risk-Based Access |
| **Risk Signal** | User risk (`high`) |
| **Applies To** | Internal users, all cloud apps |
| **Grant Controls** | Require MFA and password change |
| **Session Controls** | Sign-in frequency: every time |

---

## Business Objective

Apply the strongest scripted remediation in this repository for internal users assessed as high user risk by requiring MFA, forcing password change, and requiring reauthentication on every sign-in.

---

## Security Rationale

High user risk suggests likely compromise. Requiring both MFA and password change helps re-establish trust in the account, while every-time sign-in frequency reduces the chance of continued token reuse during remediation.

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
  - `EID-SEC-U-A-CAP-CA215-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All applications
- **Client App Types**: All

### Risk Condition
- **User Risk Levels**: `high`

### Locations and Devices
- Not configured — this policy does not use named locations, platforms, or device filters

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | AND |
| **Grant Type** | Require MFA and password change |
| **Built-In Controls** | `mfa`, `passwordChange` |

## Session Controls

| Control | Setting |
|---------|---------|
| **Sign-In Frequency** | Every time |
| **Authentication Type** | Primary and secondary |
| **Enabled** | Yes |

---

## User Impact

- High-risk users must complete MFA and change their password before access is allowed
- Reauthentication is required on every sign-in while the policy conditions apply
- Break-glass accounts and excluded admin roles remain outside scope

---

## Testing Checklist

- [ ] Entra ID P2 capability is present in the tenant
- [ ] High-risk users are required to complete MFA
- [ ] Password change is required as part of remediation
- [ ] Sign-in frequency is enforced every time
- [ ] Admin roles are excluded
- [ ] Guest and external user types are excluded
- [ ] Break-glass accounts excluded and functional

---

## Rollout Notes

- Validate password reset and recovery processes before moving beyond report-only mode
- Coordinate with identity support teams because high-risk remediation can generate urgent user support demand
- Review CA213 and CA214 together so user-risk response severity is documented consistently

---

## Operational Cautions

- The script relies on Entra ID P2 user-risk capability; without it, the script exits and the policy is not created
- Password-change remediation may depend on broader tenant password reset and authentication method readiness that should be tested before enforcement
- This policy is intentionally disruptive and should only move from report-only after incident handling and support processes are proven

---

## References

- **Identity Protection**: [Entra ID Identity Protection](https://learn.microsoft.com/en-us/entra/id-protection/overview-identity-protection)
- **Risk-Based Policies**: [Configure user and sign-in risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial documentation |
| 1.1 | 2026-07-05 | Expanded exclusions, grant operator detail, user impact, rollout notes, and operational cautions |
