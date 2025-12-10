# CA207 - Require Passwordless Authentication for Internal Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA207 |
| **Display Name** | CA207-AllApps:PasswordlessAuth-For:Internals-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Authentication Security - Passwordless |

---

## Business Objective

Enforce passwordless authentication methods for internal users, eliminating passwords and phishing attacks.

## Security Rationale

- **Threat Mitigated**: Phishing attacks, password reuse, credential stuffing
- **Attack Scenario**: Attacker phishes user password or steals from password manager
- **Control Type**: Preventive (eliminates password-based access)
- **Risk Level**: High

Passwordless methods (Windows Hello, FIDO2, Authenticator) cannot be phished or reused.

---

## Passwordless Methods Supported
- Windows Hello for Business
- FIDO2 security keys
- Microsoft Authenticator (passwordless phone sign-in)

---

## User Impact
- Users must register passwordless method
- Setup: 10-20 minutes
- Ongoing: Streamlined (face/fingerprint/key button)

---

## Testing Checklist

- [ ] Users can register passwordless method
- [ ] Can sign in using passwordless
- [ ] Sufficient devices/keys available

---

## References

- **Passwordless**: [Passwordless Authentication](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-authentication-passwordless)
- **Windows Hello**: [Windows Hello for Business](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/)
- **FIDO2**: [FIDO2 Security Keys](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-authentication-passwordless)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
