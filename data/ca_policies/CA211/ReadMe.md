# CA211 - Risky Sign-In (Medium) Require MFA + Every Sign-In

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA211 |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Risk-Based Access |
| **Risk Signal** | Sign-in risk (`medium`) |
| **Applies To** | Internal users, all cloud apps |
| **Grant Controls** | Require MFA |
| **Session Controls** | Sign-in frequency: every time |

---

## Business Objective

Enforce stronger interactive verification for medium-risk sign-ins by combining MFA with every-time reauthentication.

---

## Security Rationale

Medium sign-in risk indicates elevated uncertainty. Requiring MFA and sign-in each time limits token persistence and reduces takeover risk.

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
- Condition: `signInRiskLevels = medium`
- Grant: `mfa`
- Session: `signInFrequency = everyTime`

---

## Testing Checklist

- [ ] Policy correctly identifies medium-risk sign-ins for internal users
- [ ] MFA challenge is applied
- [ ] Sign-in frequency is enforced every time
- [ ] No impact on break-glass accounts

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-02-20 | Updated controls to MFA + every-time sign-in and service-plan P2 validation logic |
