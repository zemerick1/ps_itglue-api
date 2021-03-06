function New-ACITGlueNetwork {
    <#
      .SYNOPSIS
      Sync Networks from Aruba Central to ITGlue flexable assets

      .DESCRIPTION
      Sync Networks from Aruba Central to ITGlue flexable assets

      .EXAMPLE
      New-ACITGlueNetwork -OrgId 1111111

      .EXAMPLE
      New-ACITGlueNetwork
    #>

    Param(
        [Parameter(Mandatory = $false)]
        [String]$OrgId
    )
    begin {
        $endpoint = "/monitoring/v2/networks"
        $networks = Invoke-ArubaCLRestMethod -uri $endpoint
        $WirelessFlexId = 234110
        $ReturnArray = @()
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
    }
    process {
        foreach ($network in $networks.networks) {    
            $data = @{
                "organization_id" = $OrgId
                "type" = "flexible-assets"
                attributes = @{
                    "organization-id" = $OrgId
                    "flexible-asset-type-id" = $WirelessFlexId
                    traits = @{
                        "network-name" = $network.essid
                        "ssid" = $network.essid
                        "security-type" = $network.security
                        #"pre-shared-key" = "10101010" # AC Will not return this.
                        "hidden" = "False"
                    }
                }
            }
            $Asset = (Get-ITGlueFlexibleAssets -filter_flexible_asset_type_id $WirelessFlexId `
                -filter_organization_id $OrgId -filter_name $network.essid).data.attributes
            if (!$Asset) { 
                New-ITGlueFlexibleAssets -data $data | Out-Null
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $network.essid
                    "Status" = $true
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            } else {
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $network.essid
                    "Status" = $false
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            }
        }
    }
    end { return $ReturnArray }
}
function Update-ACITGlueNetwork {
    <#
      .SYNOPSIS
      Sync Networks from Aruba Central to ITGlue flexable assets

      .DESCRIPTION
      This will update an existing ITGlue asset with latest information from Aruba Central.

      .EXAMPLE
      Update-ACITGlueNetwork -OrgId 1111111

      .EXAMPLE
      Update-ACITGlueNetwork
    #>

    Param(
        [Parameter(
            Mandatory = $false,
            HelpMessage = "ITGlue Organization ID."
            )]
        [String]$OrgId,
        [Parameter(Mandatory = $false)]
        [string]$IgnoreSite
    )
    begin {
        $WirelessFlexId = 234110
        $ACEndpointNetwork = "/monitoring/v2/networks"
        $ACEndpointSite = "/central/v2/sites"
        $ACSites = (Invoke-ArubaCLRestMethod -uri $ACEndpointSite -limit 100).sites
        $ReturnArray = @()
        # Hacky way to handle SSIDs at more than one location.
        $DenyList = @()
        $SiteCount = $ACSites.Count
        $i = 0
        $j = 0
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
    }
    process {
        foreach ($Site in $ACSites) {
            Write-Progress -Activity "Processing Site ($($Site.site_name))" -Status "$($i) of $($SiteCount)" -PercentComplete (($i / $SiteCount) * 100) -Id 1
            $SiteName = $Site.site_name
            $ACNetworks = Invoke-ArubaCLRestMethod -uri ($ACEndpointNetwork + "?site=" + $SiteName)
            $NetworkCount = $ACNetworks.Count
            foreach ($ACNetwork in $ACNetworks.networks) {
                Write-Progress -Activity "Processing Network ($($ACNetwork.essid))" -Status "$($j) of $($NetworkCount)"  -PercentComplete (($j / $NetworkCount) * 100) -ParentId 1 -Id 2
                $AssetId = (Get-ITGlueFlexibleAssets -filter_flexible_asset_type_id $WirelessFlexId `
                    -filter_organization_id $OrgId -filter_name $ACNetwork.essid).data.id
                $data = @{
                    "organization_id" = $OrgId
                    "type" = "flexible-assets"
                    attributes = @{
                        "organization-id" = $OrgId
                        "flexible-asset-type-id" = $WirelessFlexId
                        traits = @{
                            "network-name" = $ACNetwork.essid
                            "ssid" = $ACNetwork.essid
                            "security-type" = $ACNetwork.security
                            #"pre-shared-key" = "10101010" # AC Will not return this.
                            "hidden" = "False"
                            "physical-location" = (Get-ITGlueLocations -org_id $OrgId -filter_name $SiteName).data.id
                        }   
                    }
                }
                if ($DenyList.Contains($ACNetwork.essid)) {
                    # If network was already processed reset the counter.
                    Write-Progress -Activity "Processing Network ($($ACNetwork.essid))" -Status "Network $($ACNetwork.essid) already processed. Skipping." -Id 2
                    $j = 0
                    continue 
                }
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $SiteName
                    "SSID" = $ACNetwork.essid
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
                Set-ITGlueFlexibleAssets -id $AssetId -data $data | Out-Null
                $DenyList += $ACNetwork.essid
                $j++
            }
            $i++
        }
    } 
    end { return $ReturnArray }
}
