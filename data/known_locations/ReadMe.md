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

---

## CL003 - Service Provider Users Trusted Countries

| Attribute | Value |
|-----------|-------|
| **Type** | Country-based |
| **Countries** | NZ (New Zealand) |
| **Include Unknown** | No |

**Purpose**: Defines trusted countries for service providers and vendors. Only New Zealand allowed.

---

## CL004 - Internal Users Trusted Countries

| Attribute | Value |
|-----------|-------|
| **Type** | Country-based |
| **Countries** | NZ (New Zealand) |
| **Include Unknown** | No |

**Purpose**: Defines trusted countries for internal employees.

**Used By**: CA006

**Travel Exemption**: Employees traveling outside NZ need to contact IT security for temporary exemption or use VPN to NZ office.

---

## CL005 - Internal Users Trusted IP Ranges

| Attribute | Value |
|-----------|-------|
| **Type** | IP-based |
| **Trusted IPs** | 1.1.1.1/32 |
| **Is Trusted** | Yes |

**Purpose**: Corporate network IP ranges and VPN exit points. Marks trusted internal network locations.

---

## Adding New Locations

1. Create new `.psd1` file: `CL{nnn}.psd1`
2. Define location using country or IP type
3. Update `create_known_locations.ps1` to discover and create
4. Reference in CA policy scripts as needed


---

## Location Types
### Country-Based

- Used for geographic access control
- Format: Country codes (ISO 3166-1 alpha-2)
- Example: "NZ", "AU", "US"
O 3166-1 alpha-2)
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
