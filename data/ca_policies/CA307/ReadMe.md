# CA307 - Block Legacy Authentication for All Guests

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA307 |
| **Display Name** | CA307-AllApps:Block-For:AllGuests-When:LegacyProtocols |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Authentication |

---

## Business Objective

Block all guest and external user types from accessing any application when using legacy authentication client types, enforcing modern authentication for external identities across the organisation.

## Security Rationale

- **Threat Mitigated**: Credential compromise via legacy authentication protocols that cannot negotiate modern security controls
- **Attack Scenario**: Guest account credentials obtained by attacker who uses a legacy mail client or protocol that bypasses MFA
- **Control Type**: Preventive (blocks access via legacy client app types)
- **Risk Level**: Medium-High

---

## Policy Conditions

### Users
- **Included Guest/External Types**: All guest and external user types:
  - `internalGuest`
  - `b2bCollaborationGuest`
  - `b2bCollaborationMember`
  - `b2bDirectConnectUser`
  - `otherExternalUser`
  - `serviceProvider`
- **External Tenants**: All (membershipKind = all)
- **Exclusion Groups**:
  - `EID-SEC-U-A-CAP-CA307-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All Applications
- **Client App Types**: `exchangeActiveSync`, `other` (legacy authentication client types only)

### Locations
- Not configured (applies from any network)

### Devices
- Not configured

---

## Grant Controls

| Control | Setting |
|---------|--------|
| **Operator** | OR |
| **Grant Type** | Block |

---

## User Impact
- Guests using modern authentication clients (browser, modern Outlook, MSAL-based apps) are unaffected
- Guests using Exchange ActiveSync or other legacy auth clients are blocked
- Legacy mail clients (older Outlook versions, basic-auth mobile clients) will stop working for guest accounts

---

## Dependent Resources

None. This policy does not rely on named locations, groups, or external configuration beyond the standard exclusion groups.

---

## Testing Checklist

- [ ] Guest users with modern authentication clients can access resources normally
- [ ] Guest users attempting legacy auth (EAS, other) are blocked
- [ ] Internal users are not affected by this policy
- [ ] Break-glass accounts excluded and functional

---

## References

- **Legacy Authentication**: [Block legacy authentication with Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/block-legacy-authentication)
- **Client App Types**: [Conditional Access: Client app conditions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions#client-apps)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected display name, updated policy conditions to reflect all guest types and actual client app types |
