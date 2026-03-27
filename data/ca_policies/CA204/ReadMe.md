# CA204 - Block Unmanaged Devices for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA204 |
| **Display Name** | CA204-AllApps:ManagedDevice-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Management - Managed Device Requirement |

---

## Business Objective

Block internal users from accessing any application on unmanaged devices. Devices that are Azure AD joined, Server AD joined, Intune compliant, or company-owned are allowed through; all others are blocked.

## Security Rationale

- **Threat Mitigated**: Access from unmanaged devices lacking security controls
- **Attack Scenario**: User signs in from personal unmanaged device without antivirus, encryption, or firewall
- **Control Type**: Preventive (blocks access from personal/unmanaged devices)
- **Risk Level**: Medium-High

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types
  - Admin roles (16 built-in admin role IDs)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA204-Exclude`)

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Devices
- **Filter Mode**: Exclude (allow managed devices through)
- **Excluded Devices** (allowed):
  - Azure AD joined devices (`device.trustType -eq "AzureAD"`)
  - Server AD joined devices (`device.trustType -eq "ServerAD"`)
  - Compliant devices (`device.isCompliant -eq True`)
  - Company-owned devices (`device.deviceOwnership -eq "Company"`)

### Net Effect
Devices that do **not** match any of the above criteria are blocked. This effectively requires a managed device for access.

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Block |

**Note**: The policy uses a block grant with a device filter exclusion (rather than a "require compliant device" grant control). Managed devices are excluded from the block via the device filter.

---

## User Impact
- Users on Azure AD joined, Server AD joined, compliant, or company-owned devices are unaffected
- Users on personal/unmanaged devices are blocked
- Device enrollment may be required (15–30 minutes)
- Admin roles are excluded (handled by separate admin policies)

---

## Testing Checklist

- [ ] Internal user on Azure AD joined device can access
- [ ] Internal user on compliant device can access
- [ ] Internal user on company-owned device can access
- [ ] Internal user on personal/unmanaged device is blocked
- [ ] Admin roles are excluded
- [ ] Guest users are excluded
- [ ] Break-glass accounts excluded and functional

---

## References

- **Device Filter**: [Conditional Access Device Filter](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions#filter-for-devices)
- **Device Management**: [Intune Device Enrollment](https://learn.microsoft.com/en-us/mem/intune/enrollment/)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: display name, grant type (block with device filter, not require compliant), and device filter details |
