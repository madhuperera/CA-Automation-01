# CA221 - Sign-in Frequency of 7 Days for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA221 |
| **Display Name** | CA221-AllApps:SessionFrequency7Days-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Session Management |

---

## Business Objective

Require internal users to reauthenticate at least once every 7 days on all applications, so that a sign-in session cannot stay valid indefinitely on any device.

## Security Rationale

- **Threat Mitigated**: Long-lived sessions, use of stolen or forgotten sessions on lost, shared, or no longer used devices
- **Attack Scenario**: A session established weeks ago on a device is still valid and is used by someone other than the user
- **Control Type**: Preventive (limits the lifetime of a sign-in session)
- **Risk Level**: Medium

Without a sign-in frequency policy, the Microsoft Entra ID default is a rolling 90-day window, which is renewed whenever the session is used. This policy sets a fixed upper limit of 7 days.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types (internalGuest, b2bCollaborationGuest, b2bCollaborationMember, b2bDirectConnectUser, otherExternalUser, serviceProvider)
  - Privileged admin roles (15 built-in admin role IDs, the same set as other Internal policies; admins are covered by CA104)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA221-Exclude`)

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- Not configured (applies from any network)

### Devices
- Not configured (applies to managed and unmanaged devices)

---

## Grant Controls

None. This policy only sets a session control.

## Session Controls

| Control | Setting |
|---------|---------|
| **Sign-in frequency** | Periodic reauthentication, every 7 days (`frequencyInterval = "timeBased"`, `type = "days"`, `value = 7`) |
| **Authentication type** | Primary and secondary authentication |

The period is set by `$TimeType` and `$TimeValue` in `CA221_Creation.ps1`. The display name contains the period, so do not change the value in an existing deployment without considering that the name would no longer match.

---

## Relationship to Other Policies

When more than one sign-in frequency policy applies to a sign-in, the shortest period is used.

- **CA203** sets 3 hours for internal users on unmanaged devices. It takes precedence over CA221 on those devices.
- **CA211**, **CA213**, **CA214** and **CA220** require reauthentication every time in their specific scenarios and take precedence where they apply.
- **CA104** sets the sign-in frequency for admin roles, which is why those roles are excluded here.
- CA221 sets the upper limit everywhere else, including managed and compliant devices.

---

## User Impact

- Users are asked to sign in again once every 7 days, on every device, including managed devices
- The reauthentication uses whatever the other policies require, for example MFA under CA206
- On Microsoft Entra joined and hybrid joined Windows devices, unlocking or signing in to the device at least once within the period refreshes the session, so those users are usually not prompted
- Applications and devices that are used less often than every 7 days prompt at next use
- Shared mailboxes, meeting room devices, and other accounts that cannot sign in interactively every 7 days should be added to `EID-SEC-U-A-CAP-CA221-Exclude`

---

## Testing Checklist

- [ ] Policy deployed in report-only mode
- [ ] Sign-in logs reviewed to see how many sign-ins would be affected
- [ ] Meeting room, kiosk, and shared device accounts identified and excluded where needed
- [ ] A user on a managed device is prompted after 7 days, or not at all where the device refreshes the session
- [ ] A user on an unmanaged device still follows the shorter period from CA203
- [ ] Break-glass accounts are unaffected

---

## References

- **Sign-in frequency**: [Conditional Access adaptive session lifetime policies](https://learn.microsoft.com/entra/identity/conditional-access/concept-session-lifetime)
- **Configuration**: [Configure adaptive session lifetime policies](https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-session-lifetime)
- **Session controls**: [Conditional Access: Session](https://learn.microsoft.com/entra/identity/conditional-access/concept-conditional-access-session)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-11-15 | Initial version |
| 1.1 | 2026-11-15 | Validated in a tenant deployment (policy created in report-only mode) |
