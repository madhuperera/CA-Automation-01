# CA219 - Require Phishing-Resistant MFA for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA219 |
| **Display Name** | CA219-AllApps:PhishingResistantMFA-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Authentication Security - Phishing-Resistant MFA |

---

## Business Objective

Require phishing-resistant authentication methods, such as passkeys, for internal users on all applications, so that stolen passwords and intercepted MFA prompts cannot be used to sign in.

## Security Rationale

- **Threat Mitigated**: Credential phishing, adversary-in-the-middle (AiTM) token theft, MFA fatigue and push bombing
- **Attack Scenario**: Attacker lures a user to a proxy sign-in page and relays the password and MFA prompt to capture a session
- **Control Type**: Preventive (only methods bound to the legitimate sign-in origin are accepted)
- **Risk Level**: High

Phishing-resistant methods are cryptographically bound to the sign-in service, so they cannot be replayed through a fake sign-in page. Passwords, SMS, voice, one-time codes, and Authenticator push notifications do not satisfy this policy.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Excluded**:
  - All guest/external user types (internalGuest, b2bCollaborationGuest, b2bCollaborationMember, b2bDirectConnectUser, otherExternalUser, serviceProvider)
  - Privileged admin roles (15 built-in admin roles, the same set as other Internal policies; admins are covered by CA103)
  - Break-glass groups and policy exclusion group (`EID-SEC-U-A-CAP-CA219-Exclude`)

### Applications
- **Scope**: All Applications
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
| **Grant Type** | Authentication Strength: Phishing-resistant MFA |
| **Auth Strength ID** | `00000000-0000-0000-0000-000000000004` (built-in Phishing-resistant MFA authentication strength) |

**Note**: This policy uses an Authentication Strength control (not `builtInControls = "mfa"`). It uses the built-in strength, so it does not depend on any custom authentication strength in this repository.

---

## Phishing-Resistant Methods Supported
- Passkeys (FIDO2), including FIDO2 security keys and passkeys in Microsoft Authenticator
- Windows Hello for Business
- Platform Credential for macOS
- Certificate-based authentication (multifactor)

Microsoft Authenticator passwordless phone sign-in and push notifications are **not** phishing-resistant and do not satisfy this policy.

---

## Relationship to Other Policies

- **CA206** (MFA for internal users) and **CA207** (passwordless for internal users) target the same users and applications. When several policies apply, all of them must be satisfied, so once CA219 is enforced it is the strictest of the three and effectively supersedes CA206 and CA207.
- **CA207** is expected to be retired in favour of this policy. Both remain in the repository for now.
- **CA103** applies the same requirement to admin roles, which is why those roles are excluded here.

---

## User Impact
- Users must register a phishing-resistant method before the policy is enforced
- A user with no phishing-resistant method cannot satisfy the policy. A Temporary Access Pass does not satisfy it either
- For onboarding and recovery, add the user to `EID-SEC-U-A-CAP-CA219-Exclude` until a phishing-resistant method is registered, then remove them
- Ongoing: sign-in with a biometric, PIN, or security key

---

## Testing Checklist

- [ ] Policy deployed in report-only mode
- [ ] Sign-in logs reviewed to identify users who would fail the policy
- [ ] Users can register a passkey, Windows Hello for Business, or another phishing-resistant method
- [ ] Sign-in with a phishing-resistant method satisfies the policy
- [ ] Sign-in with password plus Authenticator push is reported as not satisfying the policy
- [ ] Onboarding and recovery process through the exclusion group is confirmed
- [ ] Break-glass accounts are unaffected

---

## References

- **Authentication strengths**: [Conditional Access authentication strengths](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths)
- **Phishing-resistant MFA**: [Require phishing-resistant multifactor authentication](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength)
- **Passkeys**: [Passkeys (FIDO2) in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-passwordless)
- **Windows Hello**: [Windows Hello for Business](https://learn.microsoft.com/windows/security/identity-protection/hello-for-business/)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-11-14 | Initial version |
