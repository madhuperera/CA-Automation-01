# CA203 - Session Timeout on Unmanaged Devices (Internal Users)

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA203 |
| **Display Name** | CA203-AllApps:SessionFrequency-For:Internals-When:OnUnmanagedDevices |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Management - Session Control |

---

## Business Objective

Limit session duration to 3 hours for internal users on unmanaged devices, requiring periodic re-authentication from personal devices to reduce stolen token risks.

## Security Rationale

- **Threat Mitigated**: Stolen session tokens on personal devices
- **Attack Scenario**: User's personal laptop compromised; attacker uses stolen token
- **Control Type**: Preventive (forces periodic re-authentication)
- **Risk Level**: Medium

Managed devices (Intune-enrolled) allow longer sessions because they have additional controls.

---

## Policy Conditions

### Users
- **Scope**: Internal users (excluding guests, admins)
- **Included**: All users
- **Excluded**: Administrative roles, guests/external users

### Devices
- **Condition**: Unmanaged devices only (not Azure AD joined or compliant)
- **Device Filter**: `device.trustType -eq "AzureAD" OR device.isCompliant -eq True` (EXCLUDED)

---

## Session Controls

| Control | Setting |
|---------|---------|
| **Session Type** | Sign-in Frequency |
| **Frequency** | Every 3 hours |
| **Authentication Type** | Primary + Secondary |
| **Persistent Browser** | Never |

---

## Testing Checklist

- [ ] User on unmanaged personal device gets timeout at 3 hours
- [ ] User on managed device NOT affected (can have longer session)
- [ ] Re-authentication required with password + MFA

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Device Management**: [Azure AD Device Registration](https://learn.microsoft.com/en-us/azure/active-directory/devices/)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
