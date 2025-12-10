# CA005 - Block Device Code Flow

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA005 |
| **Display Name** | CA005-AllApps:Block-For:Global-When:DeviceCodeFlow |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Foundational Threat Control - Authentication Flow Security |

---

## Business Objective

Block all device code authentication flows organization-wide, preventing CLI tools, IoT devices, and legacy applications from authenticating with user credentials.

## Security Rationale

- **Threat Mitigated**: Unauthorized CLI/automation access and device code flow exploitation
- **Attack Scenario**: Attacker tricks user into completing device code authentication on attacker's device, or compromised CLI tool uses stolen device code
- **Control Type**: Preventive (blocks high-risk authentication flow entirely)
- **Risk Level**: Medium-High

Device code flow is inherently higher risk because users complete authentication on a device they may not fully trust. This policy enforces modern, OAuth-based authentication instead.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA005-Exclude` (for critical legacy systems that cannot be modernized)
  - Break-glass admin groups

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All
- **Excluded**: None

### Authentication Flow
- **Condition**: Device Code Flow attempts
- **Rationale**: Blocks entire device code flow, forcing migration to OAuth

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Block |

**Effect**: **Block** - Device code flow authentication is denied.

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA005-Exclude`**
- Members can use device code flow
- Use case: Legacy systems that cannot be migrated to OAuth (rare)
- **Critical Warning**: This is a powerful attack vector; keep list extremely minimal
- **Recommendation**: Use as temporary measure during migration; do not keep permanently

### Break-Glass Emergency Admin Groups
- Ensures emergency admin access via alternative means if device code needed

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **72+ hours minimum** (capture weekend and varied usage patterns)
3. Monitor audit logs for device code flow attempts
4. Identify ALL tools and applications using device code flow
5. Create migration plan to OAuth for each tool

### Phase 2: Migration
1. Test OAuth/managed identity alternatives for each tool
2. Update tools to use modern authentication
3. Coordinate with development and operations teams
4. Migrate tools in waves (test → staging → production)
5. Keep device code flow available in exclusion group during migration

### Phase 3: Enforcement
1. After all tools migrated, change policy state to `enabled`
2. Remove all users from exclusion group
3. Monitor for unexpected device code flow attempts (indicates missed tool)
4. Document which tools were migrated and why

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track device code flow attempts daily (should be zero post-enforcement)
- **Alert Threshold**: Any device code flow attempt = investigate and remediate
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Review device code flow audit logs (should be empty)
- **Quarterly**: Verify all tools using OAuth instead of device code
- **Annually**: Review exclusion group membership; enforce migration for any remaining members

### User Impact
- All CLI tools, IoT devices, and legacy scripts require migration
- Modern tools (Azure CLI v2.50+, GitHub CLI, kubectl) support OAuth/managed identity
- Migration can take days to weeks depending on tool/script complexity

### Rollback Plan
If deployment breaks critical systems:
1. Change state to `enabledForReportingButNotEnforced` immediately
2. Add affected tools to exclusion group
3. Create formal migration plan with timeline
4. Re-enforce after migration complete

---

## Dependent Resources

### Applications
This policy applies to all applications using device code flow:

| Type | Current Auth | Required Migration |
|------|--------------|-------------------|
| Azure CLI | Device code | OAuth (built-in) |
| GitHub CLI | Device code | OAuth (built-in) |
| Terraform | Device code | Managed identity or service principal |
| Kubernetes kubectl | Device code | Service account + bearer token |
| Custom scripts | Device code | Service principal + cert/secret or managed identity |

### Security Groups
| Group | Purpose |
|-------|---------|
| `EID-SEC-U-A-CAP-CA005-Exclude` | Temporarily holds tools during migration |
| Break-glass admin groups | Emergency access |

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] All device code flow usage identified and documented
- [ ] Migration plan created for each tool/application
- [ ] OAuth/managed identity alternatives tested for each tool
- [ ] Tools updated to use modern authentication
- [ ] Exclusion group is empty (or contains only temporary migration users)
- [ ] Audit logs show zero device code flow attempts for 48+ hours
- [ ] Development teams trained on OAuth/managed identity
- [ ] Support team knows how to troubleshoot authentication errors
- [ ] Stakeholders understand benefits of modern authentication

---

## Troubleshooting

### Issue: CLI tool or automation fails after policy enforcement
**Diagnosis**: 
- Tool still using device code flow
- Tool not migrated to OAuth or managed identity
- Exclusion list outdated

**Resolution**: 
- Check tool documentation for OAuth/modern auth support
- Update tool to latest version (may have OAuth support now)
- Migrate to service principal authentication
- As temporary workaround: Add tool user to exclusion group + schedule formal migration

### Issue: Audit logs show device code flow attempts after enforcement
**Diagnosis**: 
- Missed tool/application still using device code flow
- Legacy process not updated
- Automated script still using old credentials

**Resolution**: 
- Identify source of attempt in audit logs
- Locate tool/script using device code
- Update or deprecate the tool
- Enforce OAuth/modern authentication

### Issue: Break-glass admin needs device code flow access
**Diagnosis**: 
- Device code is only available authentication method (unlikely)
- Other auth methods failing

**Resolution**: 
- Use alternative authentication method (managed identity, service principal)
- If truly unavoidable: Temporarily add to exclusion group
- Investigate why other auth methods unavailable

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA004 | Sibling | Blocks device code transfer (less restrictive) |
| CA001 | Complementary | Location-based access control |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Add tools to exclusion group during migration (temporary)
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled` (after migration)
- ✅ Document migration progress

### Unsafe Changes (High Risk)
- ❌ Permanently keep users in exclusion group (defeats security goal)
- ❌ Remove break-glass group exclusions
- ❌ Delete policy script file

### How to Modify
1. Edit `CA005_Creation.ps1`
2. Update exclusion group membership as tools migrate
3. Test changes in non-production tenant
4. Run `.\scripts\main_script.ps1` to apply

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Device Code Flow**: [Device Code Flow Security](https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-device-code)
- **OAuth in Azure CLI**: [Azure CLI Authentication](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
- **Managed Identities**: [Azure Managed Identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
