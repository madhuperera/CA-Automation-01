# CA305 - Require Compliant Device for Service Providers on Admin Portals

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA305 |
| **Display Name** | CA305-AdminPortals:RequireCompliant-For:ServiceProviderUsers-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Device |

---

## Business Objective

Require Cloud Service Provider (CSP) / service provider users to use a compliant or domain-joined device when accessing Microsoft Admin Portals, ensuring partner administrative access occurs only from trusted, managed devices.

## Security Rationale

- **Threat Mitigated**: Service provider accessing admin portals from unmanaged/non-compliant devices
- **Attack Scenario**: Compromised CSP account signs in to admin portals from an unmanaged personal device
- **Control Type**: Preventive (device compliance gate for admin access)
- **Risk Level**: High

Admin portals provide elevated management capabilities. Restricting service provider access to compliant or domain-joined devices ensures a baseline security posture for administrative operations.

---

## Policy Conditions

### Users
- **Included Guest/External Types**: `serviceProvider`
- **External Tenants**: All (membershipKind = all)
- **Exclusion Groups**:
  - `EID-SEC-U-A-CAP-CA305-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: Microsoft Admin Portals (`MicrosoftAdminPortals`)
- **Client App Types**: All

### Locations
- Not configured (applies from any network)

---

## Grant Controls

| Control | Setting |
|---------|--------|
| **Operator** | OR |
| **Grant Type** | Require Compliant Device **OR** Domain-Joined (Hybrid Azure AD) Device |
| **Built-in Controls** | `compliantDevice`, `domainJoinedDevice` |

---

## User Impact
- Service provider users must use a compliant (Intune-enrolled) or domain-joined device to access admin portals
- Access to non-admin applications is not affected by this policy
- Device enrollment may be required (20–30 minutes setup)

---

## Testing Checklist

- [ ] Service provider on compliant device can access admin portals
- [ ] Service provider on domain-joined device can access admin portals
- [ ] Service provider on unmanaged device is blocked from admin portals
- [ ] Service provider access to non-admin apps is unaffected
- [ ] Break-glass accounts excluded and functional

---

## References

- **Device Compliance**: [Intune Device Compliance](https://learn.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started)
- **Admin Portals**: [Microsoft Admin Portals Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps#microsoft-admin-portals)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: policy requires compliant device for service providers on admin portals (not session timeout for all guests) |
