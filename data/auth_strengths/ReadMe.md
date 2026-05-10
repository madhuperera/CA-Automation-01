# Authentication Strengths Reference

Authentication Strength policies define which authentication method combinations satisfy MFA in a Conditional Access grant control. Custom strengths complement the three built-in strengths (`Multifactor authentication`, `Passwordless MFA`, `Phishing-resistant MFA`).

Each strength is defined as a `.psd1` file in this folder and deployed by [`scripts/create_auth_strengths.ps1`](../../scripts/create_auth_strengths.ps1).

> **Note on identity:** Unlike Authentication Contexts, the strength `Id` is a server-generated GUID. The deployment script therefore matches existing strengths by `DisplayName` (which must be unique in the tenant) — so treat the `DisplayName` as the stable key.

---

## File schema

```powershell
@{
    DisplayName         = "AS{nn}-Your-Strength-Name"     # Required. Unique in tenant. Acts as the upsert key.
    Description         = "Requires ..."                  # Optional. Free-form text.
    AllowedCombinations = @(                              # Required. One or more authenticationMethodModes values.
        "fido2"
        "windowsHelloForBusiness"
        "x509CertificateMultiFactor"
    )
}
```

| Key                   | Graph property        | Notes                                                                  |
| --------------------- | --------------------- | ---------------------------------------------------------------------- |
| `DisplayName`         | `displayName`         | Required. Used as the lookup key by the deployment script.             |
| `Description`         | `description`         | Optional. Human-readable description.                                  |
| `AllowedCombinations` | `allowedCombinations` | Required. Array of `authenticationMethodModes` values (see below).     |

### Valid `AllowedCombinations` values

`password`, `voice`, `hardwareOath`, `softwareOath`, `sms`, `fido2`, `windowsHelloForBusiness`, `microsoftAuthenticatorPush`, `deviceBasedPush`, `temporaryAccessPassOneTime`, `temporaryAccessPassMultiUse`, `email`, `x509CertificateSingleFactor`, `x509CertificateMultiFactor`, `federatedSingleFactor`, `federatedMultiFactor`.

Combinations may also be expressed as multi-method strings (e.g. `"password,microsoftAuthenticatorPush"`) — see [List authenticationMethodModes](https://learn.microsoft.com/graph/api/authenticationstrengthroot-list-authenticationmethodmodes?view=graph-rest-1.0) for the authoritative list of allowed combinations.

---

## Catalogue

### AS01 - Emergency Break Glass 01

| Attribute       | Value                                                                              |
| --------------- | ---------------------------------------------------------------------------------- |
| **Display**     | AS01-EBG-01                                                                        |
| **Description** | Authentication Strength Requirement for Emergency Break Glass 01                   |
| **Methods**     | `fido2`                                                                            |
| **Use For**     | Break-glass account 1. Requires a FIDO2 security key for emergency tenant access.  |

---

### AS02 - Emergency Break Glass 02

| Attribute       | Value                                                                                       |
| --------------- | ------------------------------------------------------------------------------------------- |
| **Display**     | AS02-EBG-02                                                                                 |
| **Description** | Authentication Strength Requirement for Emergency Break Glass 02                            |
| **Methods**     | `password,softwareOath`                                                                     |
| **Use For**     | Break-glass account 2. Requires a password combined with a software OATH (TOTP) token.      |

---

## Adding a new Authentication Strength

1. Pick the next free `AS{nn}` identifier.
2. Create `AS{nn}.psd1` following the schema above.
3. Update this `ReadMe.md` with a new catalogue entry.
4. Run [`scripts/create_auth_strengths.ps1`](../../scripts/create_auth_strengths.ps1) to deploy.

The deployment script:
- Looks up the policy by `DisplayName` (case-insensitive).
- If found → `PATCH` updates `description` and `allowedCombinations` in place.
- If not found → `POST` creates a new custom policy.

> **Renaming caveat:** Because `DisplayName` is the upsert key, renaming a strength in its `.psd1` will cause a *new* policy to be created. Rename in the Entra portal first (or delete the old one), then update the file.

---

## Required Graph permissions

| Permission                            | Type                  | Notes                            |
| ------------------------------------- | --------------------- | -------------------------------- |
| `Policy.ReadWrite.ConditionalAccess`  | Delegated / Application | Least-privileged scope.        |
| `Policy.ReadWrite.AuthenticationMethod` | Delegated / Application | Higher-privileged alternative. |

Eligible admin roles: **Conditional Access Administrator**, **Security Administrator**.

---

## References

- [Microsoft Graph: Create authenticationStrengthPolicy](https://learn.microsoft.com/graph/api/authenticationstrengthroot-post-policies?view=graph-rest-1.0)
- [authenticationStrengthPolicy resource type](https://learn.microsoft.com/graph/api/resources/authenticationstrengthpolicy?view=graph-rest-1.0)
- [List authenticationMethodModes (allowed combinations)](https://learn.microsoft.com/graph/api/authenticationstrengthroot-list-authenticationmethodmodes?view=graph-rest-1.0)
- [Conditional Access authentication strengths overview](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths)
