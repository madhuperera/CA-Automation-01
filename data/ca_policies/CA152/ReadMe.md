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

Enforce a custom authentication strength for the second emergency break-glass account, providing a redundant emergency access path with a different authentication method from break-glass account 1.

## Security Rationale

- **Threat Mitigated**: Single point of failure for emergency access
- **Purpose**: Second break-glass account provides redundancy if first account is compromised
- **Control Type**: Preventive (enforces strong authentication)
- **Risk Level**: Critical - Break-glass is last resort access

This policy applies to the second break-glass account. Unlike CA151 (which uses `AS01-EBG-01` requiring FIDO2), this policy uses `AS02-EBG-02` (password + software OATH token). Using different authentication requirements for each break-glass account ensures that a loss of one authentication method does not simultaneously lock out both accounts.

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
| **Grant Type** | Authentication Strength (`AS02-EBG-02`) |

**Accepted Methods** (per `data/auth_strengths/AS02.psd1`):
- Password combined with a software OATH token (TOTP)

**NOT Accepted**:
- Password only (without a software OATH token)
- FIDO2 security keys (not in AS02-EBG-02 combination)
- Windows Hello for Business
- Microsoft Authenticator (passwordless phone sign-in)
- SMS codes
- Phone approvals

> **Deployment note**: If `AS02-EBG-02` cannot be resolved at deployment time, the script falls back to the built-in Phishing-resistant MFA strength, which accepts FIDO2, Windows Hello for Business, and certificate-based authentication.

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
1. Review audit data: Is the custom strength working for break-glass account 2?
2. Verify account has a software OATH token registered (required by `AS02-EBG-02`)
3. Test authentication with password + TOTP code
4. Ensure account is excluded from all other CA policies (except this one)
5. Document the registered auth method and TOTP app details

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
- Break-glass account 2 requires both a password and a software OATH token (TOTP) to sign in (per `AS02-EBG-02`)
- This differs from account 1 (CA151), which requires a FIDO2 security key
- Setup: Register a software OATH token (e.g., Microsoft Authenticator or compatible TOTP app) on the account before enforcement

### Redundancy Strategy
**Why TWO break-glass accounts with different authentication requirements?**
- Account 1 (CA151) requires a FIDO2 security key (`AS01-EBG-01`)
- Account 2 (CA152) requires password + software OATH token (`AS02-EBG-02`)
- If account 1's FIDO2 key is lost: Use account 2 to regain access
- If account 2's TOTP app or password is compromised: Account 1 still requires a FIDO2 key (unaffected)
- Separate authentication methods reduce shared-failure risk across both accounts

**DO NOT USE BOTH ACCOUNTS FOR THE SAME PERSON** - Different individuals should hold each account.

---

## Dependent Resources

### Security Groups
| Group | Purpose | Member Count |
|-------|---------|--------------|
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` | The emergency account | 1 user |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` | The other emergency account (excluded) | 1 user |

### Hardware/Methods
- **Software OATH Token**: A TOTP-compatible authenticator app (e.g., Microsoft Authenticator configured as software OATH token). Required by `AS02-EBG-02` in combination with the account password.
- **Password**: The break-glass account password — must be long, random, and stored securely (e.g., sealed envelope in a physically secured location).

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] Break-glass account 2 has a software OATH token registered
- [ ] Break-glass account 2 can sign in using password + TOTP code
- [ ] Account can access Exchange Online, SharePoint, Teams, Azure (test all critical services)
- [ ] Account password is stored securely (sealed envelope or equivalent)
- [ ] Different person holds account 2 than account 1
- [ ] TOTP app and password storage details are documented
- [ ] Account 1 is properly excluded from this policy
- [ ] Policy is set to `enabled` permanently

---

## Troubleshooting

### Issue: Break-glass account 2 cannot sign in after policy enforcement
**Diagnosis**: 
- Software OATH token not registered on the account
- TOTP app unavailable or misconfigured

**Resolution** (CRITICAL):
1. **Use break-glass account 1** to regain access
2. Register a software OATH token on account 2
3. Test authentication with password + TOTP
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

**Two break-glass accounts with different authentication requirements provide resilience against loss of access. Treat both with the highest priority:**

1. **Test BOTH quarterly** - Actually sign in and verify both accounts can access the tenant
2. **Account 1 uses a FIDO2 key; Account 2 uses password + TOTP** - These are intentionally different
3. **Different people hold each** - Do not have one person with both accounts
4. **Document thoroughly** - Who holds each account? Where are credentials stored? Succession plan?
5. **Never lose both** - Losing both accounts means complete loss of tenant control and requires emergency Microsoft intervention
6. **Test emergency access plan** - Ensure procedures to use break-glass accounts are documented and tested

---

## Disaster Recovery Note

If both break-glass accounts become inaccessible:

1. You have **NO administrative access** to your tenant
2. You will need to contact **Microsoft Support**
3. Recovery will require proving:
   - Organisation ownership
   - Identity verification
   - Business case for access recovery
4. **Recovery time**: 24-72 hours (not immediate)
5. **Cost**: May incur support charges

**Prevention is far better than recovery:** Test quarterly, maintain secure backups, document procedures.
