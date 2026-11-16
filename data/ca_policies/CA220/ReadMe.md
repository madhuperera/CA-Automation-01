# CA220 - Require MFA Every Time for Intune Enrollment

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA220 |
| **Display Name** | CA220-IntuneEnrollment:RequireMFA+EverySignIn-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Enrollment Security |

---

## Business Objective

Require internal users to complete multifactor authentication every time they enrol a device in Microsoft Intune, so that a stolen password or an existing signed-in session cannot be used to enrol an attacker's device as a managed device.

## Security Rationale

- **Threat Mitigated**: Rogue device enrolment, use of stolen credentials or session tokens to obtain a managed and compliant device
- **Attack Scenario**: Attacker with a user's password or a replayed session enrols their own device, which then passes the device-based Conditional Access policies
- **Control Type**: Preventive (fresh MFA is required at the point of enrolment)
- **Risk Level**: High

An enrolled device is trusted by the policies that require a managed or compliant device. Requiring fresh MFA at enrolment protects the step that grants that trust.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types (internalGuest, b2bCollaborationGuest, b2bCollaborationMember, b2bDirectConnectUser, otherExternalUser, serviceProvider)
  - Privileged admin roles (15 built-in admin role IDs, the same set as other Internal policies)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA220-Exclude`)

### Applications
- **Scope**: Microsoft Intune Enrollment (`d4ebce55-015a-49b5-a083-c84d1797ae8c`)
- **Client App Types**: All

### Locations
- Not configured (applies from any network)

### Devices
- Not configured

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require multifactor authentication (`builtInControls = "mfa"`) |

## Session Controls

| Control | Setting |
|---------|---------|
| **Sign-in frequency** | Every time (`frequencyInterval = "everyTime"`) |
| **Authentication type** | Primary and secondary authentication |

Microsoft Intune device enrolment is one of the scenarios where the "every time" sign-in frequency is supported.

---

## Prerequisite: Microsoft Intune Enrollment Application

The policy targets the Microsoft Intune Enrollment application. In some tenants this application has no service principal, and Microsoft Graph then rejects the policy (`ServicePrincipalNotFound`).

The deployment checks for the service principal before anything else is created. If it is missing, the deployment pauses and shows a red banner asking whether to create it:

- **Y**: you are asked to sign in a second time to grant `Application.ReadWrite.All`, and the service principal is created. The account needs the Application Administrator, Cloud Application Administrator or Global Administrator role.
- **N**: nothing is created and the deployment report shows CA220 as **Skipped**. No other policy is affected.

The extra permission is only requested after a `Y` answer. See [`data/service_principals/ReadMe.md`](../../service_principals/ReadMe.md) for details.

To create the service principal by hand instead, and then run the deployment again:

```powershell
Connect-MgGraph -Scopes "Application.ReadWrite.All"
New-MgServicePrincipal -AppId "d4ebce55-015a-49b5-a083-c84d1797ae8c"
```

---

## Relationship to Other Policies

- **CA209** requires MFA for the "Register or join devices" user action, which covers Microsoft Entra device registration and join. CA220 covers the Intune enrolment step. The two complement each other.
- **CA206** requires MFA for internal users on all applications. CA220 adds the "every time" requirement for enrolment, so an existing MFA session is not enough.
- **CA204** and **CA216** rely on managed or compliant devices, which is why the enrolment step is protected here.

---

## User Impact

- Users are asked to sign in with MFA each time they enrol a device, even if they completed MFA recently
- Users must have an MFA method registered before they can enrol a device
- Bulk or automated enrolment that signs in as a user, such as a device enrolment manager account, is prompted in the same way. Add such accounts to `EID-SEC-U-A-CAP-CA220-Exclude` if they cannot complete MFA
- Windows Autopilot and other enrolment flows where the user signs in interactively continue to work, with the extra MFA prompt

---

## Testing Checklist

- [ ] Microsoft Intune Enrollment service principal exists in the tenant (the deployment offers to create it)
- [ ] Policy deployed in report-only mode
- [ ] Sign-in logs reviewed for sign-ins to Microsoft Intune Enrollment
- [ ] Enrolment on each platform in use (Windows, iOS/iPadOS, Android, macOS) prompts for MFA
- [ ] A user with a recent MFA session is prompted again at enrolment
- [ ] Enrolment accounts that cannot complete MFA are identified and added to the exclusion group
- [ ] Break-glass accounts are unaffected

---

## References

- **Sign-in frequency**: [Conditional Access adaptive session lifetime policies](https://learn.microsoft.com/entra/identity/conditional-access/concept-session-lifetime)
- **MFA for enrolment**: [Require multifactor authentication for Intune device enrollments](https://learn.microsoft.com/mem/intune/enrollment/multi-factor-authentication)
- **Session controls**: [Conditional Access: Session](https://learn.microsoft.com/entra/identity/conditional-access/concept-conditional-access-session)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-11-15 | Initial version |
| 1.1 | 2026-11-15 | Validated in a tenant deployment (policy created in report-only mode) |
| 1.2 | 2026-11-17 | The deployment now checks for the Microsoft Intune Enrollment service principal and offers to create it |
