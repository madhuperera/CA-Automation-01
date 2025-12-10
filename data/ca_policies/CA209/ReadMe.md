# CA209 - Device Compliance Policy

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA209 |
| **Display Name** | CA209-AllApps:RequireCompliance-For:AllUsers-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Management - Compliance |

---

## Business Objective

Require all devices to meet compliance standards before accessing Microsoft 365 applications.

## Security Rationale

- **Threat Mitigated**: Access from non-compliant devices (outdated OS, no antivirus)
- **Control Type**: Preventive
- **Risk Level**: Medium

---

## Compliance Requirements
- Operating system up-to-date
- Antivirus/antimalware enabled
- Firewall enabled
- Disk encryption enabled
- Password policy enforced

---

## User Impact
- Devices must maintain compliance
- Updates required if compliance lost
- Ongoing monitoring

---

## Testing Checklist

- [ ] Compliant devices can access
- [ ] Non-compliant devices blocked
- [ ] Compliance requirements clear

---

## References

- **Device Compliance**: [Intune Device Compliance](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
