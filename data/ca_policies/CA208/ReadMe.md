# CA208 - Require Managed Windows Device for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA208 |
| **Display Name** | CA208-AllApps:RequireManagedWindows-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Management - Windows Device Control |

---

## Business Objective

Require internal users to access from managed Windows devices only (Azure AD joined or Intune-enrolled), ensuring compliance with security baselines.

## Security Rationale

- **Threat Mitigated**: Access from unmanaged Windows endpoints without security controls
- **Attack Scenario**: User logs in from personal Windows PC with outdated OS and no antivirus
- **Control Type**: Preventive (blocks unmanaged Windows endpoints)
- **Risk Level**: Medium-High

---

## Policy Conditions

### Users
- **Scope**: Internal users

### Devices
- **Platform**: Windows only
- **Requirement**: Must be Azure AD joined or Intune compliant

---

## User Impact
- Personal Windows devices must be enrolled in Intune
- Company Windows devices: Auto-affected (already managed)
- Setup: 20-30 minutes for device enrollment

---

## Testing Checklist

- [ ] Internal users on managed Windows can access
- [ ] Unmanaged Windows blocked
- [ ] Enrollment works smoothly
- [ ] Other platforms (Mac, iOS, Android) not affected

---

## References

- **Device Management**: [Intune Device Enrollment](https://learn.microsoft.com/en-us/mem/intune/enrollment/)
- **Azure AD Join**: [Azure AD Device Registration](https://learn.microsoft.com/en-us/azure/active-directory/devices/)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
