# CA204 - Require Managed Device for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA204 |
| **Display Name** | CA204-AllApps:RequireManagedDevice-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Management - Managed Device Requirement |

---

## Business Objective

Require internal users to access Microsoft 365 from managed (Intune-enrolled) or Azure AD joined devices only, ensuring device compliance and security controls.

## Security Rationale

- **Threat Mitigated**: Access from unmanaged devices lacking security controls
- **Attack Scenario**: User signs in from personal unmanaged laptop without antivirus or firewall
- **Control Type**: Preventive (blocks access from personal/unmanaged devices)
- **Risk Level**: Medium-High

---

## Policy Conditions

### Users
- **Scope**: Internal users
- **Excluded**: Admins, guests

### Devices
- **Requirement**: Must be Azure AD joined OR Intune compliant
- **Effect**: Unmanaged devices blocked

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require Compliant Device |

---

## User Impact
- Users must use company device or enroll personal device in Intune
- Setup: 15-30 minutes for device enrollment
- Long-term: Device must maintain compliance (updates, antivirus, etc.)

---

## Testing Checklist

- [ ] Internal user on managed device can access
- [ ] Internal user on unmanaged device blocked
- [ ] Enrollment process works smoothly
- [ ] Admins and guests not affected

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Device Management**: [Intune Device Enrollment](https://learn.microsoft.com/en-us/mem/intune/enrollment/)
- **Device Compliance**: [Device Compliance Policies](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
