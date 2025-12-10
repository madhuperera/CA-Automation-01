# CA307 - Restrict Legacy Apps for Guest Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA307 |
| **Display Name** | CA307-AllApps:BlockLegacyApps-For:Guests-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Application |

---

## Business Objective

Block guest user access to legacy applications, enforcing modern authentication protocols.

## Security Rationale

- **Threat Mitigated**: Access using legacy authentication (IMAP, POP, basic auth)
- **Attack Scenario**: Guest account compromised via password attack on legacy protocol
- **Control Type**: Preventive (legacy protocols blocked)
- **Risk Level**: Medium-High

---

## Blocked Legacy Protocols
- IMAP/IMAPS
- POP3/POP3S
- SMTP
- Basic Authentication
- Exchange Web Services (EWS)
- Offline Address Book (OAB)

---

## Required Modern Protocols
- Modern Authentication (ADAL/MSAL)
- OAuth 2.0
- SAML 2.0

---

## User Impact
- Legacy mail clients (Outlook 2010, etc.) blocked for guests
- Modern Outlook apps required (Outlook 2016+, Outlook Web)
- Mobile apps work with modern auth

---

## Testing Checklist

- [ ] Guest users can access with modern clients
- [ ] Legacy clients properly blocked
- [ ] Mobile apps unaffected

---

## References

- **Modern Authentication**: [Modern Authentication](https://learn.microsoft.com/en-us/microsoft-365/enterprise/modern-auth-for-office-2013-and-2016?view=o365-worldwide)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
