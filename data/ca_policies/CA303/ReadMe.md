# CA303 - Block Service Provider Users Outside Trusted Countries

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA303 |
| **Display Name** | CA303-AllApps:Block-For:ServiceProviderUsers-When:OutsideOfTrustedCountries |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Geographic |

---

## Business Objective

Block Cloud Service Provider (CSP) / service provider users from accessing any application when signing in from outside their trusted countries, restricting partner access to approved geographic locations.

## Security Rationale

- **Threat Mitigated**: Compromised CSP/service provider credentials used from unexpected locations
- **Attack Scenario**: Attacker obtains service provider credentials and signs in from a country outside the trusted list
- **Control Type**: Preventive (location-based block)
- **Risk Level**: High

---

## Policy Conditions

### Users
- **Included Guest/External Types**: `serviceProvider`
- **External Tenants**: All (membershipKind = all)
- **Exclusion Groups**:
  - `EID-SEC-U-A-CAP-CA303-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- **Included**: All locations
- **Excluded**: `CL003-CN-A-AllApps-ServiceProviderUsers-TrustedCountries` (trusted countries for service providers)

---

## Grant Controls

| Control | Setting |
|---------|--------|
| **Operator** | OR |
| **Grant Type** | Block |

---

## User Impact
- Service provider users signing in from trusted countries are unaffected
- Service provider users outside trusted countries are blocked
- Travel exemptions: Add user to `EID-SEC-U-A-CAP-CA303-Exclude` group temporarily

---

## Dependent Resources

| Resource | Name | Purpose |
|----------|------|---------|
| Named Location | `CL003-CN-A-AllApps-ServiceProviderUsers-TrustedCountries` | Defines approved countries for service provider access |

---

## Testing Checklist

- [ ] Service providers in trusted countries can access
- [ ] Service providers outside trusted countries are blocked
- [ ] Named location `CL003` exists and is correctly configured
- [ ] Break-glass accounts excluded and functional
- [ ] Other guest types (B2B guests, etc.) are not affected

---

## References

- **Named Locations**: [Conditional Access Named Locations](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/location-condition)
- **CSP Access**: [Cloud Solution Provider Program](https://learn.microsoft.com/en-us/partner-center/csp-overview)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: policy blocks service providers outside trusted countries (not MFA for all external users) |
