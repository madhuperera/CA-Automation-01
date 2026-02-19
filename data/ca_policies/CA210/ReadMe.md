# CA210 - Risky Sign-In (Low) Require MFA

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA210 |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Risk-Based Access |
| **Risk Signal** | Sign-in risk (`low`) |
| **Applies To** | Internal users, all cloud apps |
| **Grant Controls** | Require MFA |
| **Session Controls** | None |

---

## Business Objective

Prompt for MFA when a sign-in is assessed as low risk, to add a lightweight verification step.

## Security Rationale

Balances user experience with risk reduction by applying MFA only when sign-in risk is detected.

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
- Condition: `signInRiskLevels = low`
- Grant: `mfa`

---

## Testing Checklist

- [ ] Policy correctly identifies low-risk sign-ins for internal users
- [ ] MFA challenge is applied
- [ ] No impact on break-glass accounts

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-02-20 | Updated to risk-based sign-in documentation and service-plan P2 validation logic |
