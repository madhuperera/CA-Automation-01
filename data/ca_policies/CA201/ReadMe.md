# CA201 - Block Unsupported Device Platforms

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA201 |
| **Display Name** | CA201-AllApps:Block-For:Internals-When:UnsupportedDeviceType |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Management - Unsupported Platforms |

---

## Business Objective

Block access from unsupported device platforms (anything not Windows, macOS, iOS, Android, or Linux), preventing access from unknown or emerging device types that cannot be secured.

## Security Rationale

- **Threat Mitigated**: Access from unknown/untrusted device types, compromised emerging platforms
- **Attack Scenario**: Attacker signs in from jailbroken device, custom OS, or device with unknown security posture
- **Control Type**: Preventive (blocks access from unsupported platforms)
- **Risk Level**: Low-Medium (most users are on supported platforms)

This is a "catch-all" policy that blocks access from any device platform not explicitly supported/recognized.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA201-Exclude` (if unsupported platform legitimate use case)
  - Break-glass admin groups
  - Guests/external users (by design)

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All
- **Excluded**: None

### Devices
- **Included**: All platforms
- **Excluded**: Windows, macOS, iOS, Android, Linux (supported platforms)
- **Effect**: Blocks anything NOT in excluded list

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Block |

**Effect**: **Block** - Unsupported device types cannot access.

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA201-Exclude`**
- Members bypass unsupported device check
- Use case: Users with very old devices, custom operating systems, specialized hardware
- **Recommendation**: Should be minimal; encourage device upgrade instead

### Break-Glass Emergency Admin Groups
- Ensures access from any device if emergency

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **24-48 hours**
3. Monitor audit logs for unsupported device types
4. Most likely: Very little traffic from unsupported platforms (if any)
5. Identify any legitimate unsupported device use cases

### Phase 2: Validation
1. Review audit data: Any unsupported platforms detected?
2. If yes: Determine if legitimate use case or anomaly
3. Assess impact on users (should be minimal)
4. Plan exclusions for any legitimate unsupported devices

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Unsupported device types will be blocked
3. Should have minimal user impact
4. Monitor for unexpected blocks

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track attempts from unsupported device types daily
- **Alert Threshold**: Any unsupported device type attempt = investigate
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Review unsupported device access logs (should be minimal)
- **Quarterly**: Audit exclusion group membership
- **Annually**: Update supported platforms list if new platforms emerge

### User Impact
- Users on standard platforms (Windows, macOS, iOS, Android): No impact
- Users on unsupported platforms: Will be blocked
- Workaround: Use supported device, or add to exclusion group

### Supported Platforms
- Windows (all versions)
- macOS (10.15+)
- iOS (13+)
- Android (8+)
- Linux (Ubuntu, CentOS, etc.)

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] Audit logs show access from expected platforms only
- [ ] No unexpected unsupported platforms detected
- [ ] Exclusion group exists: `EID-SEC-U-A-CAP-CA201-Exclude`
- [ ] Any legitimate unsupported platform use documented
- [ ] Users on unsupported platforms identified
- [ ] Break-glass accounts can access from any platform
- [ ] Most users unaffected (on supported platforms)

---

## Troubleshooting

### Issue: User blocked from unsupported device
**Diagnosis**: 
- User device is not Windows, macOS, iOS, Android, or Linux
- Policy enforcing on unsupported platform

**Resolution**: 
- If legitimate: Add user/device to exclusion group (temporary)
- Better solution: Upgrade user to supported device
- Investigate what platform user is using and why

### Issue: Unexpected unsupported platform detected
**Diagnosis**: 
- Unknown device type in audit logs
- May indicate security issue or jailbroken device

**Resolution**: 
- Investigate the unsupported platform
- Is it jailbroken/rooted device?
- Contact user to understand their device
- Block it (unless legitimate use case exists)

### Issue: Policy not blocking as expected
**Diagnosis**: 
- Unsupported devices still accessing
- Policy may be in reporting mode
- Device platform correctly identified

**Resolution**: 
- Verify policy is in `enabled` state (not reporting mode)
- Check excluded platforms list
- Re-run `CA201_Creation.ps1` to force update

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA200 | Sibling | Requires app protection on mobile |
| CA203-CA208 | Sibling | Device controls for internal users |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Add new platform to excluded list (when new OS supported)
- ✅ Add users to exclusion group
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled`

### Unsafe Changes (High Risk)
- ❌ Remove supported platforms from excluded list
- ❌ Remove break-glass group exclusions
- ❌ Delete policy script file

### How to Modify
1. Edit `CA201_Creation.ps1`
2. Update `$ExcludedPlatforms` if new platform becomes supported
3. Update exclusion groups as needed
4. Test in non-production tenant
5. Run `.\scripts\main_script.ps1` to apply

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Device Platforms**: [Device Platform Conditions](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-conditional-access-conditions#device-platforms)
- **Supported Platforms**: Check Microsoft documentation for latest platform support

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
