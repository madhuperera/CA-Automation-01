# CA217 - Block Office 365 Access from macOS Devices for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA217 |
| **Display Name** | CA217-O365:Block-For:Internals-When:OnmacOSDevices |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Internal User Access Control - Platform Restriction |

---

## Business Objective

Block internal users from accessing Office 365 from macOS devices. This is typically used where the organisation does not manage or support macOS endpoints, and access from those platforms presents an unacceptable security risk due to the absence of device compliance controls.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded guest types**: internalGuest, b2bCollaborationGuest, b2bCollaborationMember, b2bDirectConnectUser, otherExternalUser, serviceProvider (external and guest users are excluded by design; this policy targets internal users only)
- **Excluded roles**: A set of administrative roles is excluded from this policy (same role set used across other Internal policies — Global Administrator and a range of service-specific admin roles)
- **Excluded groups**:
  - `EID-SEC-U-A-CAP-CA217-Exclude` (policy-specific exclusions)
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` (break-glass admin)
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` (break-glass admin)

### Applications
- **Scope**: Office 365 (`Office365`)
- **Client App Types**: All

### Locations
- Not configured — applies at any network location

### Devices
- **Included platforms**: macOS only
- **Platform Restrictions**: Policy is triggered only when the device platform is macOS

### Session/Risk
- **Sign-in Risk**: Not configured
- **User Risk**: Not configured

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Block |
| **Session Controls** | None |

**Effect**: **Block** — Internal users attempting to access Office 365 from a macOS device are denied access.

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA217-Exclude`**
- Members bypass the macOS block for Office 365
- Use case: Employees with an approved macOS endpoint, or users with a temporary business exemption
- **Management**: Minimise membership; review regularly

### Break-Glass Emergency Admin Groups
**`EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`**
**`EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`**
- Ensures emergency admin access is not blocked by platform controls

---

## Deployment Notes

### Prerequisite
Before enforcing this policy, confirm whether any internal users have legitimate, approved use of macOS devices for Office 365 access. Add those users to the exclusion group before switching to `enabled` state.

### Testing Guidance
1. Deploy in `enabledForReportingButNotEnforced` state
2. Review CA sign-in logs to identify internal users accessing Office 365 from macOS
3. Determine whether those sessions are from managed or approved macOS endpoints
4. Add legitimate users to `EID-SEC-U-A-CAP-CA217-Exclude` before enforcement
5. Enable enforcement only after validating that no unintended users are blocked

### Rollout Notes
- This policy is typically used alongside CA216 (compliant Windows device requirement) and CA208 (managed Windows device requirement) as part of a broader device platform control set
- If macOS is a managed and supported platform in the organisation, consider replacing this block with a device compliance requirement rather than a blanket block

---

## Operational Cautions

- Blocking a device platform entirely may impact users who are unaware their device platform is being detected
- macOS platform detection relies on device metadata reported during sign-in; VMs and browser-based access may report differently
- Coordinate with endpoint management and helpdesk teams before enforcing

---

## Dependent Resources

### Security Groups
| Group | Purpose |
|-------|---------|
| `EID-SEC-U-A-CAP-CA217-Exclude` | Policy-specific exclusions for approved macOS users |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` | Emergency admin account 1 |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` | Emergency admin account 2 |

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA216 | Sibling | Requires compliant Windows device for Office 365 |
| CA208 | Sibling | Requires managed Windows device for Office 365 |
| CA201 | Sibling | Blocks unsupported device types for internal users |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-06-01 | Initial documentation created from CA217_Creation.ps1 |
