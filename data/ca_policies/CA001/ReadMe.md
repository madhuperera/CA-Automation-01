# CA001 - Block All Apps for All Users from Unknown Locations

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA001 |
| **Display Name** | CA001-AllApps:Block-For:AllUsers-When:UnknownLocations&BouvetIsland |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Foundational Threat Control - Location-Based Access |

---

## Business Objective

Prevent unauthorized access to all Microsoft 365 applications from unknown geographic locations, protecting organizational data and accounts from unauthorized access outside trusted locations.

## Security Rationale

- **Threat Mitigated**: Account compromise from unexpected geographic locations
- **Attack Scenario**: Adversary obtains user credentials and attempts sign-in from unexpected location
- **Control Type**: Preventive (blocks access before it occurs)
- **Risk Level**: High

This policy is a foundational control that blocks access attempts originating from unknown locations. To implement "unknown locations" detection, the policy leverages the **Bouvet Island country code (BV)** combined with the **"Include Unknown Countries and Regions" flag**. 

**Why Bouvet Island?** Bouvet Island is a remote, uninhabited Norwegian territory with essentially zero legitimate business activity or user connectivity. By selecting this extremely low-probability country paired with "include unknown locations," the policy effectively captures all traffic from geolocations that cannot be resolved to a specific country—the hallmark of VPN, proxy, or spoofed location attacks.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA001-Exclude` (policy-specific exclusions)
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` (break-glass admin)
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` (break-glass admin)

### Applications
- **Scope**: All Applications
- **Client App Types**: All (browser, mobile, desktop, etc.)

### Locations
- **Included**: Unknown locations (via Bouvet Island proxy) - `CL001-CN-B-M365Apps-AllUsers-UnknownLocations&BouvetIsland`
- **Excluded**: None
- **Technical Implementation**: Named location uses Bouvet Island (BV) country code with `IncludeUnknownCountriesAndRegions = $true` to detect unresolvable geolocation
- **Rationale**: Since Bouvet Island has no legitimate user population, any detected connection from it is actually an unresolved geolocation (VPN, proxy, or spoofed location)

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
| **Operator** | OR (blocks if ANY condition is true) |
| **Grant Type** | Block |
| **Session Controls** | None |

**Effect**: **Block** - User access is denied; no alternative authentication method can satisfy this policy.

---

## Exclusion Groups

### Why Exclusions Matter
Exclusions prevent legitimate users from being blocked by overly broad policies. They should be minimal and regularly reviewed.

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA001-Exclude`**
- Members added here are exempt from this policy only
- Use case: Service accounts, shared mailboxes, or special users requiring access from Algeria
- **Management**: Add/remove members as business needs change

### Break-Glass Emergency Admin Groups
**`EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`**
**`EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`**
- **Purpose**: Ensure emergency admins can always access the tenant, even if other CA policies lock them out
- **Coverage**: Included in exclusions of ALL CA policies
- **Member Count**: Should be 1-2 users maximum
- **Access**: Monitored and audited heavily; access logged for accountability

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **24-48 hours minimum**
3. Monitor audit logs and CA sign-in logs
4. Identify false positives (legitimate users blocked)
5. Document exclusion candidates

### Phase 2: Validation
1. Review audit data: How many users were blocked?
2. Verify break-glass accounts are working correctly
3. Confirm exclusion group membership is accurate
4. Check for any tenant-specific requirements

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Send user communication about new access restrictions
3. Monitor first week for support requests
4. Be prepared to quickly add exclusions if needed

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track sign-in blocks from unknown locations daily
- **Alert Threshold**: More than 10% of user base blocked unexpectedly = investigate
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Review exclusion group membership; remove unnecessary members
- **Quarterly**: Audit audit logs for patterns; consider adjusting policy scope
- **Annually**: Validate that policy aligns with business requirements; consider expanding to other regions

### Rollback Plan
If deployment causes widespread access disruption:
1. Change state back to `enabledForReportingButNotEnforced` immediately
2. Investigate impact in audit logs
3. Adjust exclusion groups or location definitions
4. Re-test before enforcement

---

## Dependent Resources

### Named Locations
This policy depends on the following named location being defined in the tenant:

| Location ID | Display Name | Type | Country Code | Unknown Locations | Description |
|------------|--------------|------|--------------|-------------------|-------------|
| `CL001` | CL001-CN-B-M365Apps-AllUsers-UnknownLocations&BouvetIsland | Country-Based | BV (Bouvet Island) | ✅ Enabled | Detects unresolved geolocation + unused country code |

