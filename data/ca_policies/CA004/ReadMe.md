# CA004 - Block Device Code Authentication Transfer

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA004 |
| **Display Name** | CA004-AllApps:Block-For:Global-When:DeviceCodeAuthTransfer |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Foundational Threat Control - Authentication Flow Security |

---

## Business Objective

Prevent attackers from transferring device code authentication tokens to intercept user sign-in sessions on a different device (phishing attack mitigation).

## Security Rationale

- **Threat Mitigated**: Device code flow exploitation and cross-device authentication hijacking
- **Attack Scenario**: Attacker tricks user into entering device code on attacker's device, then attempts to transfer authentication to attacker's session
- **Control Type**: Preventive (blocks unsafe authentication flow)
- **Risk Level**: Medium-High

Device code flow is used by CLI tools, IoT devices, and applications that cannot display a web browser. This policy prevents malicious transfer of the resulting authentication token to attacker-controlled sessions.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA004-Exclude` (legacy tools or devices requiring device code flow)
  - Break-glass admin groups

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All
- **Excluded**: None

### Devices
- **Included**: All
- **Platform Restrictions**: None

### Authentication Flow
- **Condition**: Device Code Authentication Transfer attempts
- **Rationale**: Only blocks cross-device transfer; normal device code flow continues

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Block |

**Effect**: **Block** - Device code authentication transfer is denied.

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA004-Exclude`**
- Members can transfer device code authentication tokens
- Use case: Legacy CLI tools, automation systems, or IoT devices requiring device code flow
- **Warning**: Should be extremely minimal; this is a powerful attack vector

### Break-Glass Emergency Admin Groups
- Ensures emergency admin access via device code if primary auth methods fail

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **48-72 hours minimum** (device code usage may be infrequent)
3. Monitor audit logs for device code transfer attempts
4. Identify which applications/tools use device code flow
5. Determine if any are legitimate and require exclusion

### Phase 2: Validation
1. Review audit data: Are any legitimate device code transfers being blocked?
2. Verify affected applications can work with alternative auth (OAuth, managed identity)
3. Document exclusion candidates
4. Test with legitimate tools

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Communicate to development teams about device code restrictions
3. Provide alternative authentication methods guidance
4. Monitor for unexpected blocks

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track device code authentication transfer attempts daily
- **Alert Threshold**: Any transfer attempts = investigate intent
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Review device code usage in audit logs
- **Quarterly**: Audit exclusion group membership; validate each entry
- **Annually**: Review tools using device code; encourage migration to alternative auth

### User Impact
- CLI tools, IoT devices, and automation scripts may fail
- Most modern tools support OAuth or managed identity (preferred alternatives)
- Migration to alternative auth: Varies (hours to days per tool)

### Rollback Plan
If deployment breaks critical workflows:
1. Change state to `enabledForReportingButNotEnforced` immediately
2. Add affected applications/tools to exclusion group
3. Plan migration to alternative authentication methods
4. Re-test before enforcement

---

## Dependent Resources

### Applications
This policy applies to all applications that use device code flow:

| Type | Examples | Impact |
|------|----------|--------|
| CLI Tools | Azure CLI, GitHub CLI, Kubernetes `kubectl` | Requires OAuth or token-based auth instead |
| IoT Devices | Smart devices, sensors | May require API key or cert-based auth |
| Legacy Apps | Older scripts, automation tools | May need rewrite to support OAuth |

### Security Groups
| Group | Purpose |
|-------|---------|
| `EID-SEC-U-A-CAP-CA004-Exclude` | Applications/tools requiring device code flow |
| Break-glass admin groups | Emergency CLI access |

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] Audit logs show device code usage patterns
- [ ] All legitimate device code tools identified
- [ ] Alternative auth methods available for tools (OAuth, managed identity, API keys)
- [ ] Exclusion group created and configured: `EID-SEC-U-A-CAP-CA004-Exclude`
- [ ] Legacy tools that require device code transfer are documented
- [ ] Development teams notified of device code restrictions
- [ ] CI/CD pipelines don't rely on device code transfer
- [ ] Stakeholders understand the security benefit

---

## Troubleshooting

### Issue: CLI tool or script fails to authenticate
**Diagnosis**: 
- Tool uses device code authentication transfer
- Tool attempts to transfer token across devices
- Policy is blocking the transfer

**Resolution**: 
- Add tool/application to `EID-SEC-U-A-CAP-CA004-Exclude` (temporary)
- Better solution: Migrate tool to OAuth or managed identity auth
- For Azure CLI: Use `az login --use-device-code` with interactive auth instead
- For other tools: Check documentation for alternative auth methods

### Issue: Automation script fails with authentication error
**Diagnosis**: 
- Script uses device code flow to obtain tokens
- Authentication transfer is blocked

**Resolution**: 
- Migrate script to use Service Principal with certificate or secret
- Use managed identities if running on Azure resources
- Update script to use client credentials flow instead of device code flow

### Issue: Break-glass admin cannot access via device code
**Diagnosis**: 
- Device code transfer blocked even for break-glass account
- Break-glass group exclusion not applied correctly

**Resolution**: 
- Verify break-glass groups are properly configured in policy
- Re-run `CA004_Creation.ps1` to ensure exclusions applied
- Test device code flow with excluded account

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA005 | Sibling | Blocks device code flow entirely (more restrictive) |
| CA001 | Complementary | Location-based access control |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Add applications to exclusion group (if legitimate need for device code)
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled` (after validation)
- ✅ Update exclusion group membership

### Unsafe Changes (High Risk)
- ❌ Remove break-glass group exclusions
- ❌ Delete policy script file
- ❌ Expand to block all device code authentication (use CA005 instead)

### How to Modify
1. Edit `CA004_Creation.ps1`
2. Update exclusion groups as needed
3. Test changes in non-production tenant
4. Run `.\scripts\main_script.ps1` to apply

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Device Code Flow**: [Device Code Flow Security](https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-device-code)
- **Alternative Authentication Methods**: [OAuth and Managed Identities](https://learn.microsoft.com/en-us/azure/active-directory/develop/authentication-flows-app-scenarios)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
