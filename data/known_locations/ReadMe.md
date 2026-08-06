# Named Locations Reference

Named locations define geographic and network-based access conditions used by Conditional Access policies.

---

## CL001 - Unknown Locations & Bouvet Island

| Attribute | Value |
|-----------|-------|
| **Type** | Country-based |
| **Countries** | BV (Bouvet Island) |
| **Include Unknown** | Yes |

**Purpose**: Trap for unresolved geolocations (VPN/proxy). Bouvet Island is uninhabited—any user mapping to BV is definitely from unknown location.

**Used By**: CA001

---

## CL002 - B2B Guest Trusted Countries

| Attribute | Value |
|-----------|-------|
| **Type** | Country-based |
| **Countries** | NZ (New Zealand) |
| **Include Unknown** | No |

**Purpose**: Defines trusted countries for B2B collaboration guests. Only New Zealand allowed.

**Used By**: CA301 (block B2B guests outside trusted countries), CA302 (intended trusted-country exclusion for B2B guest MFA policy; current CA302 script does not apply the exclusion due to a variable mismatch)

---

## CL003 - Service Provider Users Trusted Countries

| Attribute | Value |
|-----------|-------|
| **Type** | Country-based |
| **Countries** | NZ (New Zealand) |
| **Include Unknown** | No |

**Purpose**: Defines trusted countries for service providers and vendors. Only New Zealand allowed.

**Used By**: CA303 (block service provider users outside trusted countries)

---

## CL004 - Internal Users Trusted Countries

| Attribute | Value |
|-----------|-------|
| **Type** | Country-based |
| **Countries** | NZ (New Zealand) |
| **Include Unknown** | No |

**Purpose**: Defines trusted countries for internal employees.

**Used By**: CA218

**Travel Exemption**: Employees traveling outside NZ need to contact IT security for temporary exemption or use VPN to NZ office.

---

## CL005 - Internal Users Trusted IP Ranges


| Attribute | Value |
|-----------|-------|
| **Type** | IP-based |
| **Trusted IPs** | **`1.1.1.1/32`** |
| **Is Trusted** | Yes |

**:warning: IMPORTANT:** Replace **`CL005`** and **`1.1.1.1/32`** with your own internal trusted IP ranges!

**Purpose**: Corporate network IP ranges and VPN exit points. Marks trusted internal network locations.

**Used By**: CA202 (require MFA for security info registration — exempts office IPs)

**Note**: CA209 (device enrollment MFA) references office location in its display name but does not configure a location exclusion in its creation script. CL005 is not referenced by CA209.

---

## Adding New Locations

1. Create new `.psd1` file: `CL{nnn}.psd1`
2. Define location using country or IP type
3. Run `scripts/create_known_locations.ps1` (or `scripts/main_script.ps1`) to create or update the location
4. Reference the named location in CA policy scripts as needed

---

## Location Types

### Country-Based

- Used for geographic access control
- Format: Country codes (ISO 3166-1 alpha-2)
- Example: "NZ", "AU", "US"

### IP-Based

- Used for network-based access control
- Format: CIDR notation (IPv4)
- Example: "1.1.1.1/32", "10.0.0.0/24"

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-10 | Initial documentation |
| 1.1 | 2026-06-21 | Added Used By references for CL002 (CA301, CA302), CL003 (CA303), and CL005 (CA202) |
