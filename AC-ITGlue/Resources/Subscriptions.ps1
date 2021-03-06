function New-ACITGlueSubscription {
    <#
      .SYNOPSIS
      Sync Subscriptions from Aruba Central to ITGlue licenses

      .DESCRIPTION
      Sync subscriptions from Aruba Central to ITGlue licenses

      .EXAMPLE
      New-ACITGlueSites -OrgId 1111111

      .EXAMPLE
      New-ACITGlueSites

      .EXAMPLE
      This will included expired licenses from Aruba Central.
      New-ACITGlue Sites -OrgID 1111111 -IncludeExpired
    #>

  Param(
    [Parameter(
        Mandatory = $false,
        HelpMessage = "ITGlue Organization ID."
        )]
    [String]$OrgId,
    [Parameter(
        Mandatory = $false,
        HelpMessage = "Will include expired licenses."
    )]
    [switch]$IncludeExpired = $false
    )
    begin {
        $ACEndpoint = "/platform/licensing/v1/subscriptions?license_type=all"
        $Subscriptions = Invoke-ArubaCLRestMethod -uri $ACEndpoint
        $LicenseFlexId = 234119
        $Manufacturer = "Aruba Networks"
        $ReturnArray = @()
        [datetime]$OriginStart = '1970-01-01 00:00:00'
        [datetime]$OriginEnd = '1970-01-01 00:00:00'
        $SubCount = $Subscriptions.subscriptions.Count
        $i = 0
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
    }
    process {
        foreach ($Sub in $Subscriptions.subscriptions) {
            Write-Progress -Activity "Processing Subscription ($($Sub.subscription_key))" -Status "$($i) of $($SubCount)" -PercentComplete (($i / $SubCount) * 100)
            if (!$IncludeExpired) {
                if ($Sub.status -ne "OK") { 
                    $i++
                    continue 
                }
            }
            $StartTime = $Sub.start_date
            $RenewalTime = $Sub.end_date
            $LicenseKey = "<div>" + $Sub.subscription_key + " : " + $Sub.sku + "<br></div>"
            $data = @{
                "organization_id" = $OrgId
                "type" = "flexible-assets"
                attributes = @{
                    "flexible-asset-type-id" = $LicenseFlexId
                    traits = @{
                        "manufacturer" = $Manufacturer
                        "name" = $Sub.subscription_key
                        "seats" = $Sub.quantity
                        "license-key-s" = $LicenseKey
                        "purchase-date" = $OriginStart.AddSeconds($StartTime)
                        "renewal-date"  = $OriginEnd.AddSeconds($RenewalTime)
                        "version" = $Sub.license_type
                    }
                }
            }
            $AssetName = $Manufacturer + " " + $Sub.subscription_key + " " + $Sub.license_type
            $Asset = (Get-ITGlueFlexibleAssets -filter_flexible_asset_type_id $LicenseFlexId `
            -filter_organization_id $OrgId -filter_name $AssetName).data

            if (!$Asset) {
                New-ITGlueFlexibleAssets -organization_id $OrgId -data $data | Out-Null
            }
            $i++
        }
    }
    end { return $ReturnArray }
}
