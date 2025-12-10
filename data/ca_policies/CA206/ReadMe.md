# CA206 - Require MFA for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA206 |
| **Display Name** | CA206-AllApps:RequireMFA-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Authentication Security - MFA Enforcement |

---

## Business Objective

Enforce multi-factor authentication for all internal users accessing Microsoft 365, preventing account takeover via password compromise.

## Security Rationale

- **Threat Mitigated**: Account takeover via compromised passwords
- **Attack Scenario**: Attacker obtains user password and attempts to sign in without additional factor
- **Control Type**: Preventive (forces second authentication factor)
- **Risk Level**: High

---

## Policy Conditions

### Users
- **Scope**: Internal users
- **Excluded**: Admins, guests, break-glass accounts

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Multifactor Authentication |

---

## User Impact
- All internal users must register MFA method
- Setup: 5 minutes for authenticator app
- Ongoing: 10-30 seconds per sign-in for MFA

---

## Testing Checklist

- [ ] Internal users can register MFA
- [ ] MFA is working (authenticator, phone, etc.)
- [ ] Non-MFA users have fallback options

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **MFA Methods**: [MFA Registration](https://learn.microsoft.com/en-us/azure/active-directory/user-help/multi-factor-authentication-end-user-first-time)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
