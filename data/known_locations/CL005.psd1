@{
    "@odata.type" = "#microsoft.graph.ipNamedLocation"
    DisplayName = "CL005-IP-A-AllApps-InternalUsers-TrustedLocations"
    IsTrusted = $true
    IpRanges = @(
        @{
            "@odata.type" = "#microsoft.graph.iPv4CidrRange"
            CidrAddress = "1.1.1.1/32"
        }
    )
}