**Technical Detail**: The Bouvet Island country code (BV) is intentionally selected as a "trap" for unknown locations. Since no legitimate users connect from Bouvet Island, any hits on this location are actually unresolved geolocations from VPNs, proxies, or spoofed locations. The `IncludeUnknownCountriesAndRegions = $true` flag enables this detection.

**Setup**: Named location is auto-created by `create_known_locations.ps1` from `data/known_locations/CL001.psd1`

### Security Groups
This policy depends on the following groups being created:

| Group | Purpose | Member Count |
|-------|---------|--------------|
| `EID-SEC-U-A-CAP-CA001-Exclude` | Policy-specific exclusions | Varies (managed by operations) |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` | Emergency admin account 1 | 1 |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` | Emergency admin account 2 | 1 |

**Setup**: Groups are auto-created by `create_break_glass_groups.ps1` and `create_groups.ps1`

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] Named location `CL001-CN-B-M365Apps-AllUsers-UnknownLocations&Algeria` exists in tenant
- [ ] Break-glass groups exist and have correct members (1 user each)
- [ ] Policy exclusion group exists: `EID-SEC-U-A-CAP-CA001-Exclude`
- [ ] Policy deployed in reporting mode (`enabledForReportingButNotEnforced`)
- [ ] Audit logs show realistic block patterns (no widespread legitimate user blocks)
- [ ] Break-glass accounts can sign in successfully
- [ ] Known/trusted location access works without blockage
- [ ] Stakeholders informed of upcoming enforcement

---

## Troubleshooting

### Issue: Policy not applying as expected
**Diagnosis**: 
- Verify policy is in `enabled` state (not reporting mode)
- Check that location `CL001` exists with Bouvet Island (BV) country code
- Confirm `IncludeUnknownCountriesAndRegions` is set to `$true` in named location
- Ensure user is not in any exclusion group

**Resolution**: 
- Run `create_known_locations.ps1` to ensure location exists with correct configuration
- Run `create_groups.ps1` to ensure groups exist
- Run `CA001_Creation.ps1` to ensure policy is updated
- Verify `data/known_locations/CL001.psd1` contains correct country code (BV) and unknown location flag

### Issue: Legitimate users blocked from known locations
**Diagnosis**: 
- User location may be geotagged incorrectly by ISP
- Named location definition may be too broad
- Break-glass account exclusion may not be working

**Resolution**: 
- Add user to `EID-SEC-U-A-CAP-CA001-Exclude` group temporarily
- Review named location configuration
- Test break-glass account sign-in separately

### Issue: Break-glass accounts cannot sign in
**Diagnosis**: 
- Break-glass groups may not exist
- Exclusions may not be applied to policy
- Graph API call may have failed

**Resolution**: 
- Run `create_break_glass_groups.ps1` to create groups
- Re-run `CA001_Creation.ps1` to apply exclusions
- Verify group IDs in policy definition match created groups

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA006 | Sibling | Extends location-based blocking to additional countries |
| CA102-CA104 | Complementary | Admin-specific hardening policies |
| CA200-CA208 | Complementary | Device-based access controls |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Add users/groups to `EID-SEC-U-A-CAP-CA001-Exclude`
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled` (after validation)
- ✅ Adjust location list (if named location is updated)

### Unsafe Changes (High Risk)
- ❌ Remove break-glass group exclusions
- ❌ Delete the policy script file (breaks tracking)
- ❌ Change policy `displayName` (breaks update/create detection)

### How to Modify
1. Edit `CA001_Creation.ps1`
2. Test changes in a non-production tenant first
3. Run `.\scripts\main_script.ps1` to apply changes
4. Monitor audit logs for impact

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Named Locations**: [Conditional Access Named Locations](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/location-condition)
- **CA Best Practices**: [Conditional Access Deployment Guide](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/plan-conditional-access)
- **Unknown Locations Pattern**: Using low-probability country codes (Bouvet Island, etc.) combined with "include unknown" flag to detect VPN/proxy traffic

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |

---

## Template Notes for Other Policies

**To adapt this template for other CA policies:**

1. **Update header**: Replace `CA001` with new policy ID
2. **Update sections**:
   - Policy Overview (state, category)
   - Business Objective (specific threat for that policy)
   - Policy Conditions (users, apps, locations, devices, risk)
   - Exclusion Groups (policy-specific exclusion naming)
   - Dependent Resources (named locations and groups specific to policy)
3. **Keep sections as-is** (structure works for all policies):
   - Deployment Timeline
   - Operational Considerations
   - Testing Checklist
   - Troubleshooting
   - Related Policies
   - Policy Modification Guide
4. **Customize Related Policies** table for cross-references
5. **Update Version History** as policy evolves

**Key Principle**: This template balances operational detail with brevity—aim for 1-2 pages per policy.
