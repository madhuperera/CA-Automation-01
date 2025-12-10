# CA205 - Block Legacy Protocols for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA205 |
| **Display Name** | CA205-LegacyAuth:Block-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Authentication Security - Legacy Protocol |

---

## Business Objective

Block legacy authentication protocols (Basic Auth, IMAP, POP, SMTP) for internal users, forcing adoption of modern OAuth-based authentication.

## Security Rationale

- **Threat Mitigated**: Credential stuffing attacks exploiting legacy protocols with simple password auth
- **Attack Scenario**: Attacker uses list of compromised passwords against IMAP/POP endpoints
- **Control Type**: Preventive (blocks weak authentication flows)
- **Risk Level**: High

Legacy protocols do not support MFA, making them vulnerable to password attacks.

---

## Policy Conditions

### Users
- **Scope**: Internal users
- **Excluded**: Admins, guests

### Applications
- **Condition**: Legacy authentication flows

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Block |

---

## User Impact
- Users on old email clients must upgrade to modern clients (Outlook, Mail)
- Legacy mail forwarding apps need updating
- SMTP for printing/scanning needs alternative (print cloud)

---

## Testing Checklist

- [ ] Modern Outlook/Teams can access
- [ ] Old IMAP/POP mail clients blocked
- [ ] Identify legacy protocol users before enforcement

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Legacy Auth Blocking**: [Blocking Legacy Authentication](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-conditional-access-conditions#legacy-authentication)
- **Modern Auth**: [Migrate to modern authentication](https://learn.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/enable-or-disable-modern-authentication-in-exchange-online)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
