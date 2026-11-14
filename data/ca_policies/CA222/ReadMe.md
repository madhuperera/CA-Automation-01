# CA222 - Require Token Protection on Windows Devices

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA222 |
| **Display Name** | CA222-EXO+SPO+Teams:RequireTokenProtection-For:Internals-When:OnWindowsDevices |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Session Security - Token Protection |

---

## Business Objective

Require device-bound sign-in session tokens for internal users who access Exchange Online, SharePoint Online, and Microsoft Teams from desktop applications on Windows, so that a stolen token cannot be replayed from another device.

## Security Rationale

- **Threat Mitigated**: Token theft and token replay, including tokens taken by malware or adversary-in-the-middle phishing
- **Attack Scenario**: Attacker steals a refresh token from a user's device and uses it from their own device to reach mail and files
- **Control Type**: Preventive (only tokens cryptographically bound to the registered device are accepted)
- **Risk Level**: High

MFA protects the sign-in. Token protection protects what the sign-in produces: a token bound to the device it was issued to is of no use anywhere else.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types (internalGuest, b2bCollaborationGuest, b2bCollaborationMember, b2bDirectConnectUser, otherExternalUser, serviceProvider)
  - Privileged admin roles (15 built-in admin role IDs, the same set as other Internal policies)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA222-Exclude`)

### Applications
- **Scope**: Three applications, selected individually:
  - Office 365 Exchange Online (`00000002-0000-0ff1-ce00-000000000000`)
  - Office 365 SharePoint Online (`00000003-0000-0ff1-ce00-000000000000`)
  - Microsoft Teams Services (`cc15fd57-2c6c-4117-a88c-83b1d56b4bbe`)
- **Client App Types**: Mobile apps and desktop clients only

Do not replace the three applications with the **Office 365** application group, and do not add the **Browser** client app type. Microsoft warns that either change can cause unintended failures, for example blocking Teams on the web.

### Locations
- Not configured (applies from any network)

### Devices
- **Device Platforms**: Windows

---

## Grant Controls

None. This policy only sets a session control.

## Session Controls

| Control | Setting |
|---------|---------|
| **Token protection** | Require token protection for sign-in sessions (`secureSignInSession.isEnabled = $true`) |

---

## Prerequisites

- Microsoft Entra ID P1 licences
- Windows 10 or later devices that are Microsoft Entra joined, Microsoft Entra hybrid joined, or Microsoft Entra registered
- Supported, up-to-date desktop applications (for example Outlook, Teams, OneDrive, Word, Excel, PowerPoint, OneNote)

**Deployment note**: The token protection session control is sent through the Microsoft Graph v1.0 `New-MgIdentityConditionalAccessPolicy` command. If a tenant or module version does not accept the control, the deployment report shows CA222 as **Failed** with the reason, and no other policy is affected.

---

## Known Limitations

Once enforced, the policy blocks clients and devices that cannot present a bound token. Microsoft lists the following as unsupported.

**Applications**
- Office perpetual clients earlier than version 2024
- PowerShell modules that access SharePoint
- The PowerQuery extension for Excel outside the Current Channel
- Visual Studio Code extensions that access Exchange or SharePoint

**Devices**
- Surface Hub
- Windows-based Microsoft Teams Rooms systems
- Windows devices deployed with bulk enrolment
- Windows Autopilot devices deployed in self-deploying mode
- Microsoft Entra joined Azure Virtual Desktop session hosts
- Microsoft Entra joined Cloud PCs deployed by Windows 365
- Microsoft Entra joined Power Automate hosted machine groups
- Azure virtual machines enabled for Microsoft Entra ID sign-in

Handle these before enforcement, either by adding the affected accounts to `EID-SEC-U-A-CAP-CA222-Exclude` or by adding a device filter to the policy that excludes the device type. Microsoft's deployment guide gives example filter rules.

---

## Relationship to Other Policies

- The policy applies to Windows only. An attacker can present a different platform to avoid it, so it should be paired with policies that block unsupported platforms and require managed or compliant devices: **CA201** (block unsupported device types), **CA204** (managed device), and **CA216** (compliant device on Windows).
- Admin roles are excluded, as in the other Internal policies. No admin policy in this repository requires token protection at present.
- Token protection is also available for native applications on iOS, iPadOS, and macOS. Those platforms are not covered by this policy.

---

## User Impact

- No visible change for users on a registered Windows device with supported applications
- A user on an unregistered Windows device is prompted to register the device
- A user on an unsupported application or device is blocked after signing in, with a message that token protection is required
- Browser access is not affected, because the policy only applies to mobile apps and desktop clients

---

## Testing Checklist

- [ ] Policy deployed in report-only mode
- [ ] Interactive and non-interactive sign-in logs captured for long enough to cover normal use
- [ ] Sign-ins where the token protection session control would not be satisfied are reviewed (the **Token Protection - Sign In Session** field shows Bound or Unbound, with a status code)
- [ ] Unsupported applications and device types are identified and excluded
- [ ] Pilot group enforced before wider rollout
- [ ] Outlook, Teams, and OneDrive on a registered Windows device work without prompts
- [ ] Break-glass accounts are unaffected

---

## References

- **Overview**: [Token Protection in Microsoft Entra Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/concept-token-protection)
- **Deployment**: [Token Protection deployment guide - Windows](https://learn.microsoft.com/entra/identity/conditional-access/deployment-guide-token-protection-windows)
- **Token theft**: [Protecting tokens in Microsoft Entra](https://learn.microsoft.com/entra/identity/devices/protecting-tokens-microsoft-entra-id)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-11-15 | Initial version |
