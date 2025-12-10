# CA303 - MFA for External Collaboration

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA303 |
| **Display Name** | CA303-AllApps:RequireMFA-For:ExternalUsers-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Authentication |

---

## Business Objective

Require multi-factor authentication for guest and external user access to protect shared resources.

## Security Rationale

- **Threat Mitigated**: Credential compromise of guest accounts
- **Attack Scenario**: Attacker uses stolen guest credentials
- **Control Type**: Preventive (MFA required)
- **Risk Level**: High

---

## MFA Methods Required
- Microsoft Authenticator (preferred)
- FIDO2 keys
- Phone sign-in
- SMS/Voice call (minimum acceptable)

---

## User Impact
- External users must register MFA method
- Setup: 10-20 minutes
- Ongoing access requires MFA

---

## Testing Checklist

- [ ] Guest users can register MFA
- [ ] MFA required on each sign-in
- [ ] All MFA methods available

---

## References

- **MFA**: [Microsoft Authenticator](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-authentication-authenticator-app)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
