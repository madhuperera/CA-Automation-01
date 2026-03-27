# CA306 - Block All Guests on Unsupported Device Platforms

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA306 |
| **Display Name** | CA306-AllApps:Block-For:AllGuests-When:UnsupportedDeviceType |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Device |

---

## Business Objective

Block all guest and external user types from accessing any application when using an unsupported device platform (anything other than Android, iOS, Windows, macOS, or Linux).

## Security Rationale

- **Threat Mitigated**: Guest access from unknown or unsupported device platforms
- **Attack Scenario**: External user accesses resources from a custom, emulated, or unrecognized device type
- **Control Type**: Preventive (platform-based block)
- **Risk Level**: Medium

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
  - `EID-SEC-U-A-CAP-CA306-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Platforms
- **Included**: All platforms
- **Excluded** (allowed through):
  - Android
  - iOS
  - Windows
  - macOS
  - Linux

### Net Effect
Blocks guests on any device platform **not** in the excluded (allowed) list — effectively blocking unknown, custom, or unsupported device types.

---

## Grant Controls

| Control | Setting |
|---------|--------|
| **Operator** | OR |
| **Grant Type** | Block |

---

## User Impact
- Guest users on standard platforms (Windows, macOS, iOS, Android, Linux) are unaffected
- Guest users on unknown or unsupported device types are blocked
- Minimal disruption expected for legitimate users

---

## Testing Checklist

- [ ] Guests on Windows, macOS, iOS, Android, and Linux can access
- [ ] Guests on unknown/unsupported device platforms are blocked
- [ ] Internal users are not affected
- [ ] Break-glass accounts excluded and functional

---

## References

- **Device Platforms**: [Conditional Access Device Platforms](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions#device-platforms)
- **Guest Access**: [Azure AD B2B Collaboration](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/what-is-b2b)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: policy blocks guests on unsupported platforms (not risk-based blocking) |
