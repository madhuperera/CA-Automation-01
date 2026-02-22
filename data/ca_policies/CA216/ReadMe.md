# CA216 - O365 Require Compliant Device for Internals on Windows

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA216 |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Management |
| **Applies To** | Internal users, Office 365 cloud apps, Windows platform |
| **Device Filter** | Include `device.deviceOwnership -eq "Company"` |
| **Grant Controls** | Require compliant device |
| **Session Controls** | None |

---

## Business Objective

Allow access to Office 365 from Windows only when the device is company-owned and compliant.

---

## Security Rationale

Combining device ownership filtering with compliant-device enforcement reduces risk from unmanaged or non-compliant endpoints while maintaining access for trusted managed assets.

---

## Policy Conditions

- Include users: `All`
- Exclude groups: policy exclusion group + two emergency break-glass groups
- Exclude guest/external user types
- Exclude privileged admin roles
- Include applications: `Office365`
- Include platforms: `windows`
- Device filter: `include` with `device.deviceOwnership -eq "Company"`
- Grant: `compliantDevice`

---

## Testing Checklist

- [ ] Policy correctly targets internal users on Windows
- [ ] Company-owned devices are in-scope per filter condition
- [ ] Compliant device requirement is enforced
- [ ] No impact on break-glass accounts

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial documentation |
