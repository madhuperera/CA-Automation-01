# CA152 - Break-Glass Account 2 Authentication Strength

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA152 |
| **Display Name** | CA152-AllApps:AuthStrength-For:EmergencyBreakGlassAccount2-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Privileged Access Control - Emergency Access |

---

## Business Objective

Enforce strong authentication (passwordless or phishing-resistant MFA) for the second emergency break-glass account, providing a redundant emergency access path while maintaining high security.

## Security Rationale

- **Threat Mitigated**: Single point of failure for emergency access
- **Purpose**: Second break-glass account provides redundancy if first account is compromised
- **Control Type**: Preventive (enforces strong authentication)
- **Risk Level**: Critical - Break-glass is last resort access

This policy is identical to CA151 but applies to the second break-glass account. Having TWO break-glass accounts ensures that compromise of one doesn't completely eliminate emergency access.

---

## Policy Conditions

### Users
- **Scope**: Only the emergency break-glass account 2
- **Included Groups**: `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` 
- **Excluded Groups**: `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` (other break-glass account)

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

**Note**: This policy has NO exclusion group. Break-glass accounts must ALWAYS use strong auth.

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
4. Keep this policy in `enabled` state permanently

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

### Redundancy Strategy
**Why TWO break-glass accounts?**
- If account 1 is compromised: Use account 2 to revoke account 1's access
- If account 1 loses authentication method: Use account 2 to re-register account 1's auth
- If account 2 is compromised: Use account 1 to revoke account 2's access
- If both passwords stolen: Both still protected by strong auth requirement

**DO NOT USE BOTH ACCOUNTS FOR SAME PERSON** - Different individuals should hold each account.

---

## Dependent Resources

### Security Groups
| Group | Purpose | Member Count |
|-------|---------|--------------|
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` | The emergency account | 1 user |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` | The other emergency account (excluded) | 1 user |

### Hardware/Methods
- **Windows Hello**: Built into Windows 10/11 (if device supports biometric)
- **FIDO2 Key**: Physical security key ($20-50) 
- **Authenticator**: Microsoft Authenticator app on phone

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] Break-glass account 2 has strong auth method registered
- [ ] Break-glass account 2 can sign in using strong auth method
- [ ] Account can access Exchange Online, SharePoint, Teams, Azure (test all critical services)
- [ ] Strong auth method is stored securely
- [ ] Different person holds account 2 than account 1
- [ ] Both FIDO2 keys (or auth methods) are documented
- [ ] Backup strong auth method exists if possible
- [ ] Account 1 is properly excluded from this policy
- [ ] Policy is set to `enabled` permanently

---

## Troubleshooting

### Issue: Break-glass account 2 cannot sign in after policy enforcement
**Diagnosis**: 
- Strong auth method not registered
- FIDO2 key lost or not functioning
- Windows Hello enrollment failed

**Resolution** (CRITICAL):
1. **Use break-glass account 1** to regain access
2. Register strong auth method on account 2
3. Test authentication with strong method
4. Ensure CA152 policy is enforced
5. Do NOT leave both accounts inaccessible

### Issue: Both break-glass accounts inaccessible
**Diagnosis**: 
- Both accounts lost strong auth methods
- Both locked out by policy

**Resolution** (EMERGENCY ONLY):
1. **This is a severe incident** - You have no admin access
2. Contact Microsoft Support for emergency access
3. Provide proof of identity and organization ownership
4. Microsoft can temporarily disable CA policies
5. **Prevent this**: Test break-glass accounts quarterly
6. **After recovery**: Secure both accounts immediately

### Issue: Need to temporarily access account 2 with weaker authentication
**Diagnosis**: 
- Strong auth method unavailable
- Emergency situation

**Resolution**:
1. **ONLY as absolute last resort**: Temporarily disable CA152
2. Sign in with account 2
3. Re-enable CA152 immediately after
4. Fix the underlying authentication issue
5. Do NOT leave policy disabled

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA151 | Sibling | Similar policy for break-glass account 1 (primary redundancy) |
| CA102-CA104 | Complement | Admin hardening policies (break-glass always excluded) |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Update included group to different break-glass account (if person changes)
- ✅ Change authentication strength requirement
- ✅ Update documentation of strong auth method

### UNSAFE Changes (High Risk - Do NOT Do)
- ❌ Remove the included group
- ❌ Add exclusion group
- ❌ Weaken authentication requirement
- ❌ Delete policy script file

### How to Modify
1. Edit `CA152_Creation.ps1` ONLY if break-glass account ownership changes
2. Update `$IncludedGroups` if different user now holds break-glass role
3. Test in non-production tenant first
4. **Verify account 1 still works** before modifying account 2

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

**TWO break-glass accounts provide redundancy against loss of access. Treat both with highest priority:**

1. **Test BOTH quarterly** - Actually sign in and verify both can access tenant
2. **Secure both authentication methods** - FIDO2 keys must be in different secure locations
3. **Different people hold each** - Do not have one person with both accounts
4. **Document thoroughly** - Who holds each account? Where are the keys? Succession plan if person leaves?
5. **Never lose both** - Losing both accounts means complete loss of tenant control and requires emergency Microsoft intervention
6. **Have backup methods** - More than one way for each account to authenticate
7. **Test emergency access plan** - Ensure procedures to use break-glass accounts are documented and tested

---

## Disaster Recovery Note

If both break-glass accounts become inaccessible:

1. You have **NO administrative access** to your tenant
2. You will need to contact **Microsoft Support**
3. Recovery will require proving:
   - Organization ownership
   - Identity verification
   - Business case for access recovery
4. **Recovery time**: 24-72 hours (not immediate)
5. **Cost**: May incur support charges

**Prevention is far better than recovery:** Test quarterly, maintain secure backups, document procedures.
