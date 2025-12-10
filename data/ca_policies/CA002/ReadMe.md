# CA002 - Require MFA for Azure Management

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA002 |
| **Display Name** | CA002-AzureManagement:RequireMFA-For:Global-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Foundational Threat Control - Privileged Application Access |

---

## Business Objective

Require multi-factor authentication (MFA) for all users accessing Azure Management to protect cloud infrastructure from unauthorized modification and data exfiltration.

## Security Rationale

- **Threat Mitigated**: Unauthorized Azure/Microsoft 365 infrastructure changes due to compromised credentials
- **Attack Scenario**: Attacker obtains user credential and attempts to modify Azure policies, create resources, or escalate privileges
- **Control Type**: Preventive (forces additional authentication factor before granting access)
- **Risk Level**: Critical

This policy targets the Azure Management application specifically, ensuring that any infrastructure changes require additional proof of user identity beyond password authentication.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA002-Exclude` (policy-specific exclusions)
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` (break-glass admin)
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` (break-glass admin)

### Applications
- **Scope**: Azure Management (Microsoft)
- **Client App Types**: All (browser, mobile, desktop, etc.)

### Locations
- **Included**: All
- **Excluded**: None

### Devices
- **Included**: All
- **Platform Restrictions**: None

### Session/Risk
- **Sign-in Risk**: Not configured
- **User Risk**: Not configured

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR (enforces if ANY condition matches) |
| **Grant Type** | Multifactor Authentication |
| **Session Controls** | None |

**Effect**: **Require MFA** - User must provide second factor (authenticator app, phone, FIDO key) to access Azure Management.

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA002-Exclude`**
- Members added here bypass MFA requirement for Azure Management access
- Use case: Legacy systems, service accounts, or applications requiring Azure API access without MFA support
- **Warning**: Every exclusion is a security gap; keep list minimal and audit quarterly

### Break-Glass Emergency Admin Groups
**`EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`**
**`EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`**
- Ensures emergency access to Azure management if primary MFA system fails
- Should have pre-registered MFA devices to access Azure

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **24-48 hours minimum**
3. Monitor audit logs and CA sign-in logs
4. Identify users frequently accessing Azure Management without MFA capability
5. Document service accounts and legacy systems requiring exclusions

### Phase 2: Validation
1. Review audit data: How many users are affected?
2. Verify MFA is functional (authenticator apps, phone sign-in, etc.)
3. Confirm all service accounts that need Azure access are identified
4. Test excluded accounts can still access Azure Management

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Send user communication about MFA requirement
3. Provide MFA setup instructions (authenticator app recommended)
4. Monitor first week for support requests

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track MFA success/failure rates for Azure Management daily
- **Alert Threshold**: MFA failure rate >5% = investigate user issues or MFA system problems
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Review exclusion group membership; remove service accounts no longer needing access
- **Quarterly**: Audit failed MFA attempts; investigate patterns
- **Annually**: Review Azure Management access logs; identify unused exclusions

### User Impact
- Users without pre-registered MFA devices will be blocked
- First-time setup: ~5 minutes to register authenticator app
- Subsequent access: Additional 10-30 seconds for MFA completion

### Rollback Plan
If deployment causes widespread access disruption:
1. Change state to `enabledForReportingButNotEnforced` immediately
2. Add affected users to exclusion group temporarily
3. Adjust MFA method support (enable phone sign-in if needed)
4. Re-test before enforcement

---

## Dependent Resources

### Applications
This policy targets:

| Application | ID | Purpose |
|-------------|----|---------| 
| Azure Management | `797f4846-ba00-4fd7-ba43-dac1f8f63013` | Microsoft Azure portal and management APIs |

### Security Groups
This policy depends on:

| Group | Purpose | Member Count |
|-------|---------|--------------|
| `EID-SEC-U-A-CAP-CA002-Exclude` | Policy-specific exclusions | Varies (service accounts, legacy apps) |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` | Emergency admin account 1 | 1 |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` | Emergency admin account 2 | 1 |

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] MFA methods are available (authenticator app, phone sign-in, etc.)
- [ ] All users have registered at least one MFA device
- [ ] Service accounts requiring Azure API access identified and added to exclusion group
- [ ] Policy exclusion group exists: `EID-SEC-U-A-CAP-CA002-Exclude`
- [ ] Break-glass accounts have pre-registered MFA devices
- [ ] Azure Management access logs show expected MFA prompts
- [ ] Test user can sign in to Azure portal with MFA
- [ ] Stakeholders informed of MFA requirement

---

## Troubleshooting

### Issue: Users cannot access Azure Management
**Diagnosis**: 
- User has not registered MFA device
- MFA method is not compatible with their device
- User is not in exclusion group but should be

**Resolution**: 
- Send user MFA registration instructions
- Verify authenticator app is installed on user device
- Add to exclusion group if legacy system requires Azure access without MFA

### Issue: Service accounts blocked from Azure API access
**Diagnosis**: 
- Service account cannot complete MFA flow
- Application does not support interactive authentication

**Resolution**: 
- Add service account to `EID-SEC-U-A-CAP-CA002-Exclude` group
- Consider migrating to managed identities (eliminates MFA requirement)
- Ensure service account is not over-privileged

### Issue: Break-glass accounts cannot access Azure
**Diagnosis**: 
- MFA method not working or not registered
- Break-glass group not properly configured

**Resolution**: 
- Verify break-glass MFA devices are registered and functional
- Re-run `CA002_Creation.ps1` to ensure policy exclusions applied
- Test break-glass account can access Azure portal

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA003 | Sibling | Blocks access to all admin portals (including Azure) for non-admins |
| CA102-CA104 | Complementary | Additional MFA and hardening for admin roles |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Add service accounts/legacy apps to `EID-SEC-U-A-CAP-CA002-Exclude`
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled` (after validation)
- ✅ Change MFA method (if organization supports alternative methods)

### Unsafe Changes (High Risk)
- ❌ Remove break-glass group exclusions
- ❌ Expand policy to cover all applications
- ❌ Delete the policy script file

### How to Modify
1. Edit `CA002_Creation.ps1`
2. Update exclusion groups as needed
3. Test in non-production tenant first
4. Run `.\scripts\main_script.ps1` to apply changes

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **MFA Best Practices**: [Protecting identities with MFA](https://learn.microsoft.com/en-us/security/operations/security-monitoring-fundamentals#mfa-enforcement)
- **Azure Management Security**: [Secure Azure Resource Management](https://learn.microsoft.com/en-us/security/benchmark/azure/security-controls-v3-access-control#ac-2-accounts-and-access-control)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
