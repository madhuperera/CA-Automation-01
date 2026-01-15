# CA105 - Block Legacy Authentication for Administrative Roles

## Overview

**CA105** is a Conditional Access policy designed to **block legacy authentication protocols** for users with administrative roles. This policy enforces modern authentication methods for privileged accounts, enhancing security by preventing attackers from using legacy protocols (such as SMTP, IMAP, POP3, and older versions of Office clients) to compromise administrative accounts.

**Policy ID**: CA105  
**Display Name**: CA105-AllApps:Block-For:Admins-When:LegacyProtocols  
**Current State**: Report-Only (enabledForReportingButNotEnforced)

## Policy Details

### Target Users
This policy applies to users with the following administrative roles:

- **Global Administrator** (62e90394-69f5-4237-9190-012177145e10)
- **Exchange Administrator** (f2ef992c-3afb-46b9-b7cf-a126ee74c451)
- **Security Administrator** (194ae4cb-b126-40b2-bd5b-6091b380977d)
- **Conditional Access Administrator** (f28a1f50-f6e7-4571-818b-6a12f2af6b6c)
- **Cloud Application Administrator** (29232cdf-9323-42fd-ade2-1d097af3e4de)
- **Application Administrator** (b1be1c3e-b65d-4f19-8427-f6fa0d97feb9)
- **Authentication Administrator** (729827e3-9c14-49f7-bb1b-9608f156bbb8)
- **Azure AD Joined Device Local Administrator** (b0f54661-2d74-4c50-afa3-1ec803f12efe)
- **Dynamics 365 Administrator** (fe930be7-5e62-47db-91af-98c3a49a38b1)
- **Teams Administrator** (c4e39bd9-1100-46d3-8c65-fb160da0071f)
- **Skype for Business Administrator** (9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3)
- **SharePoint Administrator** (158c047a-c907-4556-b7ef-446551a6b5f7)
- **Intune Administrator** (966707d0-3269-4727-9be2-8c3a10f19b9d)
- **Service Support Administrator** (7be44c8a-adaf-4e2a-84d6-ab2649e08a13)
- **User Administrator** (e8611ab8-c189-46e8-94e1-60213ab1f814)

### Applications
- **All applications** are included (not limited to specific services)

### Client App Types
The policy triggers when using:
- **Exchange ActiveSync** clients (legacy Outlook, mobile clients using EAS)
- **Other** clients (covers additional legacy protocols)

### Excluded Groups
To prevent accidental lockout, the following security groups are excluded from this policy:

- **EID-SEC-U-A-CAP-CA105-Exclude** - Break-glass exceptions for CA105
- **EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount1** - Emergency admin account 1
- **EID-SEC-U-A-ROLE-EmergencyBreakGlassAccount2** - Emergency admin account 2

### Access Control
- **Grant Control**: **Block** all matching sign-ins
- **Evaluation Method**: OR operator (if any condition matches, the policy applies)

## Why This Policy Matters

### Security Benefits
✅ **Prevents credential compromise**: Legacy protocols cannot negotiate modern security standards  
✅ **Protects privileged accounts**: Ensures admins use only secure, modern authentication  
✅ **Reduces attack surface**: Eliminates legacy protocol exploitation vectors  
✅ **Improves audit trail**: Modern protocols provide better logging and monitoring  

### Legacy Protocols Blocked
- SMTP, IMAP, POP3 (email protocols)
- Exchange ActiveSync (older versions)
- Office Outlook clients before 2013
- Basic authentication with older Office versions

## Deployment Status

**Current Mode**: Report-Only (`enabledForReportingButNotEnforced`)  
This policy is currently in monitoring mode. No access is blocked yet. This allows your organization to:
- Monitor impact on users and applications
- Identify users still using legacy protocols
- Plan remediation before enforcement

### Transitioning to Enforcement

To enable enforcement:
1. Review the sign-in logs for impact
2. Ensure all admins have migrated to modern authentication
3. Update the `$State` variable to `"enabled"` in the script
4. Run the policy creation script to activate enforcement

## Implementation Notes

### PowerShell Script
The policy is defined in `CA105_Creation.ps1` and includes:
- Automatic group ID lookup from Entra ID
- Policy creation if it doesn't exist
- Policy update if it already exists

### Prerequisites
- Microsoft Graph PowerShell SDK
- Permissions: `Policy.ReadWrite.ConditionalAccess`, `Application.Read.All`
- Required security groups must exist in Entra ID

### Execution
Run this policy as part of the CA-Automation-01 orchestration:
```powershell
.\main_script.ps1
```

## Related Policies

Similar policies in this repository:
- **CA101-CA104**: Other administrative access control policies
- **CA151-CA152**: Device compliance policies
- **CA200-CA212**: Application and location-based policies

## Support & Questions

For questions about this policy or to report issues, please refer to the main [CA-Automation-01 README](../../README.md).

---

**⚠️ WARNING**: This policy affects administrative accounts. Test thoroughly in report-only mode before enabling enforcement to prevent accidental lockout.
