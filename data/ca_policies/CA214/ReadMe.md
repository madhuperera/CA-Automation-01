# CA214 - Risky User (Medium) Require MFA + Every Sign-In

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA214 |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Risk-Based Access |
| **Risk Signal** | User risk (`medium`) |
| **Applies To** | Internal users, all cloud apps |
| **Grant Controls** | Require MFA |
| **Session Controls** | Sign-in frequency: every time |

---

## Business Objective

Enforce stronger controls for medium-risk users using MFA and per-sign-in reauthentication.

---

## Security Rationale

Medium user risk indicates elevated compromise probability. Every-time sign-in frequency reduces the chance of long-lived token abuse.

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
- Condition: `userRiskLevels = medium`
- Grant: `mfa`
- Session: `signInFrequency = everyTime`

---

## Testing Checklist

- [ ] Policy correctly identifies medium-risk users for internal population
- [ ] MFA challenge is applied
- [ ] Sign-in frequency is enforced every time
- [ ] No impact on break-glass accounts

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial documentation |
