# CA305 - Session Timeout for Guest Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA305 |
| **Display Name** | CA305-AllApps:SessionTimeout-For:Guests-When:AnyNetwork |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | External/Guest Access Control - Session |

---

## Business Objective

Enforce limited session lifetime for guest users to reduce risk of unattended access.

## Security Rationale

- **Threat Mitigated**: Unattended guest device access
- **Control Type**: Detective/Preventive
- **Risk Level**: Medium

---

## Session Controls

### Session Timeout
- **Duration**: Configurable (default 2 hours)
- **Effect**: Guest users must re-authenticate after timeout

### Persistent Session Blocking
- Guest users cannot maintain persistent sessions

---

## User Impact
- Guest users re-authenticate after 2 hours
- No persistent browser sessions
- Expected for external access

---

## Testing Checklist

- [ ] Session timeout occurs at configured time
- [ ] Re-authentication works
- [ ] Long-running tasks handled

---

## References

- **Session Controls**: [Conditional Access Session Controls](https://learn.microsoft.com/en-us/azure/active-directory/conditional-access/concept-conditional-access-session)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
