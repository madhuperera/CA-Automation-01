$params = 
@{
	displayName = $null
	state = $null
	conditions = 
        @{
                signInRiskLevels = $null
                clientAppTypes = $null
                applications = 
                @{
                        includeApplications = $null
                        excludeApplications = $null
                        includeUserActions = $null
                }
                users = 
                @{
                        includeUsers = $null
                        excludeUsers = $null
                        includeGroups = $null
                        excludeGroups = $null
                        includeRoles = $null
                        excludeRoles = $null
                        includeGuestsOrExternalUsers = $null
                        excludeGuestsOrExternalUsers = $null
                }
                platforms = 
                @{
                        includePlatforms = $null
                        excludePlatforms = $null
                }
                locations = 
                @{
                        includeLocations = $null
                        excludeLocations = $null
                }
        }
        grantControls = 
        @{
                operator = $null
                builtInControls =$null
                customAuthenticationFactors = $null
                termsOfUse = $null
        }
        sessionControls = 
        @{
                applicationEnforcedRestrictions = $null
                persistentBrowser = $null
                cloudAppSecurity = 
                @{
                        cloudAppSecurityType = $null
                        isEnabled = $null
                }
                signInFrequency = 
                @{
                        value = $null
                        type = $null
                        isEnabled = $null
                }
        }
}

# New-MgIdentityConditionalAccessPolicy -BodyParameter $params