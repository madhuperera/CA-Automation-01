# CA102 - Require MFA for All Admin Roles

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA102 |
| **Display Name** | CA102-AllApps:RequireMFA-For:Admins-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Privileged Access Control - Admin Hardening |

---

## Business Objective

Enforce multi-factor authentication for all users assigned administrative roles, ensuring that only users with physical device possession can access administrative functions.

## Security Rationale

- **Threat Mitigated**: Unauthorized admin access due to stolen credentials or phishing
- **Attack Scenario**: Attacker compromises admin password and attempts to modify organizational policies
- **Control Type**: Preventive (forces second authentication factor)
- **Risk Level**: Critical - Admins control entire tenant

This policy applies to all administrative roles (15+ roles including Global Admin, Exchange Admin, Teams Admin, Security Admin, etc.).

---

## Policy Conditions

### Users
- **Scope**: All users assigned administrative roles
- **Included Roles**:
  - Global Administrator
  - Exchange Administrator
  - Teams Administrator
  - SharePoint Administrator
  - Application Administrator
  - Security Administrator
  - Privileged Role Administrator
  - Privileged Identity Management Administrator
  - Azure Information Protection Administrator
  - Cloud Application Administrator
  - Conditional Access Administrator
  - Identity Governance Administrator
  - User Administrator
  - Compliance Administrator
  - And others (see policy script for full list)
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA102-Exclude` (minimal use)
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
| **Grant Type** | Multifactor Authentication |

**Effect**: **Require MFA** - Admins must provide second factor to access any application.

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA102-Exclude`**
- Members bypass MFA requirement
- Use case: Service accounts (if absolutely required), legacy systems
- **Critical**: Admins should never be in this group; prefer granting actual MFA capability

### Break-Glass Emergency Admin Groups
- Always excluded to ensure access during MFA system failure
- Should have pre-registered MFA devices

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **24-48 hours**
3. Monitor audit logs for expected MFA prompts
4. Identify any admins without MFA devices registered
5. Verify break-glass accounts can authenticate

### Phase 2: Validation
1. Review audit data: Are all admins receiving MFA prompts?
2. Verify no unexpected access blocks
3. Confirm all admins have MFA methods available
4. Test break-glass account MFA access

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Send admin notification about MFA requirement
3. Provide MFA setup instructions for those without devices
4. Monitor support requests

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track MFA success/failure rates for admins daily
- **Alert Threshold**: >1 MFA failure per admin per day = investigate
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Review admin MFA status; ensure all have registered devices
- **Quarterly**: Audit failed MFA attempts; investigate patterns
- **Annually**: Review admin roles; remove unnecessary admin privileges

### User Impact
- Admins must have MFA device available when accessing tenant
- Setup: 5 minutes to register authenticator app (if not already done)
- Ongoing: Additional 10-30 seconds per sign-in for MFA

### Rollback Plan
If MFA system fails and admins locked out:
1. Change state to `enabledForReportingButNotEnforced` immediately
2. Use break-glass accounts for emergency access
3. Troubleshoot MFA system
4. Re-enforce once fixed

---

## Dependent Resources

### Security Groups
| Group | Purpose | Member Count |
|-------|---------|--------------|
| `EID-SEC-U-A-CAP-CA102-Exclude` | Policy exceptions (should be empty) | 0-2 |
| Break-glass admin groups | Emergency access with MFA | 1 each |

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] All admins have registered at least one MFA device
- [ ] MFA methods are functioning (authenticator app, phone sign-in)
- [ ] Policy applies to all expected admin roles
- [ ] Non-admin users not affected
- [ ] Break-glass accounts can sign in with MFA
- [ ] Exclusion group exists but is empty (or nearly empty)
- [ ] Support team ready to help admins with MFA issues
- [ ] Admins informed about MFA requirement

---

## Troubleshooting

### Issue: Admin cannot sign in with MFA
**Diagnosis**: 
- MFA device not registered
- MFA method not working
- Policy misconfigured

**Resolution**: 
- Verify admin has registered MFA device
- Check MFA method is functional (authenticator app updated, phone available)
- If admin locked out: Use break-glass account to investigate
- Re-run `CA102_Creation.ps1` to ensure policy updated

### Issue: Non-admin receiving MFA prompt
**Diagnosis**: 
- User has admin role but shouldn't
- Role assignment delay (cache)
- Policy has incorrect scope

**Resolution**: 
- Remove admin role from non-admin user
- Wait 5-10 minutes for policy cache refresh
- Verify policy only applies to admin roles

### Issue: MFA requirement too strict, admins complaining
**Diagnosis**: 
- Legitimate business need for MFA bypass
- MFA causing productivity issues

**Resolution**: 
- Confirm MFA is working properly (not user error)
- Document why MFA bypass needed
- Add to exclusion group only as temporary measure
- Plan to resolve underlying issue

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA002 | Sibling | Requires MFA for Azure Management (subset of CA102) |
| CA103 | Sibling | Requires phishing-resistant MFA for admins |
| CA104 | Sibling | Enforces session timeout for admins |
| CA151-CA152 | Complementary | Specific hardening for break-glass accounts |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Add/remove roles from included roles list
- ✅ Change MFA method requirements
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled`

### Unsafe Changes (High Risk)
- ❌ Remove break-glass group exclusions
- ❌ Remove all roles (breaks all admin access)
- ❌ Delete policy script file

### How to Modify
1. Edit `CA102_Creation.ps1`
2. Update `$IncludedRoles` array if roles changed
3. Test in non-production tenant
4. Run `.\scripts\main_script.ps1` to apply

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **MFA Best Practices**: [Protecting identities with MFA](https://learn.microsoft.com/en-us/security/operations/security-monitoring-fundamentals#mfa-enforcement)
- **Admin Role Security**: [Secure Azure AD admin roles](https://learn.microsoft.com/en-us/security/privileged-access-workstations/)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
