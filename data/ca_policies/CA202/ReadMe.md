# CA202 - Require MFA for Security Information Registration Outside Office

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA202 |
| **Display Name** | CA202-SecurityInformation:RequireMFAorCompliant-For:Internals-When:OutsideOfOffice |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Identity Security - Account Hardening |

---

## Business Objective

Require internal users to complete MFA when registering new security information (MFA methods, security keys, etc.) from outside trusted office locations and when not on a company-owned compliant device. This prevents unauthorized modification of authentication methods.

## Security Rationale

- **Threat Mitigated**: Attackers modifying victim's security information to lock them out or maintain backdoor access
- **Attack Scenario**: Attacker compromises user password and tries to register their own MFA device from an external location
- **Control Type**: Preventive (prevents unauthorized security configuration changes from untrusted locations/devices)
- **Risk Level**: High

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types (internalGuest, b2bCollaborationGuest, b2bCollaborationMember, b2bDirectConnectUser, otherExternalUser, serviceProvider)
  - Admin roles (16 built-in admin role IDs)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA202-Exclude`)

### User Actions
- **Trigger**: `urn:user:registersecurityinfo` (registering security information)

### Devices
- **Filter Mode**: Exclude
- **Excluded Devices**: Company-owned AND compliant devices (`device.deviceOwnership -eq "Company" -and device.isCompliant -eq True`)

### Locations
- **Included**: All locations
- **Excluded**: `CL005-IP-A-AllApps-InternalUsers-TrustedLocations` (trusted office locations)

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require MFA |

---

## User Impact
- Users registering security info from trusted office locations are unaffected
- Users on company-owned compliant devices are unaffected
- Users outside the office on non-company devices must complete MFA before registering new security info
- Admin roles are excluded (handled by separate admin policies)

---

## Dependent Resources

| Resource | Name | Purpose |
|----------|------|---------|
| Named Location | `CL005-IP-A-AllApps-InternalUsers-TrustedLocations` | Trusted office IP ranges |

---

## Testing Checklist

- [ ] Users at office locations can register security info without MFA prompt
- [ ] Users on company-owned compliant devices can register without MFA prompt
- [ ] Users outside office on personal devices are prompted for MFA
- [ ] Admin roles are excluded
- [ ] Guest users are excluded
- [ ] Break-glass accounts excluded and functional

---

## References

- **Security Info Registration**: [Combined Registration for MFA and SSPR](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-registration-mfa-sspr-combined)
- **Conditional Access**: [User Actions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps#user-actions)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: display name, user scope (internals not all), location condition, device filter, and grant controls |
