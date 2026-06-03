# CA209 - Require MFA for Device Enrollment (All Locations)

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA209 |
| **Display Name** | CA209-DeviceEnrollment:RequireMFA-For:Internals-When:OutsideOfOffice |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Identity Security - Device Registration |

---

## Business Objective

Require internal users to complete MFA when registering (enrolling) a device. The display name indicates intent to scope this to outside-office scenarios, but the creation script does not configure a location exclusion — MFA is therefore required for device enrollment from any location.

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
- **Excluded**: Not configured — the script does not define any location exclusion

**Note**: Despite the display name containing `OutsideOfOffice`, the creation script (`CA209_Creation.ps1`) only sets `includeLocations = "All"` with no `excludeLocations` block. As scripted, MFA is required for device registration from all locations, including trusted office locations.

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require MFA |

---

## User Impact
- MFA is required for device registration from any network location (no office exclusion is configured in the script)
- Admin roles are excluded (handled by separate admin policies)
- Guest users are excluded

---

## Dependent Resources

None. This policy does not reference any named location — no location exclusion is configured in the creation script.

---

## Testing Checklist

- [ ] Internal users are prompted for MFA when registering devices (from any location)
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
| 1.2 | 2026-06-18 | Corrected: no location exclusion is configured in the creation script; policy applies from all locations |
