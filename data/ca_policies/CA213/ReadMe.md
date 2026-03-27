# CA213 - Risky User (Low) Require MFA

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA213 |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Risk-Based Access |
| **Risk Signal** | User risk (`low`) |
| **Applies To** | Internal users, all cloud apps |
| **Grant Controls** | Require MFA |
| **Session Controls** | None |

---

## Business Objective

Require MFA for users assessed as low risk to reduce account takeover exposure while preserving usability.

---

## Security Rationale

User risk combines identity protection signals over time. Applying MFA at low user risk adds assurance before risk increases further.

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
- Condition: `userRiskLevels = low`
- Grant: `mfa`

---

## Testing Checklist

- [ ] Policy correctly identifies low-risk users for internal population
- [ ] MFA challenge is applied
- [ ] No impact on break-glass accounts

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial documentation |
