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

| File | Id | Display name | Enforces |
| ---- | -- | ------------ | -------- |
| [C01.psd1](C01.psd1) | `c1` | `AC01-Require-Compliant-Device` | Action requires a compliant device |
| [C02.psd1](C02.psd1) | `c2` | `AC02-Require-Phish-Resistant-MFA` | Action requires phishing-resistant MFA (FIDO2, Windows Hello for Business, or certificate-based) |
| [C03.psd1](C03.psd1) | `c3` | `AC03-Require-Trusted-Location` | Action requires the user to be on a trusted internal network location |
| [C04.psd1](C04.psd1) | `c4` | `AC04-Require-PRMFA-Or-Compliant-Or-Trusted` | Action requires phishing-resistant MFA, or a compliant device, or a trusted internal network location |

A context only labels an action. What it enforces is set by the Conditional Access policy that targets the context.

### Display name and description length

Keep display names and descriptions short. Microsoft Entra rejects a context whose text is too long with a plain `BadRequest` and no reason, and the limits are not documented. Display names of up to 32 characters and descriptions of up to 121 characters are known to be accepted. `PRMFA` in `AC04` stands for phishing-resistant MFA.

---

## Adding a new Authentication Context

1. Pick the next free `Id` in the `c1`–`c25` range.
2. Create a new file `C{nn}.psd1` (zero-padded for readable sort order).
3. Populate the four required keys following the schema above.
4. Update this `ReadMe.md` with the new entry.
5. Run [`scripts/create_auth_contexts.ps1`](../../scripts/create_auth_contexts.ps1) to deploy.

The deployment script only creates contexts that are missing, so re-running it is safe. A context is created (with a `PATCH` against `/identity/conditionalAccess/authenticationContextClassReferences/{id}`) only when both its `Id` and its `DisplayName` are unused in the tenant. An existing context is never modified, including when the `Id` is already in use under a different name; the run report shows it as skipped.

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
