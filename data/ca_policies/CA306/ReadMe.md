# CA306 - Block High-Risk User Behavior for Guests

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA306 |
| **Display Name** | CA306-AllApps:BlockHighRisk-For:Guests-When:RiskDetected |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Risk-Based |

---

## Business Objective

Block guest user access when Azure AD Identity Protection detects high-risk sign-in or user behavior.

## Security Rationale

- **Threat Mitigated**: Compromised guest accounts, anomalous behavior
- **Attack Scenario**: Stolen guest credentials used from unusual location/device
- **Control Type**: Preventive (risk-based detection)
- **Risk Level**: High

---

## Risk Conditions

### Sign-In Risk
- Blocked if **high-risk sign-in detected** (unusual location, impossible travel, malware, etc.)

### User Risk
- Blocked if guest user marked as **compromised** by Identity Protection

---

## User Impact
- Guest users triggering risk signals blocked
- User investigation required for unblock
- Security incident notification sent

---

## Testing Checklist

- [ ] High-risk sign-ins detected and blocked
- [ ] Security team alerted
- [ ] Normal guest access unaffected

---

## References

- **Identity Protection**: [Azure AD Identity Protection](https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/overview-identity-protection)
- **Risk Signals**: [Risk Detections](https://learn.microsoft.com/en-us/azure/active-directory/identity-protection/concept-identity-protection-risks)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
