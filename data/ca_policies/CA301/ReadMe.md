# CA301 - Require Compliance for Guest Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA301 |
| **Display Name** | CA301-AllApps:RequireCompliance-For:Guests-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control |

---

## Business Objective

Require guest users to access from compliant devices meeting organizational security standards.

## Security Rationale

- **Threat Mitigated**: Access from unmanaged guest devices
- **Control Type**: Preventive
- **Risk Level**: Medium

---

## Policy Conditions

### Users
- **Scope**: Guest and external users

### Devices
- **Requirement**: Must be compliant (updated OS, antivirus, encryption)

---

## User Impact
- Guest users must use compliant devices
- Enrollment: 20-30 minutes
- Setup instructions provided to external users

---

## Testing Checklist

- [ ] Compliant guest devices can access
- [ ] Non-compliant guest devices blocked
- [ ] Clear enrollment instructions

---

## References

- **Device Compliance**: [Intune Device Compliance](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
