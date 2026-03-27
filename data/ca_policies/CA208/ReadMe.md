# CA208 - Block Non-Company-Owned Windows Devices for Office 365

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA208 |
| **Display Name** | CA208-O365:RequireManagedDevice-For:Internals-When:OnWindowsDevices |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Management - Windows Device Control |

---

## Business Objective

Block internal users from accessing Office 365 on Windows devices that are not company-owned, ensuring only corporate-managed Windows endpoints can access Office 365 applications.

## Security Rationale

- **Threat Mitigated**: Access to Office 365 from unmanaged personal Windows devices
- **Attack Scenario**: User signs in to Office 365 from personal Windows PC without corporate security controls
- **Control Type**: Preventive (blocks non-company-owned Windows access to Office 365)
- **Risk Level**: Medium-High

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types
  - Admin roles (16 built-in admin role IDs)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA208-Exclude`)

### Applications
- **Scope**: Office 365 (`Office365`)
- **Client App Types**: All

### Platforms
- **Included**: Windows only

### Devices
- **Filter Mode**: Exclude (allow company-owned devices through)
- **Excluded Devices**: Company-owned devices (`device.deviceOwnership -eq "Company"`)

### Net Effect
Windows devices that are **not** company-owned are blocked from accessing Office 365.

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Block |

**Note**: The policy uses a block grant with a device filter exclusion. Company-owned Windows devices are excluded from the block via the device filter.

---

## User Impact
- Internal users on company-owned Windows devices can access Office 365 normally
- Internal users on personal/non-company Windows devices are blocked from Office 365
- Other platforms (macOS, iOS, Android) are not affected by this policy
- Admin roles are excluded (handled by separate admin policies)

---

## Testing Checklist

- [ ] Internal user on company-owned Windows device can access Office 365
- [ ] Internal user on personal Windows device is blocked from Office 365
- [ ] Other platforms (Mac, iOS, Android) are not affected
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
| 1.1 | 2026-03-27 | Corrected: display name, app scope (Office365 not All), grant type (block with device filter), platform (Windows only) |
