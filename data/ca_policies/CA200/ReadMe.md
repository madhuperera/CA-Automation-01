# CA200 - Require App Protection Policy for Mobile Users

## Policy Overview

| Attribute | Value |
|-----------|-------|
| **Policy ID** | CA200 |
| **Display Name** | CA200-O365:RequireAppProtectionPolicy-For:AllUsers-When:OnMobileDevices |
| **State** | Reporting Only (`enabledForReportingButNotEnforced`) |
| **Category** | Device Management - Mobile Security |

---

## Business Objective

Require Intune app protection policies on mobile devices (iOS/Android) accessing Microsoft 365, ensuring that organization data on personal devices is encrypted and can be remotely wiped.

## Security Rationale

- **Threat Mitigated**: Data exfiltration from unmanaged mobile devices
- **Attack Scenario**: User loses phone with sensitive data, or malware installed on user's personal device
- **Control Type**: Preventive (blocks access from unprotected apps)
- **Risk Level**: Medium-High

App protection policies allow organization data on personal devices to be encrypted, wiped, and controlled without full device management.

---

## Policy Conditions

### Users
- **Scope**: All Users
- **Exclusions**: 
  - `EID-SEC-U-A-CAP-CA200-Exclude` (exceptions for unmanaged devices)
  - Break-glass admin groups
  - Guests/external users (by design)

### Applications
- **Scope**: Microsoft Office 365 (Teams, Excel, Word, PowerPoint, OneDrive, Outlook)
- **Client App Types**: All

### Locations
- **Included**: All
- **Excluded**: None

### Devices
- **Included**: iOS, Android (mobile platforms only)
- **Desktop platforms**: Not affected (Windows, macOS, Linux can access)

---

## Grant Controls

| Control | Setting |
|---------|---------|
| **Operator** | OR |
| **Grant Type** | Require Compliant Application (with app protection policy) |

**Effect**: Users on iOS/Android must use Microsoft Office apps with app protection policy. Unprotected browsers cannot access Office data.

---

## Exclusion Groups

### Policy-Specific Exclusion Group
**`EID-SEC-U-A-CAP-CA200-Exclude`**
- Members bypass app protection requirement
- Use case: Users with managed devices (Intune enrolled), users in countries where Intune not available
- **Management**: Add only when truly necessary; prefer Intune enrollment instead

### Break-Glass Emergency Admin Groups
- Ensures emergency access via mobile if needed

---

## Deployment Timeline

### Phase 1: Audit (Reporting Mode)
1. Deploy policy in `enabledForReportingButNotEnforced` state
2. Duration: **48-72 hours**
3. Monitor which users access from iOS/Android
4. Identify users with app protection policies already configured
5. Assess rollout capacity (who will manage app protection policies)

### Phase 2: Preparation
1. Review audit data: How many users access from mobile?
2. Prepare Intune app protection policies for iOS and Android
3. Test Office app with protection policy on sample devices
4. Create communication for users about app protection requirement
5. Identify users/devices needing exclusions (rare)

### Phase 3: Enforcement
1. Change policy state to `enabled`
2. Users without app protection will be blocked on mobile
3. Provide clear error message directing to enrollment
4. Support team ready to help with app protection setup
5. Monitor support requests

---

## Operational Considerations

### Monitoring & Alerting
- **Metric**: Track app protection policy adoption among mobile users
- **Alert Threshold**: >10% of users blocked = insufficient app protection deployment
- **Review Frequency**: Weekly during first month, then monthly

### Maintenance Tasks
- **Monthly**: Monitor which users are being blocked; ensure they can enroll
- **Quarterly**: Review app protection policy settings; update as security baseline changes
- **Annually**: Verify app protection policies are up-to-date for all users

### User Impact
- Users on iOS/Android will be blocked from Office apps without app protection
- Resolution: Enroll devices in Intune or enable app protection policy
- Setup time: 5-10 minutes for app protection on already-installed app

### Supported Apps
Apps with app protection policy support:
- Microsoft Authenticator
- Microsoft Outlook
- Microsoft Word, Excel, PowerPoint
- Microsoft Teams
- Microsoft OneDrive
- Microsoft Edge (for accessing web apps)

**NOT supported**:
- Third-party browsers (Chrome, Safari cannot be restricted with app protection)
- Unmanaged mail clients

---

## Dependent Resources

### Applications
| App | Platform | Requirement |
|-----|----------|-------------|
| Microsoft Office 365 | iOS, Android | Must have app protection policy |

### Mobile Device Management
- **Intune**: Configuration of app protection policies
- **Policy settings**: Encryption, access controls, wipe capability
- **Managed apps**: Office apps installed via managed app protection

---

## Testing Checklist

Before enforcing this policy, verify:

- [ ] Intune app protection policies created for iOS and Android
- [ ] Sample user can install Office app with protection on iOS/Android
- [ ] Sample user can access O365 with protected app
- [ ] Unprotected browser cannot access Office data (blocked correctly)
- [ ] Exclusion group exists: `EID-SEC-U-A-CAP-CA200-Exclude`
- [ ] Break-glass accounts can access on mobile
- [ ] User communication prepared about app protection requirement
- [ ] Support team trained on app protection enrollment

---

## Troubleshooting

### Issue: User cannot access Office apps on mobile
**Diagnosis**: 
- User device doesn't have app protection policy
- Office app not installed with protection
- Policy enforcing

**Resolution**: 
- Direct user to install protected Office app from app store
- Enroll device in Intune (if available)
- Or add to exclusion group temporarily
- Ensure Intune app protection policy is deployed to user

### Issue: Third-party mail client cannot access Exchange
**Diagnosis**: 
- Gmail, Yahoo mail, or other non-Microsoft client trying to access
- These don't support app protection policy

**Resolution**: 
- User must use Microsoft Outlook with app protection
- Or use web browser to access Outlook Web Access (blocked by separate policy)
- Third-party clients not supported with this control

### Issue: Too many users being excluded from policy
**Diagnosis**: 
- Insufficient app protection policy deployment
- Too many unmanaged devices

**Resolution**: 
- Increase Intune enrollment rate
- Deploy app protection policies more widely
- Review business justification for exclusions
- Remove unnecessary exclusions

---

## Related Policies

| Policy ID | Relationship | Purpose |
|-----------|--------------|---------|
| CA201 | Sibling | Blocks unsupported device types |
| CA203 | Sibling | Session timeout for unmanaged devices |
| CA204 | Sibling | Requires managed device for certain users |
| CA205-CA208 | Complementary | Device controls for internal users |

---

## Policy Modification Guide

### Safe Changes (Low Risk)
- ✅ Update to require different app protection level
- ✅ Add devices to exclusion group (if business need exists)
- ✅ Change state from `enabledForReportingButNotEnforced` to `enabled`

### Unsafe Changes (High Risk)
- ❌ Expand to desktop platforms (creates broader impact)
- ❌ Remove break-glass group exclusions
- ❌ Delete policy script file

### How to Modify
1. Edit `CA200_Creation.ps1`
2. Update `$IncludedApplications` if changing from Office 365
3. Update `$IncludedPlatforms` if adding/removing mobile platforms
4. Update exclusion groups as needed
5. Test in non-production tenant
6. Run `.\scripts\main_script.ps1` to apply

---

## References

- **Microsoft Graph API**: [Conditional Access Policies](https://learn.microsoft.com/en-us/graph/api/resources/conditionalaccesspolicy)
- **App Protection Policies**: [Intune App Protection Overview](https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy)
- **Mobile Device Management**: [Intune Mobile Device Management](https://learn.microsoft.com/en-us/mem/intune/fundamentals/)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial template documentation |
