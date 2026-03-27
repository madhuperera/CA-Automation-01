# CA304 - Require MFA for Service Provider Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA304 |
| **Display Name** | CA304-AllApps:RequireMFA-For:ServiceProviderUsers-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Authentication |

---

## Business Objective

Require multi-factor authentication (via authentication strength) for Cloud Service Provider (CSP) / service provider users accessing any application from any network.

## Security Rationale

- **Threat Mitigated**: Credential compromise of service provider accounts with elevated privileges
- **Attack Scenario**: Attacker obtains CSP credentials and accesses customer tenant resources
- **Control Type**: Preventive (MFA via authentication strength)
- **Risk Level**: High

Service provider accounts often have elevated access to manage customer tenants. Enforcing MFA reduces the risk of credential-based attacks.

---

## Policy Conditions

### Users
- **Included Guest/External Types**: `serviceProvider`
- **External Tenants**: All (membershipKind = all)
- **Exclusion Groups**:
  - `EID-SEC-U-A-CAP-CA304-Exclude`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1`
  - `EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2`

### Applications
- **Scope**: All Applications
- **Client App Types**: All

### Locations
- Not configured (applies from any network)

---

## Grant Controls

| Control | Setting |
|---------|--------|
| **Operator** | OR |
| **Grant Type** | Authentication Strength — Multi-Factor Authentication |
| **Auth Strength ID** | `00000000-0000-0000-0000-000000000002` (built-in MFA strength) |

---

## User Impact
- Service provider users must complete MFA on every sign-in
- Setup: Service provider users must register an MFA method (10–20 minutes)
- Ongoing: MFA prompt on each authentication

---

## Testing Checklist

- [ ] Service provider users are prompted for MFA on sign-in
- [ ] Authentication strength enforces acceptable MFA methods
- [ ] Break-glass accounts excluded and functional
- [ ] Other guest types (B2B guests, etc.) are not affected

---

## References

- **Authentication Strength**: [Conditional Access Authentication Strength](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
- **CSP Access**: [Cloud Solution Provider Program](https://learn.microsoft.com/en-us/partner-center/csp-overview)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-03-27 | Corrected: policy requires MFA for service providers (not device platform restriction for guests) |
