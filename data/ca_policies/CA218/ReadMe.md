# CA006 - Block Access from Outside Trusted Countries

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA006 |
| **Display Name** | CA006-AllApps:Block-For:AllUsers-When:OutsideOfTrustedCountries |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Foundational Threat Control - Location-Based Access |

---

## Business Objective

Restrict access to Microsoft 365 applications to users in trusted countries only, reducing exposure to geographically distant attacks while allowing legitimate regional business operations.

## Security Rationale

- **Threat Mitigated**: Access from high-risk geographies, nation-state attacks, and compromised foreign endpoints
- **Attack Scenario**: Attacker in country outside trusted list attempts to access organization resources
- **Control Type**: Preventive (blocks access by geography before it occurs)
- **Risk Level**: Medium (lower than unknown locations but addresses regional risks)

This policy complements CA001 by blocking access from countries outside an approved whitelist, rather than blocking only unknown locations.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA006-Exclude` (employees traveling to excluded countries)
  - Break-glass admin groups
  - Guests/external users (by design)
  - Global Administrator role (policy allows this role)

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All locations (inverse logic: outside trusted)
- **Excluded**: Trusted countries only (via `CL004-CN-A-AllApps-InternalUsers-TrustedCountries`)
- **Rationale**: Blocks all traffic except from explicitly whitelisted countries

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
| **Operator** | OR |
| **Grant Type** | Block |

**Effect**: **Block** - Access from non-trusted countries is denied.

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA006-Exclude`**
- Members can access from any country
- Use case: Employees traveling temporarily, VPN users in excluded countries, partners
- **Management**: Add during travel, remove upon return

### Break-Glass Emergency Admin Groups
- Ensures access during crisis scenarios regardless of location

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **1-2 weeks minimum** (captures travel patterns and anomalies)
3. Monitor audit logs for access patterns by country
4. Identify legitimate access from excluded countries
5. Validate named location (CL004) has correct country list

### Phase 2: Validation
1. Review audit data: Are expected countries in trusted list?
2. Identify employees in excluded countries (traveling, relocated, VPN bypass)
3. Create process for temporary country exclusions
4. Verify named location includes all business-required countries
5. Test access from both trusted and untrusted countries

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Send communication about geographic restrictions
3. Provide instructions for travel exemption process
4. Monitor for access from unexpected countries
5. Establish process to handle false positives

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track access attempts from excluded countries daily
- **Alert Threshold**: Unusual geographic patterns = investigate intent
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Review travel requests and exclusion group membership
- **Quarterly**: Audit geographic access patterns; validate trusted country list
- **Annually**: Review business footprint; adjust trusted countries if needed

### User Impact
- Employees traveling to non-trusted countries will be blocked
- Workaround: Add to exclusion group during travel (temporary)
- Users accessing via VPN in trusted country: Not affected (IP geolocated to VPN server location)

### Rollback Plan
If deployment blocks legitimate business operations:
1. Change state to `enabledForReportingButNotEnforced` immediately
2. Add affected countries to trusted location (if valid business need)
3. Or add affected users to exclusion group temporarily
4. Re-test before enforcement

---

## Dependent Resources

### Named Locations
This policy depends on:

| Location ID | Display Name | Type | Purpose |
|------------|--------------|------|---------|
| `CL004` | CL004-CN-A-AllApps-InternalUsers-TrustedCountries | Country-Based | Whitelist of allowed countries |

**Setup**: Named location is auto-created by `create_known_locations.ps1` from `data/known_locations/CL004.psd1`

**Countries Included**: Verify the actual list in CL004.psd1 (e.g., New Zealand, Australia, USA, etc.)

### Security Groups
| Group | Purpose | Member Count |
|-------|---------|--------------|
| `EID-SEC-U-A-CAP-CA006-Exclude` | Temporary travel exemptions | Varies (managed by operations) |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1` | Emergency admin | 1 |
| `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2` | Emergency admin | 1 |

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] Named location `CL004-CN-A-AllApps-InternalUsers-TrustedCountries` exists in tenant
- [ ] Named location contains all countries where business operates
- [ ] Audit logs show access from expected countries only (no anomalies)
- [ ] Travel exemption process documented and communicated
- [ ] Exclusion group exists: `EID-SEC-U-A-CAP-CA006-Exclude`
- [ ] Break-glass admin groups have expected access
- [ ] Policy does not block access from legitimate business countries
- [ ] Support team trained on country exclusion requests

---

## Troubleshooting

### Issue: Legitimate user blocked from accessing resources
**Diagnosis**: 
- User in country not in trusted list
- User traveling outside trusted countries
- ISP geotagged to excluded country

**Resolution**: 
- Add user to `EID-SEC-U-A-CAP-CA006-Exclude` group (temporary)
- Or add country to CL004 named location if legitimate business need
- Or suggest user use VPN in trusted country
- After travel: Remove from exclusion group

### Issue: Named location CL004 doesn't exist
**Diagnosis**: 
- `create_known_locations.ps1` did not run successfully
- CL004.psd1 file missing or misconfigured

**Resolution**: 
- Verify `data/known_locations/CL004.psd1` exists
- Check file format is valid PowerShell data file
- Run `create_known_locations.ps1` to create location
- Verify location exists in Entra ID > Security > Conditional Access > Named locations

### Issue: Breaking legitimate business operations
**Diagnosis**: 
- Key business countries missing from trusted list
- High volume of exclusion requests

**Resolution**: 
- Review audit logs to identify blocked countries
- Add legitimate business countries to CL004.psd1
- Update named location definition
- Re-run `CA006_Creation.ps1` to apply changes

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA001 | Sibling | Blocks unknown locations + Bouvet Island |
| CA200-CA208 | Complementary | Device-based access controls |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Add countries to CL004 named location (expands trusted countries)
- ✅ Add users to exclusion group (temporary travel exemptions)
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled` (after validation)

### Unsafe Changes (High Risk)
- ❌ Remove all countries from CL004 (blocks everyone)
- ❌ Remove break-glass group exclusions
- ❌ Delete policy script file

### How to Modify
1. Edit `data/known_locations/CL004.psd1` to adjust trusted countries
2. Or edit `CA006_Creation.ps1` to update exclusion groups
3. Test changes in non-production tenant first
4. Run `.\scripts\main_script.ps1` to apply

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **Named Locations**: [Location Conditions in CA](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/location-condition)
- **Geo-IP Accuracy**: Note that geoIP databases have ~3% error rate; not 100% reliable for security
- **CA Best Practices**: [Conditional Access Deployment](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/plan-conditional-access)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
