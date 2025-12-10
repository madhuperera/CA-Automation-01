# CA103 - Require Phishing-Resistant MFA for Admins

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA103 |
| **Display Name** | CA103-AllApps:PhishingResistantMFA-For:Admins-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Privileged Access Control - Phishing Prevention |

---

## Business Objective

Enforce phishing-resistant multi-factor authentication methods for all administrative users, preventing account takeover via phishing of MFA codes.

## Security Rationale

- **Threat Mitigated**: Phishing attacks that steal temporary MFA codes or push MFA approvals
- **Attack Scenario**: Attacker phishes admin's password and MFA code, or tricks admin to approve fake MFA push notification
- **Control Type**: Preventive (forces cryptographically secure MFA)
- **Risk Level**: Critical - Addresses most common attack vector against admins

Phishing-resistant methods (FIDO2 keys, Windows Hello, Microsoft Authenticator with passwordless phone sign-in) cannot be socially engineered like time-based codes (TOTP) or push notifications.

---

## Policy Conditions

### Users
- **Scope**: All users assigned administrative roles
- **Included Roles**: Same 15+ admin roles as CA102
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA103-Exclude` (minimal—only truly necessary exclusions)
  - Break-glass admin groups

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All
- **Excluded**: None

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Phishing-Resistant Authentication Strength |

**Effect**: **Require Phishing-Resistant MFA** - Only cryptographically secure methods accepted.

**Acceptable Methods**:
- FIDO2 security keys (most secure)
- Windows Hello for Business (on managed device)
- Microsoft Authenticator with passwordless phone sign-in

**NOT Accepted**:
- Time-based one-time passwords (TOTP)
- SMS codes
- Phone call approvals
- Traditional push notifications

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA103-Exclude`**
- Members bypass phishing-resistant requirement (can use weaker MFA)
- Use case: Temporary transition period, users unable to register phishing-resistant device
- **Warning**: Should be empty after transition period

### Break-Glass Emergency Admin Groups
- Should have FIDO2 keys or Windows Hello registered

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **1-2 weeks minimum**
3. Monitor audit logs to see which admins have phishing-resistant methods
4. Identify admins needing FIDO2 keys or Windows Hello setup
5. Assess capability to provision FIDO2 keys to all admins

### Phase 2: Transition
1. Procure FIDO2 security keys or Windows Hello devices as needed
2. Distribute FIDO2 keys to all admins without phishing-resistant methods
3. Test with sample group in non-production tenant
4. Provide training on phishing-resistant MFA
5. Allow 1-2 week transition period with policy in reporting mode

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Admins without phishing-resistant methods will be prompted to register
3. Monitor transition; add to exclusion group if genuine issue
4. Remove from exclusion group once phishing-resistant setup complete

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track phishing-resistant MFA adoption rate among admins daily
- **Alert Threshold**: Admin signing in without phishing-resistant method = unusual
- **Review Frequency**: Weekly during transition, then monthly

### Maintenance Tasks
- **Monthly**: Verify all admins have phishing-resistant method registered
- **Quarterly**: Audit failed phishing-resistant authentication attempts
- **Annually**: Review and replace FIDO2 keys if lost/damaged

### User Impact
- Admins must register FIDO2 key, Windows Hello, or use Authenticator passwordless
- Setup: 10-20 minutes for FIDO2 key registration or Windows Hello enrollment
- Ongoing: Streamlined access (press button on key, or face/fingerprint)

### Hardware Requirements
- **FIDO2 Security Keys**: $20-50 per key; recommend 2 per admin (primary + backup)
- **Windows Hello**: Built into Windows 10/11; no additional hardware (if biometric available)
- **Microsoft Authenticator**: Mobile app; still requires smartphone

### Rollback Plan
If phishing-resistant deployment causes access disruption:
1. Change state to `enabledForReportingButNotEnforced` immediately
2. Add affected admins to exclusion group
3. Plan alternative: Extend transition period, provide more keys, etc.
4. Resume enforcement once resolved

---

## Dependent Resources

### Security Groups
| Group | Purpose | Member Count |
|-------|---------|--------------|
| `EID-SEC-U-A-CAP-CA103-Exclude` | Transition period exclusions (should empty after transition) | 0-5 |
| Break-glass admin groups | Emergency access (must have FIDO2 or Windows Hello) | 1 each |

### Hardware (if using FIDO2 keys)
- Procure FIDO2-compatible keys (YubiKey, etc.)
- Register with each admin
- Maintain backup key per admin

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] All admins aware of phishing-resistant requirement
- [ ] FIDO2 keys or Windows Hello option available to admins
- [ ] Sample admin can register phishing-resistant method
- [ ] Sample admin can sign in using phishing-resistant method
- [ ] Policy correctly enforces authentication strength (not just MFA)
- [ ] Break-glass accounts have phishing-resistant method registered
- [ ] Exclusion group exists for transition period
- [ ] Support team trained on troubleshooting phishing-resistant methods

---

## Troubleshooting

### Issue: Admin cannot sign in after policy enforcement
**Diagnosis**: 
- Admin doesn't have phishing-resistant method registered
- FIDO2 key lost or not functioning
- Windows Hello enrollment failed

**Resolution**: 
- Add to exclusion group temporarily (if in transition)
- Provide replacement FIDO2 key if lost
- Help admin re-enroll Windows Hello
- Verify authenticator is set to passwordless sign-in mode

### Issue: Not enough FIDO2 keys for all admins
**Diagnosis**: 
- Hardware procurement not complete
- More admins than keys available

**Resolution**: 
- Prioritize distribution to most-used admin accounts first
- Use Windows Hello for admins with capable hardware
- Extend transition period in exclusion group
- Procure more keys

### Issue: Windows Hello enrollment failing
**Diagnosis**: 
- Device doesn't have biometric hardware
- Windows version doesn't support Windows Hello
- Biometric not recognizing user

**Resolution**: 
- Use FIDO2 key instead (works on any device)
- Upgrade Windows if on unsupported version
- Re-enroll biometric or use different method
- Use Microsoft Authenticator passwordless as fallback

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA102 | Sibling | Requires basic MFA for admins (less strict) |
| CA104 | Sibling | Enforces session timeout for admins |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Add/remove roles from included roles
- ✅ Add admins to exclusion group during transition
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled`

### Unsafe Changes (High Risk)
- ❌ Remove break-glass group exclusions
- ❌ Remove all roles
- ❌ Delete policy script file

### How to Modify
1. Edit `CA103_Creation.ps1`
2. Update `$IncludedRoles` array if roles changed
3. Update `$AuthStrengthId` if using different authentication strength
4. Test in non-production tenant
5. Run `.\scripts\main_script.ps1` to apply

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Authentication Strength**: [Conditional Access Authentication Strength](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-authentication-strength)
- **FIDO2 Security Keys**: [Use FIDO2 security keys in Azure AD](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-authentication-passwordless)
- **Phishing-Resistant Auth**: [Plan a passwordless authentication deployment](https://learn.microsoft.com/en-us/azure/active-directory/authentication/howto-authentication-passwordless-deployment)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
