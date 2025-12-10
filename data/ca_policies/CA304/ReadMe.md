# CA304 - Device Platform Restriction for Guests

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA304 |
| **Display Name** | CA304-AllApps:PlatformRestriction-For:Guests-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Device |

---

## Business Objective

Restrict guest access to supported device platforms only (Windows, macOS, iOS, Android).

## Security Rationale

- **Threat Mitigated**: Access from unsupported/unmanaged device types
- **Control Type**: Preventive
- **Risk Level**: Low-Medium

---

## Supported Platforms
- Windows (all versions)
- macOS
- iOS
- Android
- Linux

---

## Unsupported Platforms Blocked
- Custom/legacy platforms
- Unknown device types

---

## User Impact
- Guest users must use standard devices
- Minimal disruption expected

---

## Testing Checklist

- [ ] Guests on standard devices can access
- [ ] Unusual platforms tested

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
