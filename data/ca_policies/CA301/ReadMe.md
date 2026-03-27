# CA301 - Block B2B Collaboration Guests Outside Trusted Countries

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA301 |
| **Display Name** | CA301-AllApps:Block-For:B2BCollaborationGuests-When:OutsideOfTrustedCountries |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Geographic |

---

## Business Objective

Block B2B collaboration guest users from accessing any application when signing in from outside trusted countries, ensuring guest access is restricted to approved geographic locations.

## Security Rationale

- **Threat Mitigated**: Compromised guest credentials used from unexpected geographic locations
- **Attack Scenario**: Attacker obtains B2B guest credentials and signs in from a country outside the trusted list
- **Control Type**: Preventive (location-based block)
- **Risk Level**: Medium-High

---

## Policy Conditions

### Users
- **Included Guest/External Types**: `b2bCollaborationGuest`
- **External Tenants**: All (membershipKind = all)
- **Exclusion Groups**:
  - `EID-SEC-U-A-CAP-CA301-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All locations
- **Excluded**: `CL002-CN-A-AllApps-B2BCollaborationGuests-TrustedCountries` (trusted countries for B2B guests)

---

## Grant Controls

| Control | Setting |
|---------|--------|
| **Operator** | OR |
| **Grant Type** | Block |

---

## User Impact
- B2B collaboration guests signing in from trusted countries are unaffected
- B2B collaboration guests outside trusted countries are blocked
- Travel exemptions: Add user to `EID-SEC-U-A-CAP-CA301-Exclude` group temporarily

---

## Dependent Resources

| Resource | Name | Purpose |
|----------|------|---------|
| Named Location | `CL002-CN-A-AllApps-B2BCollaborationGuests-TrustedCountries` | Defines approved countries for B2B guest access |

---

## Testing Checklist

- [ ] B2B guests in trusted countries can access
- [ ] B2B guests outside trusted countries are blocked
- [ ] Named location `CL002` exists and is correctly configured
- [ ] Break-glass accounts excluded and functional
- [ ] Other guest types (service provider, etc.) are not affected

---

## References

- **Named Locations**: [Conditional Access Named Locations](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/location-condition)
- **B2B Collaboration**: [Azure AD B2B](https://learn.microsoft.com/en-us/azure/active-directory/external-identities/what-is-b2b)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: policy blocks B2B guests outside trusted countries (not device compliance) |
