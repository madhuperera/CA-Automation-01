# CA300 - Block Unallowed Guest User Types

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA300 |
| **Display Name** | CA300-AllApps:BlockGuestTypes-For:ExternalUsers-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control |

---

## Business Objective

Block access from guest and external user types that don't meet organizational standards, restricting M365 access to member accounts only.

## Security Rationale

- **Threat Mitigated**: Unauthorized external collaboration, shadow IT
- **Attack Scenario**: Attacker gains guest account access from social engineering attack
- **Control Type**: Preventive (blocks guest/external user access)
- **Risk Level**: Medium

Restricts external access to vetted member accounts only. Guest types (OrgDbGuest, PartnerTenant) are blocked.

---

## Blocked User Types
- **OrgDbGuest**: Organization's database guest accounts
- **PartnerTenant**: Guest users from partner organizations

---

## Allowed User Types
- **Member**: Internal organization accounts
- **ServicePrincipal**: Service accounts

---

## User Impact
- External collaborators must use guest invitations (if allowed by separate policy)
- Personal account access blocked
- B2B collaboration controlled

---

## Testing Checklist

- [ ] Internal users unaffected
- [ ] Guest users appropriately blocked
- [ ] Service accounts continue working
- [ ] Test with actual guest account to verify blocking

---

## References

- **Guest Access**: [Azure AD B2B Collaboration](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/what-is-b2b)
- **User Types**: [Guest vs Member Accounts](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/user-types)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
