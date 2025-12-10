# CA104 - Enforce Session Timeout for Admins

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA104 |
| **Display Name** | CA104-AllApps:SessionFrequency-For:Admins-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Privileged Access Control - Session Management |

---

## Business Objective

Limit administrative session duration to 4 hours, forcing re-authentication periodically to reduce risk of stolen session tokens and ensure admins remain actively engaged with access authorization.

## Security Rationale

- **Threat Mitigated**: Compromised session tokens, unattended admin sessions, and lateral movement
- **Attack Scenario**: Attacker compromises admin session token; limited lifetime prevents long-term exploitation
- **Control Type**: Preventive (forces periodic re-authentication)
- **Risk Level**: High - Reduces token abuse window

A session token stolen at the start of the day could be used all day without this control. 4-hour timeout means stolen tokens become useless after that time.

---

## Policy Conditions

### Users
- **Scope**: All users assigned administrative roles
- **Included Roles**: Same 15+ admin roles as CA102-CA103
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA104-Exclude` (only if truly necessary)
  - Break-glass admin groups

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All
- **Excluded**: None

---

## Session Controls

| Control | Setting |
|---------|---------|
| **Session Type** | Sign-in Frequency |
| **Frequency** | Every 4 hours |
| **Authentication Type** | Primary + Secondary (requires password + MFA) |
| **Persistent Browser** | Never allow persistent session |

**Effect**: 
- Admin must re-authenticate every 4 hours
- Cannot maintain persistent browser session ("remember me" disabled)
- Requires both password and MFA at 4-hour boundary

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA104-Exclude`**
- Members bypass session timeout (can have longer sessions)
- Use case: Extremely limited—only if legitimate 8+ hour admin work required
- **Recommendation**: Empty; use scheduling instead of exclusions

### Break-Glass Emergency Admin Groups
- Can have longer sessions in crisis scenarios

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **48-72 hours minimum**
3. Monitor audit logs for session pattern
4. Identify how long typical admin sessions last
5. Assess if 4 hours is appropriate (adjust if needed)

### Phase 2: Validation
1. Review audit data: What's typical admin session length?
2. Are 4-hour interruptions acceptable?
3. Do long-running processes need session re-auth?
4. Adjust timeout if needed (default: 4 hours)
5. Plan communication to admins

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Send admin notification about session timeout
3. Explain why timeout improves security
4. Advise handling long-running tasks
5. Monitor support requests for issues

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track admin session re-authentication frequency daily
- **Alert Threshold**: Any unusual re-auth patterns
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Review session timeout compliance
- **Quarterly**: Audit session length patterns; validate 4-hour timeout is appropriate
- **Annually**: Evaluate if timeout should be adjusted based on business needs

### User Impact
- Admins signing in normally: Not affected
- Admins with long uninterrupted sessions: Interrupted at 4-hour mark
- Interruption: Re-enter password + MFA (2-3 minutes)
- Long-running processes: May timeout if unattended for 4+ hours

### Recommended Practices for Admins
- Sign in, complete task, sign out (optimal)
- For long tasks: Set calendar reminder to re-authenticate at 3.5 hour mark
- Use service accounts with application permissions for long-running automation (not subject to session timeout)

### Rollback Plan
If session timeout causes widespread productivity issues:
1. Change state to `enabledForReportingButNotEnforced` immediately
2. Increase timeout from 4 hours to 8 hours (or appropriate value)
3. Add exclusion group members for admins with legitimate long sessions
4. Re-enforce with adjusted timeout

---

## Session Timeout Adjustment

The 4-hour timeout is configurable in `CA104_Creation.ps1`:

```powershell
$TimeValue = 4  # Change to 6, 8, 12, 24, etc. as needed
$TimeType = "hours"  # Can be "hours" or "days"
```

**Recommended values by scenario:**
- **High-security**: 1-2 hours
- **Standard**: 4 hours (current)
- **Lenient**: 8 hours
- **Very lenient**: 12-24 hours (not recommended for admins)

---

## Dependent Resources

### Security Groups
| Group | Purpose | Member Count |
|-------|---------|--------------|
| `EID-SEC-U-A-CAP-CA104-Exclude` | Long session exceptions (should be minimal) | 0-2 |
| Break-glass admin groups | Emergency access | 1 each |

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] 4-hour timeout is appropriate for business (or adjust as needed)
- [ ] Sample admin experiences session timeout at 4-hour mark
- [ ] Sample admin can re-authenticate with MFA
- [ ] Long-running admin processes reviewed (may timeout)
- [ ] Exclusion group exists (keep minimal)
- [ ] Break-glass accounts not excluded
- [ ] Admins understand session timeout policy
- [ ] Support team trained on session timeout handling

---

## Troubleshooting

### Issue: Admin session unexpectedly times out during important task
**Diagnosis**: 
- Admin at 4-hour mark of continuous session
- Policy functioning as designed

**Resolution**: 
- Have admin re-authenticate at 4-hour mark
- For future: Start task earlier in day, or save state frequently
- For critical ongoing tasks: Use service account with application permissions instead

### Issue: Policy not enforcing session timeout
**Diagnosis**: 
- Policy in reporting mode (not enforcing)
- Session controls not applied
- Policy syntax error

**Resolution**: 
- Verify policy state is `enabled` (not `enabledForReportingButNotEnforced`)
- Check policy `sessionControls` section is correctly formatted
- Re-run `CA104_Creation.ps1` to force update
- Verify policy exists in Entra ID > Conditional Access > Policies

### Issue: Break-glass account also experiencing session timeout
**Diagnosis**: 
- Break-glass not properly excluded from policy
- Long emergency session interrupted

**Resolution**: 
- Verify break-glass groups are in exclusion list
- Re-run `CA104_Creation.ps1` to apply exclusions
- For critical long sessions: Re-authenticate at 4-hour mark as needed

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA102 | Sibling | Requires MFA for admins |
| CA103 | Sibling | Requires phishing-resistant MFA for admins |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Adjust `$TimeValue` (change 4 hours to different timeout)
- ✅ Add/remove roles from included roles
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled`
- ✅ Add exclusions for admins with legitimate long sessions

### Unsafe Changes (High Risk)
- ❌ Remove break-glass group exclusions
- ❌ Set extremely long timeout (defeats security goal)
- ❌ Delete policy script file

### How to Modify
1. Edit `CA104_Creation.ps1`
2. Update `$TimeValue` to desired timeout (hours or days)
3. Update `$IncludedRoles` if roles changed
4. Test in non-production tenant
5. Run `.\scripts\main_script.ps1` to apply

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Session Controls**: [Session Management in CA](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-conditional-access-session)
- **Privileged Access Security**: [Securing privileged access](https://learn.microsoft.com/en-us/security/privileged-access-workstations/)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
