# CA300 - Block Unallowed Guest and External User Types

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA300 |
| **Display Name** | CA300-AllApps:Block-For:UnallowedGuestTypes-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control |

---

## Business Objective

Block access from guest and external user types that are not explicitly approved for collaboration, while allowing B2B Collaboration Guests and Service Provider users to continue accessing resources.

## Security Rationale

- **Threat Mitigated**: Unauthorized external collaboration from unapproved guest types
- **Attack Scenario**: Attacker gains access via an unvetted external user type (e.g. internal guest, B2B direct connect, other external user)
- **Control Type**: Preventive (blocks unapproved guest/external user types)
- **Risk Level**: Medium

---

## Policy Conditions

### Users
- **Included Guest/External Types** (targeted by policy):
  - `internalGuest`
  - `b2bCollaborationGuest`
  - `b2bCollaborationMember`
  - `b2bDirectConnectUser`
  - `otherExternalUser`
  - `serviceProvider`
- **Excluded Guest/External Types** (allowed through):
  - `b2bCollaborationGuest` — Standard B2B collaboration guests
  - `serviceProvider` — Cloud Service Provider (CSP) users
- **External Tenants**: All (membershipKind = all)
- **Exclusion Groups**:
  - `EID-SEC-U-A-CAP-CA300-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Net Effect
The following guest types are **blocked**:
- `internalGuest` — Internal guest accounts
- `b2bCollaborationMember` — B2B collaboration members
- `b2bDirectConnectUser` — B2B direct connect users
- `otherExternalUser` — Other external users

The following guest types are **allowed**:
- `b2bCollaborationGuest` — Standard invited B2B guests
- `serviceProvider` — CSP/partner service provider accounts

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- Not configured (applies from any network)

---

## Grant Controls

| Control | Setting |
|---------|--------|
| **Operator** | OR |
| **Grant Type** | Block |

---

## User Impact
- B2B collaboration guests and service providers can continue accessing resources
- Internal guest accounts, B2B direct connect users, and other external user types are blocked
- Affected users must be invited as standard B2B collaboration guests to gain access

---

## Testing Checklist

- [ ] Internal users unaffected
- [ ] B2B collaboration guests can access normally
- [ ] Service provider users can access normally
- [ ] Internal guest accounts are blocked
- [ ] B2B direct connect users are blocked
- [ ] Other external user types are blocked
- [ ] Break-glass accounts excluded and functional

---

## References

- **Guest Access**: [Azure AD B2B Collaboration](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/what-is-b2b)
- **User Types**: [Guest vs Member Accounts](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/user-types)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected to match actual policy: display name, guest types, and grant controls |
