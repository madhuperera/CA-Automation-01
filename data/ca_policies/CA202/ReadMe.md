# CA202 - Require MFA or Compliant Device for Security Info Updates

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA202 |
| **Display Name** | CA202-SecurityInfo:Require-MFAorCompliance-For:AllUsers-When:RegisteringSecurity |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Identity Security - Account Hardening |

---

## Business Objective

Require users to provide MFA or use compliant devices when registering new security information (MFA methods, security keys, etc.), preventing unauthorized account modifications.

## Security Rationale

- **Threat Mitigated**: Attackers modifying victim's security information to lock them out or maintain backdoor access
- **Attack Scenario**: Attacker compromises user password and tries to add their own MFA device as backup
- **Control Type**: Preventive (prevents unauthorized security configuration changes)
- **Risk Level**: High

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Exclusions**: Break-glass accounts

### Applications
- **Scope**: User registration actions (security info registration)

### Devices
- **Condition**: Requires MFA OR compliant/managed device

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require MFA OR Compliant Device |

---

## Testing Checklist

- [ ] Users with MFA can register new security info
- [ ] Users on compliant devices can register new security info
- [ ] Users without MFA or compliant device are blocked

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Device Compliance**: [Device Compliance in Intune](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
