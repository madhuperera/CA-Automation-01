# CA003 - Block Access to Microsoft Admin Portals for Non-Admin Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA003 |
| **Display Name** | CA003-AdminPortals:Block-For:Global-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Foundational Threat Control - Admin Portal Access |

---

## Business Objective

Prevent non-administrative users from accessing Microsoft Admin Portals (Exchange, Teams, SharePoint, Azure AD), reducing the attack surface and preventing privilege escalation attempts.

## Security Rationale

- **Threat Mitigated**: Unauthorized access to administrative interfaces by non-admin users
- **Attack Scenario**: Compromised non-admin user attempts to access Exchange Admin Center, Teams Admin Center, or other portals to modify policies or create backdoors
- **Control Type**: Preventive (blocks access before it occurs)
- **Risk Level**: High

This policy blocks all users except those with administrative roles from accessing Microsoft administrative portals.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Exclusions (Included Roles)**: 
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
- **Excluded Groups**: 
  - `EID-SEC-U-A-CAP-CA003-Exclude` (policy-specific overrides)
  - Break-glass admin groups

### Applications
- **Scope**: Microsoft Admin Portals
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
| **Grant Type** | Block |

**Effect**: **Block** - Non-admin users cannot access admin portals.

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA003-Exclude`**
- Members bypass role-based access restriction
- Use case: Service accounts, automation systems, or special users needing admin portal access without admin role
- **Note**: Should be minimal; prefer granting actual admin roles instead

### Break-Glass Emergency Admin Groups
**`EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`**
**`EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`**
- Ensures emergency admin access to portals in crisis scenarios
- Always included in policy scope due to admin role assignments

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **24-48 hours minimum**
3. Monitor audit logs for non-admin user attempts
4. Identify users who access admin portals legitimately
5. Determine if they need permanent role grants or exclusion group membership

### Phase 2: Validation
1. Review audit data: Which non-admins accessed admin portals?
2. Business context: Were these legitimate accesses?
3. Solution: Grant roles OR add to exclusion group
4. Verify admin users can still access portals normally

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Send communication explaining access restrictions
3. Provide instructions for role request process
4. Monitor for support requests

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track admin portal access by non-admin roles daily
- **Alert Threshold**: Unusual access patterns = investigate intent
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Review who accessed admin portals (audit logs); verify roles match job functions
- **Quarterly**: Audit exclusion group membership; justify each member
- **Annually**: Review role assignments; remove unused admin roles

### User Impact
- Non-admin users will receive "access denied" when attempting admin portals
- Proper solution: Request admin role grant (not exclusion group membership)
- Setup time: Role activation process varies (minutes to hours)

### Rollback Plan
If deployment blocks legitimate admin access:
1. Change state to `enabledForReportingButNotEnforced` immediately
2. Add affected admin roles to role list
3. Re-run `CA003_Creation.ps1` with updated role IDs
4. Test before re-enforcement

---

## Dependent Resources

### Applications
This policy targets all Microsoft Admin Portals:

| Portal | Scope |
|--------|-------|
| Exchange Admin Center | Exchange Administrator role |
| Teams Admin Center | Teams Administrator role |
| SharePoint Admin Center | SharePoint Administrator role |
| Azure AD Admin Center | Global Administrator, User Administrator roles |
| Microsoft 365 Security Center | Security Administrator role |
| Intune Admin Center | Intune Administrator role |

### Security Groups
| Group | Purpose |
|-------|---------|
| `EID-SEC-U-A-CAP-CA003-Exclude` | Policy-specific exceptions (minimal use) |
| Break-glass admin groups | Emergency access |

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] All admin users have appropriate roles assigned
- [ ] Non-admin users cannot access admin portals (audit logs show blocks)
- [ ] Admins can still access portals normally
- [ ] Exclusion group exists: `EID-SEC-U-A-CAP-CA003-Exclude`
- [ ] Break-glass admin groups have appropriate roles
- [ ] Users informed about role request process
- [ ] Support team trained on role grant procedure
- [ ] Audit logging is enabled for admin portal access

---

## Troubleshooting

### Issue: Admin user blocked from accessing admin portals
**Diagnosis**: 
- User has role assignment but policy not recognizing it
- User role is not in policy's included roles list
- Policy caching delay

**Resolution**: 
- Verify user role assignment in Entra ID admin center
- Add missing role to policy if new admin role exists
- Wait 5-10 minutes for policy cache refresh
- Re-run `CA003_Creation.ps1` to force update

### Issue: Non-admin user should access admin portal
**Diagnosis**: 
- Legitimate business need for non-admin access
- User cannot or should not have admin role

**Resolution**: 
- Add user to `EID-SEC-U-A-CAP-CA003-Exclude` group (temporary)
- Better solution: Grant appropriate admin role (permanent)
- Document business justification for exclusion

### Issue: Service account blocked from admin portal API access
**Diagnosis**: 
- Service account doesn't have admin role
- Service principal cannot complete interactive auth

**Resolution**: 
- Grant service account appropriate admin role
- Or add to exclusion group if role assignment not possible
- Consider using application permissions (scope-based) instead

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA002 | Sibling | Requires MFA for Azure Management (subset of admin portals) |
| CA102-CA104 | Complementary | Additional hardening for admin roles |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Add roles to included roles list (expands access to admins with new roles)
- ✅ Add users to exclusion group (grants access to non-admins with legitimate need)
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled`

### Unsafe Changes (High Risk)
- ❌ Remove break-glass group exclusions
- ❌ Remove all roles (blocks all admin access)
- ❌ Delete policy script file

### How to Modify
1. Edit `CA003_Creation.ps1`
2. Update `$ExcludedRoles` array with new role GUIDs if roles changed
3. Update exclusion groups as needed
4. Test in non-production tenant first
5. Run `.\scripts\main_script.ps1` to apply

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Azure AD Roles**: [Administrator roles in Azure AD](https://learn.microsoft.com/en-us/azure/active-directory/roles/permissions-reference)
- **Admin Portal Security**: [Protecting administrative access](https://learn.microsoft.com/en-us/security/privileged-access-workstations/)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
