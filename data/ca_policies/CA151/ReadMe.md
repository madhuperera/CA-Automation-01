# CA151 - Break-Glass Account 1 Authentication Strength

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA151 |
| **Display Name** | CA151-AllApps:AuthStrength-For:EmergencyBreakGlassAccount1-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Privileged Access Control - Emergency Access |

---

## Business Objective

Enforce strong authentication (passwordless or phishing-resistant MFA) for the first emergency break-glass account, ensuring that emergency access is secure and auditable.

## Security Rationale

- **Threat Mitigated**: Unauthorized emergency account access if password compromised
- **Purpose**: Break-glass accounts are "emergency only" with minimal usage; strong auth ensures access is legitimate
- **Control Type**: Preventive (enforces strong authentication)
- **Risk Level**: Critical - Break-glass is last resort access

Break-glass accounts are intentionally excluded from other CA policies to guarantee access during crises. This policy ensures that access is still highly secure.

---

## Policy Conditions

### Users
- **Scope**: Only the emergency break-glass account 1
- **Included Groups**: `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` 
- **Excluded Groups**: `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` (other break-glass account)

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All
- **Excluded**: None

### Devices
- **Included**: All
- **Platform Restrictions**: None

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Authentication Strength (Passwordless/Phishing-Resistant) |

**Accepted Methods**:
- Windows Hello for Business
- FIDO2 security keys
- Microsoft Authenticator (passwordless phone sign-in)

**NOT Accepted**:
- Password only
- MFA with TOTP codes
- SMS codes
- Phone approvals

---

## Exclusion Groups

**Note**: This policy has NO exclusion group (`EID-SEC-U-A-CAP-CA151-Exclude`). Break-glass accounts must ALWAYS use strong auth.

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **48-72 hours**
3. Monitor audit logs: Does the break-glass account have strong auth registered?
4. Verify the account can authenticate with registered strong auth method
5. Identify what authentication methods are currently used

### Phase 2: Validation
1. Review audit data: Is strong auth working for break-glass account?
2. Verify account has Windows Hello, FIDO2 key, or Authenticator passwordless registered
3. Test authentication with strong method
4. Ensure account is excluded from all other CA policies (except this one)
5. Document the strong auth method registered

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Break-glass account MUST use strong auth to sign in
3. Verify account can still access tenant
4. Keep this policy in `enabled` state permanently (unlike other policies)

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track break-glass account sign-in attempts and authentication method used
- **Alert Threshold**: Any failed sign-in attempt = investigate immediately
- **Review Frequency**: Monthly minimum (should have very low activity)

### Maintenance Tasks
- **Monthly**: Verify break-glass account still has strong auth method registered
- **Quarterly**: Test break-glass account can still access tenant
- **Annually**: Rotate strong auth credentials (if FIDO2 key, consider backup key)

### User Impact
- Break-glass account cannot sign in with password alone
- Must use Windows Hello, FIDO2 key, or Authenticator passwordless
- Setup: 10-20 minutes for initial strong auth registration

### Critical Note
**DO NOT LOCK OUT YOUR BREAK-GLASS ACCOUNT** - This is your emergency access if all other admins are compromised. Ensure strong auth method is:
- Registered and functional
- Documented and accessible (store FIDO2 key in secure location)
- Tested periodically
- Maintained with backups

---

## Dependent Resources

### Security Groups
| Group | Purpose | Member Count |
|-------|---------|--------------|
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` | The emergency account | 1 user |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` | The other emergency account (excluded) | 1 user |

### Hardware/Methods
- **Windows Hello**: Built into Windows 10/11 (if device supports biometric)
- **FIDO2 Key**: Physical security key ($20-50)
- **Authenticator**: Microsoft Authenticator app on phone

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] Break-glass account has strong auth method registered
- [ ] Break-glass account can sign in using strong auth method
- [ ] Account can access Exchange Online, SharePoint, Teams, Azure (test all critical services)
- [ ] FIDO2 key is stored securely if used
- [ ] Strong auth method is documented (where it's stored, how to use it)
- [ ] Backup strong auth method exists if possible (e.g., backup FIDO2 key or Windows Hello + Authenticator)
- [ ] The other break-glass account (CA152) is properly excluded
- [ ] Policy is set to `enabled` permanently

---

## Troubleshooting

### Issue: Break-glass account cannot sign in after policy enforcement
**Diagnosis**: 
- Strong auth method not registered
- FIDO2 key lost or not functioning
- Windows Hello enrollment failed

**Resolution** (CRITICAL):
1. **Temporarily disable CA151 policy** to regain access
2. Register strong auth method on break-glass account
3. Test authentication with strong method
4. Re-enable policy
5. Do NOT leave policy disabled long-term

### Issue: Break-glass account strong auth method lost/unavailable
**Diagnosis**: 
- FIDO2 key lost or destroyed
- Biometric device no longer available
- Authenticator uninstalled from phone

**Resolution**:
1. If this is emergency: Temporarily disable CA151 to access tenant
2. Register new strong auth method immediately
3. Document where backup method is stored
4. Re-enable CA151
5. Procure backup FIDO2 key

### Issue: Need to temporarily access with weaker authentication
**Diagnosis**: 
- Strong auth method unavailable in emergency
- Need emergency access immediately

**Resolution**:
1. **Only as last resort**: Temporarily change policy to reporting mode
2. Sign in with available auth
3. Fix the underlying issue
4. Re-enforce policy immediately after

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA152 | Sibling | Similar policy for break-glass account 2 |
| CA102-CA104 | Complement | Admin hardening policies (break-glass is always excluded from these) |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Update included group to different break-glass account (if account ownership changes)
- ✅ Change authentication strength ID to stricter requirement
- ✅ Update documentation of strong auth method

### UNSAFE Changes (High Risk - Do NOT Do)
- ❌ Remove the included group (breaks emergency access)
- ❌ Add exclusion group (defeats security purpose)
- ❌ Change to less strict authentication
- ❌ Delete policy script file

### How to Modify
1. Edit `CA151_Creation.ps1` ONLY if break-glass account ownership changes
2. Update `$IncludedGroups` if different user now holds break-glass role
3. Test in non-production tenant (if available)
4. **Verify access works** before running in production

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Authentication Strength**: [CA Authentication Strength](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-authentication-strength)
- **Break-Glass Accounts**: [Emergency Access Accounts](https://learn.microsoft.com/en-us/azure/active-directory/roles/security-emergency-access)
- **Windows Hello**: [Windows Hello for Business](https://learn.microsoft.com/en-us/windows/security/identity-protection/hello-for-business/)
- **FIDO2 Keys**: [FIDO2 Security Key Support](https://learn.microsoft.com/en-us/azure/active-directory/authentication/concept-authentication-passwordless)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |

---

## CRITICAL REMINDER

**Break-glass accounts are your organization's "nuclear option" for access if all other admins are compromised.** Treat CA151 and CA152 with highest priority:

1. **Test quarterly** - Actually sign in and verify access works
2. **Secure the authentication method** - FIDO2 key must be physically secure
3. **Document everything** - Where is the key? Who has it? How do you use it?
4. **Never lock it out** - Losing both break-glass accounts means complete loss of tenant control
5. **Keep backup methods** - Have more than one way to authenticate break-glass accounts
