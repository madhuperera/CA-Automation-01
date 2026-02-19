# CA215 - Risky User (High) Require MFA + Password Reset + Every Sign-In

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA215 |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Risk-Based Access |
| **Risk Signal** | User risk (`high`) |
| **Applies To** | Internal users, all cloud apps |
| **Grant Controls** | Require MFA + Password reset |
| **Session Controls** | Sign-in frequency: every time |

---

## Business Objective

Apply strongest remediation for high-risk users before access is allowed.

---

## Security Rationale

High user risk suggests probable compromise. Requiring both MFA and password change with per-sign-in validation forces account recovery and reduces persistence risk.

---

## License Prerequisite

The script validates Entra ID P2 capability by:

1. Filtering subscribed SKUs to those where `CapabilityStatus` is `Enabled`
2. Ensuring `PrepaidUnits.Enabled -gt 0`
3. Checking included `ServicePlans` for `ServicePlanName = AAD_PREMIUM_P2`

---

## Policy Conditions

- Include users: `All`
- Exclude groups: policy exclusion group + two emergency break-glass groups
- Exclude guest/external user types
- Exclude privileged admin roles
- Condition: `userRiskLevels = high`
- Grant: `mfa` AND `passwordChange`
- Session: `signInFrequency = everyTime`

---

## Testing Checklist

- [ ] Policy correctly identifies high-risk users for internal population
- [ ] MFA and password-change controls are both required
- [ ] Sign-in frequency is enforced every time
- [ ] No impact on break-glass accounts

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial documentation |
