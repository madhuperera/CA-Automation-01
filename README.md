<!-- WARNING: The content below is AI generated. Please review and validate before using in production. -->

# CA-Automation-01

Conditional Access Policy Automation

## Overview

This repository provides PowerShell scripts and supporting files to automate the creation and management of Azure AD Conditional Access (CA) policies, known locations, and related groups. It is designed for IT administrators who want to standardize and streamline the deployment of CA policies across their Microsoft 365 tenant.

---

## Table of Contents

- [Overview](#overview)
- [File Structure](#file-structure)
- [How to Run](#how-to-run)
- [Permissions Required](#permissions-required)
- [Scripts](#scripts)
- [CA Policies](#ca-policies)
- [Known Locations](#known-locations)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

---

## File Structure

```plaintext
CA-Automation-01/
│
├── README.md
├── data/
│   ├── adminstrative_units/
│   ├── ca_policies/
│   │   ├── CA001/
│   │   ├── CA002/
│   │   ├── CA003/
│   │   ├── CA004/
│   │   ├── CA005/
│   │   ├── CA006/
│   │   ├── CA102/
│   │   ├── CA103/
│   │   ├── CA104/
│   │   ├── CA151/
│   │   ├── CA152/
│   │   ├── CA200/
│   │   ├── CA201/
│   │   ├── CA202/
│   │   ├── CA203/
│   │   ├── CA204/
│   │   ├── CA205/
│   │   ├── CA206/
│   │   ├── CA207/
│   │   ├── CA208/
│   │   ├── CA300/
│   │   ├── CA301/
│   │   ├── CA302/
│   │   ├── CA303/
│   │   ├── CA304/
│   │   ├── CA305/
│   │   ├── CA306/
│   │   ├── CA307/
│   │   └── ... (additional policies)
│   └── known_locations/
│       ├── CL001.psd1
│       ├── CL002.psd1
│       ├── CL003.psd1
│       ├── CL004.psd1
│       └── ... (additional locations)
├── scripts/
│   ├── create_admin_units.ps1
│   ├── create_break_glass_groups.ps1
│   ├── create_ca_policies.ps1
│   ├── create_groups.ps1
│   ├── create_known_locations.ps1
│   └── main_script.ps1
└── Templates/
    ├── CAPolicy_Filled.json
    └── CAPolicy_Skeleton.ps1
```

---

## How to Run

1. **Clone the repository** to your local machine.
2. **Open PowerShell as Administrator** (recommended for permissions).
3. **Navigate to the `scripts` directory**:
   ```powershell
   cd .\CA-Automation-01\scripts
   ```
4. **Run the main script**:
   ```powershell
   .\main_script.ps1
   ```
   - The script will prompt you to confirm your Microsoft Graph session and tenant.
   - It will sequentially execute scripts to create known locations, break glass groups, exclusion groups, and CA policies.

---

## Permissions Required

To run these scripts, you must have the following Microsoft Graph API permissions:

- `Policy.Read.All`
- `Policy.ReadWrite.ConditionalAccess`
- `Group.ReadWrite.All`
- `Application.Read.All`

You will be prompted to sign in and consent to these permissions when the script connects to Microsoft Graph.

---

## Scripts

- **main_script.ps1**: Entry point for automation. Connects to Microsoft Graph, checks session and tenant, and executes scripts for known locations, groups, and CA policies.
- **create_known_locations.ps1**: Reads location definitions from `data/known_locations/*.psd1` and creates named locations in Azure AD for use in CA policies.
- **create_break_glass_groups.ps1**: Creates emergency access groups ("break glass" accounts) for admin access in case of lockout.
- **create_groups.ps1**: Creates exclusion groups for use in CA policies.
- **create_ca_policies.ps1**: Orchestrates the creation of CA policies by running individual policy scripts from `data/ca_policies`.
- **create_admin_units.ps1**: Manages administrative units if required.

---

## CA Policies

Each CA policy is defined in its own folder under `data/ca_policies/` and has a corresponding PowerShell script (e.g., `CA001_Creation.ps1`). Below is a summary of the included policies:

| Policy  | Description                                                                                 |
|---------|--------------------------------------------------------------------------------------------|
| CA001   | Block access to all apps for all users when from unknown locations (e.g., Algeria).         |
| CA002   | Require MFA for Azure Management for all users.                                             |
| CA003   | Block access to Microsoft Admin Portals for all users except specified exclusions.           |
| CA004   | Block device code authentication transfer for all apps.                                     |
| CA005   | Block legacy protocols for all users.                                                       |
| CA006   | Block access to all apps for all users when outside trusted locations.                      |
| CA102   | Require MFA for admin roles.                                                                |
| CA103   | Require phishing-resistant MFA for admin roles.                                             |
| CA104   | Set session frequency for admin roles.                                                      |
| CA151   | Set authentication strength for Emergency Break Glass Account 1.                            |
| CA152   | Set authentication strength for Emergency Break Glass Account 2.                            |
| CA200   | Require compliant application for all users on all platforms.                               |
| CA201   | Block access to all apps for all users on all platforms except specified exclusions.         |
| CA202   | Require MFA for all users on all platforms except specified exclusions.                      |
| CA203   | Set session frequency for internal users on unmanaged devices.                              |
| CA204   | Require managed device for internal users.                                                  |
| CA205   | Block legacy protocols for internal users.                                                  |
| CA206   | Require MFA for internal users.                                                             |
| CA207   | Require passwordless authentication for internal users.                                     |
| CA208   | Block access for internal users on excluded platforms.                                      |
| CA300   | Block access for unallowed guest types.                                                     |
| CA301   | Block access for service provider users outside trusted countries.                          |
| CA302   | Require authentication strength for service provider users.                                 |
| CA303   | Block access for service provider users outside trusted countries.                          |
| CA304   | Require MFA for service provider users.                                                     |
| CA305   | Require compliant device for service provider users.                                        |
| CA306   | Block access for all guests on unsupported device types.                                    |
| CA307   | Block legacy protocols for all guests.                                                      |
| ...     | Additional policies can be added as needed.                                                 |

Each policy script contains logic to create or update the policy in Azure AD using Microsoft Graph, with customizable exclusions, locations, device filters, and grant controls.

---

## Known Locations

- Defined in `data/known_locations/*.psd1`.
- Used to specify trusted countries, regions, or IP ranges for CA policies.
- Example:
  ```powershell
  @{
      "@odata.type" = "#microsoft.graph.countryNamedLocation"
      DisplayName = "CL001-CN-B-M365Apps-AllUsers-UnknownLocations&Algeria"
      CountriesAndRegions = @("DZ")
      IncludeUnknownCountriesAndRegions = $true
  }
  ```

---

## Troubleshooting

- **Permissions Errors:** Ensure you are running PowerShell as Administrator and have the required Graph API permissions.
- **Registry/Access Errors:** Some scripts may require elevated permissions to modify registry or system settings.
- **Policy Creation Errors:** Check that all required parameters are provided and that group/application IDs are valid.
- **Session Issues:** If you are connected to the wrong tenant, disconnect and reconnect with the correct scopes.

---

## Support

For questions or issues, please contact your IT administrator or refer to the Microsoft documentation for Conditional Access and Microsoft Graph PowerShell.