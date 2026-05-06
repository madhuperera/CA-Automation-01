# Authentication Contexts Reference

Authentication Context Class References (`acrs`) let Conditional Access policies require step-up authentication for specific protected actions or app-defined operations (Microsoft Graph, SharePoint sensitivity labels, custom apps, PIM role activation, etc.).

Each context is defined as a `.psd1` file in this folder and deployed by [`scripts/create_auth_contexts.ps1`](../../scripts/create_auth_contexts.ps1).

---

## File schema

```powershell
@{
    Id          = "c1"                              # Required. Must be c1..c25 (lowercase).
    DisplayName = "AC01-Require-Compliant-Device"   # Required. Friendly name shown in admin UX.
    Description = "Step-up authentication ..."      # Required. Secondary text for admin UX.
    IsAvailable = $true                             # Required. $false hides from app/CA selection while drafting.
}
```

| Key           | Graph property | Notes                                                          |
| ------------- | -------------- | -------------------------------------------------------------- |
| `Id`          | `id`           | Allowed values `c1`–`c25`. Issued in the `acrs` access token claim. |
| `DisplayName` | `displayName`  | Friendly name used in admin selection UX.                      |
| `Description` | `description`  | Short explanation of what the context enforces.                |
| `IsAvailable` | `isAvailable`  | `$true` publishes for app/CA use; `$false` keeps it draft-only.|

The filename (e.g. `C01.psd1`) is for natural sorting / Git readability only — Microsoft Graph keys on the lowercase `Id` value inside the file.

---

## Catalogue

### C01 - Require Compliant Device

| Attribute    | Value                                                                                  |
| ------------ | -------------------------------------------------------------------------------------- |
| **Id**       | `c1`                                                                                   |
| **Display**  | AC01-Require-Compliant-Device                                                          |
| **Enforces** | Action requires a compliant or hybrid Entra-joined device.                             |

---

### C02 - Require Phish-Resistant MFA

| Attribute    | Value                                                                                  |
| ------------ | -------------------------------------------------------------------------------------- |
| **Id**       | `c2`                                                                                   |
| **Display**  | AC02-Require-Phish-Resistant-MFA                                                       |
| **Enforces** | Action requires phishing-resistant MFA (FIDO2, WHfB, or certificate-based).            |

---

### C03 - Require MFA Re-authentication

| Attribute    | Value                                                                                  |
| ------------ | -------------------------------------------------------------------------------------- |
| **Id**       | `c3`                                                                                   |
| **Display**  | AC03-Require-MFA-Reauthentication                                                      |
| **Enforces** | Fresh MFA challenge regardless of session age.                                         |

---

### C04 - Require Trusted Location

| Attribute    | Value                                                                                  |
| ------------ | -------------------------------------------------------------------------------------- |
| **Id**       | `c4`                                                                                   |
| **Display**  | AC04-Require-Trusted-Location                                                          |
| **Enforces** | User must be on a trusted internal network location.                                   |

---

### C05 - High-Risk Admin Action

| Attribute    | Value                                                                                  |
| ------------ | -------------------------------------------------------------------------------------- |
| **Id**       | `c5`                                                                                   |
| **Display**  | AC05-High-Risk-Admin-Action                                                            |
| **Enforces** | Compliant device **AND** phishing-resistant MFA. Intended for sensitive admin ops.     |

---

## Adding a new Authentication Context

1. Pick the next free `Id` in the `c1`–`c25` range.
2. Create a new file `C{nn}.psd1` (zero-padded for readable sort order).
3. Populate the four required keys following the schema above.
4. Update this `ReadMe.md` with the new entry.
5. Run [`scripts/create_auth_contexts.ps1`](../../scripts/create_auth_contexts.ps1) to deploy.

The deployment script uses an idempotent `PATCH` against `/identity/conditionalAccess/authenticationContextClassReferences/{id}`, so re-running it is safe — missing contexts are created, existing ones are updated in place.

---

## Required Graph permissions

| Permission                          | Type                  | Notes                       |
| ----------------------------------- | --------------------- | --------------------------- |
| `AuthenticationContext.ReadWrite.All` | Delegated / Application | Least-privileged scope.   |
| `Policy.ReadWrite.ConditionalAccess`  | Delegated / Application | Higher-privileged alternative. |

Eligible admin roles: **Security Administrator**, **Conditional Access Administrator**.

> Note: Microsoft Learn flags a known consent issue where this API may require consent to multiple permissions in some tenants.

---

## References

- [Microsoft Graph: Create authenticationContextClassReference (beta POST)](https://learn.microsoft.com/graph/api/conditionalaccessroot-post-authenticationcontextclassreferences?view=graph-rest-beta)
- [Microsoft Graph: Create or Update authenticationContextClassReference (v1.0 PATCH/upsert)](https://learn.microsoft.com/graph/api/authenticationcontextclassreference-update?view=graph-rest-1.0)
- [Conditional Access authentication context overview](https://learn.microsoft.com/entra/identity/conditional-access/concept-conditional-access-cloud-apps#authentication-context)
