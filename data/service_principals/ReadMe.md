# Service Principals Reference

Some Conditional Access policies target a Microsoft application that does not have a service principal in every tenant. Microsoft Graph rejects a policy that targets an application without one (`ServicePrincipalNotFound`).

Each application that a policy depends on is defined as a `.psd1` file in this folder and checked by [`scripts/create_service_principals.ps1`](../../scripts/create_service_principals.ps1) at the start of a deployment.

---

## File schema

```powershell
@{
    AppId       = "00000000-0000-0000-0000-000000000000"   # Required. The application (client) ID. Acts as the matching key.
    DisplayName = "Application name"                       # Required. Shown in the prompt and the run report.
    Description = "Why the application is needed"          # Optional. Free-form text.
    RequiredBy  = @("CA###")                               # Required. The policies that target the application.
}
```

---

## Catalogue

| File | Application | App ID | Required by |
| ---- | ----------- | ------ | ----------- |
| [SP001.psd1](SP001.psd1) | Microsoft Intune Enrollment | `d4ebce55-015a-49b5-a083-c84d1797ae8c` | CA220 |

---

## Deployment behaviour

- The check runs first, straight after the tenant confirmation countdown, so that any question is asked while you are still at the keyboard.
- A service principal that already exists is never modified; the run report shows it as skipped.
- When one is missing, the deployment **pauses** and shows a red banner asking whether to create it. Nothing is created without a `Y` answer.
- **Y**: you are asked to sign in a second time to grant `Application.ReadWrite.All`. The script confirms that the session is still connected to the same tenant, and stops the whole deployment if it is not. The service principal is then created.
- **N**: the service principal and the policies listed in `RequiredBy` are reported as skipped. Every other policy is deployed as normal.
- In Core mode the check only applies when a policy listed in `RequiredBy` is part of the Core tier.

## Required permissions

| Step | Graph permission | Role |
| ---- | ---------------- | ---- |
| Check | `Application.Read.All` (already requested by the deployment) | None beyond the deployment roles |
| Create (only after a `Y` answer) | `Application.ReadWrite.All` | Application Administrator, Cloud Application Administrator or Global Administrator |

`Application.ReadWrite.All` is never requested unless a service principal is missing and you choose to create it.

To create a service principal by hand instead:

```powershell
Connect-MgGraph -Scopes "Application.ReadWrite.All"
New-MgServicePrincipal -AppId "d4ebce55-015a-49b5-a083-c84d1797ae8c"
```

---

## References

- [Require multifactor authentication for Intune device enrollments](https://learn.microsoft.com/intune/device-enrollment/configure-multifactor-authentication)
- [Microsoft Graph: Create servicePrincipal](https://learn.microsoft.com/graph/api/serviceprincipal-post-serviceprincipals?view=graph-rest-1.0)
