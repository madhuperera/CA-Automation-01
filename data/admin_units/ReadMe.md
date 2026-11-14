# Administrative Units Reference

Administrative units in this repository are restricted management units. They are used to protect the objects that Conditional Access depends on, so that only administrators with a role scoped to the unit can change them.

Each unit is defined as a `.psd1` file in this folder and created by [`scripts/create_admin_units.ps1`](../../scripts/create_admin_units.ps1).

> **Note on identity:** The unit `Id` is a server-generated GUID. The deployment script matches existing units by `DisplayName`, so treat the `DisplayName` as the stable key and do not change it after deployment.

---

## File schema

```powershell
@{
    DisplayName          = "AU{nnn}-A-RES-YourUnitName"   # Required. Acts as the matching key.
    Description          = "Protects ..."                 # Optional. Free-form text.
    RestrictedManagement = $true                          # Required. $true or $false. Fixed at creation.
    MembershipType       = "Assigned"                     # Required. Assigned or Dynamic.
    MembershipRule       = '...'                          # Required only when MembershipType is Dynamic.
}
```

| Key                    | Graph property                 | Notes |
| ---------------------- | ------------------------------ | ----- |
| `DisplayName`          | `displayName`                  | Required. Used as the lookup key by the deployment script. |
| `Description`          | `description`                  | Optional. |
| `RestrictedManagement` | `isMemberManagementRestricted` | Required. Can only be set when the unit is created. |
| `MembershipType`       | `membershipType`               | Required. `Assigned` or `Dynamic`. |
| `MembershipRule`       | `membershipRule`               | Required for `Dynamic` units only. |

### Naming convention

`AU{nnn}-{A|D}-{RES|STD}-{Purpose}`

| Part | Meaning |
| ---- | ------- |
| `AU{nnn}` | Unit number, in the same style as `CA###` policies and `CL###` named locations |
| `A` or `D` | Assigned or dynamic membership |
| `RES` or `STD` | Restricted management or standard unit |
| `Purpose` | What the unit protects |

---

## Catalogue

| File | Display name | Restricted | Membership | Purpose |
| ---- | ------------ | ---------- | ---------- | ------- |
| [AU001.psd1](AU001.psd1) | `AU001-A-RES-ConditionalAccessPolicyObjects` | Yes | Assigned | Protects the groups used by Conditional Access policies, such as the per-policy exclusion and inclusion groups |
| [AU002.psd1](AU002.psd1) | `AU002-A-RES-EmergencyBreakGlassAccounts` | Yes | Assigned | Protects the emergency break-glass accounts and their role groups |

---

## Deployment behaviour

- The script creates a unit only when no unit with the same `DisplayName` exists. An existing unit is never modified; the run report shows it as skipped.
- The units are created empty. The script never adds or removes members; membership is managed in the Microsoft Entra admin center.
- Restricted management cannot be switched on or off after a unit is created. To change it, the unit has to be deleted and created again.
- Creating units requires the `AdministrativeUnit.ReadWrite.All` permission and the Privileged Role Administrator or Global Administrator role.

## What restricted management means

Once an object is a member of a restricted management unit, only administrators with a role assigned at the scope of that unit can modify it. Tenant-wide administrators, including Global Administrators, cannot modify the object directly until they hold a role scoped to the unit.

Plan the unit-scoped role assignments before adding members:

- Adding or removing a user in a protected exclusion group needs a role such as Groups Administrator scoped to `AU001`.
- Resetting a password or managing authentication methods for a protected break-glass account needs a suitable role scoped to `AU002`.

Conditional Access policies continue to read protected groups as before. A policy cannot target an administrative unit directly.

---

## References

- [Administrative units in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/role-based-access-control/administrative-units)
- [Restricted management administrative units](https://learn.microsoft.com/entra/identity/role-based-access-control/admin-units-restricted-management)
- [Microsoft Graph: Create administrativeUnit](https://learn.microsoft.com/graph/api/directory-post-administrativeunits?view=graph-rest-1.0)
