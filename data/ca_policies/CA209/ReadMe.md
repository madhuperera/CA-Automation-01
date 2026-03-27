# CA209 - Require MFA for Device Enrollment Outside Office

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA209 |
| **Display Name** | CA209-DeviceEnrollment:RequireMFA-For:Internals-When:OutsideOfOffice |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Identity Security - Device Registration |

---

## Business Objective

Require internal users to complete MFA when registering (enrolling) a device from outside trusted office locations. This prevents unauthorized device enrollment from untrusted networks.

## Security Rationale

- **Threat Mitigated**: Unauthorized device registration using compromised credentials
- **Attack Scenario**: Attacker with stolen user credentials registers their own device from an external location to maintain persistent access
- **Control Type**: Preventive (requires MFA verification before device enrollment outside office)
- **Risk Level**: Medium-High

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types (internalGuest, b2bCollaborationGuest, b2bCollaborationMember, b2bDirectConnectUser, otherExternalUser, serviceProvider)
  - Admin roles (16 built-in admin role IDs)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA209-Exclude`)

### User Actions
- **Trigger**: `urn:user:registerdevice` (device registration/enrollment)

### Locations
- **Included**: All locations
- **Excluded**: `CL005-IP-A-AllApps-InternalUsers-TrustedLocations` (trusted office locations)

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require MFA |

---

## User Impact
- Users enrolling devices from trusted office locations are unaffected
- Users enrolling devices from outside the office must complete MFA
- Admin roles are excluded (handled by separate admin policies)
- Guest users are excluded

---

## Dependent Resources

| Resource | Name | Purpose |
|----------|------|---------|
| Named Location | `CL005-IP-A-AllApps-InternalUsers-TrustedLocations` | Trusted office IP ranges |

---

## Testing Checklist

- [ ] Users at office locations can register devices without MFA prompt
- [ ] Users outside office are prompted for MFA when registering devices
- [ ] Admin roles are excluded
- [ ] Guest users are excluded
- [ ] Break-glass accounts excluded and functional

---

## References

- **Device Registration**: [Device Registration in Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/overview)
- **Conditional Access User Actions**: [User Actions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps#user-actions)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: policy is for device enrollment MFA outside office (not device compliance for all users) |
