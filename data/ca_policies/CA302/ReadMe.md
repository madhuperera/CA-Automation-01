# CA302 - Restrict Guest Access by Country

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA302 |
| **Display Name** | CA302-AllApps:CountryRestriction-For:Guests-When:HighRiskCountry |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Geographic |

---

## Business Objective

Block guest user access from high-risk countries using named location restrictions.

## Security Rationale

- **Threat Mitigated**: Access from jurisdictions with heightened cyber threat levels
- **Control Type**: Preventive (geographic restriction)
- **Risk Level**: Medium-High

---

## Policy Conditions

### Users
- **Scope**: Guest and external users

### Locations
- **Excluded Countries**: Named location CL006 (high-risk countries)
- Guests cannot access from these countries

---

## User Impact
- Guest users in restricted countries blocked
- Travel exemption process required (contact IT)
- Business-critical countries only

---

## Testing Checklist

- [ ] Guests outside restricted countries can access
- [ ] Guests in restricted countries blocked
- [ ] Exemption process functional

---

## References

- **Named Locations**: [Microsoft Named Locations](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/location-condition)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
