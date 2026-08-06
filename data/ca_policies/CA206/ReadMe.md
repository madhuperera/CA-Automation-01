# CA206 - Require MFA for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA206 |
| **Display Name** | CA206-AllApps:RequireMFA-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Authentication Security - MFA Enforcement |
| **Applies To** | Internal users, all cloud apps, all client app types |
| **Grant Controls** | Require MFA |
| **Session Controls** | None |

---

## Business Objective

Require MFA for internal users across all cloud apps to reduce password-only sign-in risk and raise the baseline authentication standard.

---

## Security Rationale

- **Threat Mitigated**: Account takeover through compromised passwords
- **Attack Scenario**: An attacker obtains a user password and attempts to sign in without a second factor
- **Control Type**: Preventive (requires step-up verification before access is granted)
- **Risk Level**: High

---

## Policy Conditions

### Users
- **Scope**: All users
- **Excluded**:
  - All guest and external user types
  - Privileged admin roles (16 built-in role IDs)
  - `EID-SEC-U-A-CAP-CA206-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All applications
- **Client App Types**: All

### Locations
- Not configured — applies from any network

### Devices
- Not configured — no device filter or platform restriction

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Multifactor Authentication (`mfa`) |

---

## User Impact

- Internal users must complete MFA when policies evaluate access to any cloud app
- Admin-role users are intentionally excluded because separate admin-focused policies cover them
- Guest and external accounts are excluded because this policy is for internal identities only

---

## Testing Checklist

- [ ] Internal users are prompted for MFA
- [ ] All cloud apps are in scope as expected
- [ ] Admin roles are excluded
- [ ] Guest and external user types are excluded
- [ ] Break-glass accounts excluded and functional

---

## Rollout Notes

- Keep the policy in report-only mode first and review sign-in logs for applications with heavy MFA impact
- Confirm users have at least one supported MFA method registered before enforcement
- Coordinate rollout with helpdesk teams because this policy affects broad internal access

---

## Operational Cautions

- This policy applies to all cloud apps, not only Microsoft 365 workloads
- Legacy applications, automation, or service scenarios that still depend on password-only sign-in may surface during report-only review
- Validate exclusion group membership carefully before enforcement

---

## References

- **Conditional Access**: [Conditional Access policy overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- **MFA Registration**: [Require users to register for MFA](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-mfa-userstates)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-07-05 | Corrected app scope to all cloud apps and expanded exclusions, testing, rollout, and cautions |
