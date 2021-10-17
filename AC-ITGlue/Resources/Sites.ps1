function New-ACITGlueSite {
    <#
      .SYNOPSIS
      Sync Sites from Aruba Central to ITGlue locations

      .DESCRIPTION
      Sync Sites from Aruba Central to ITGlue locations

      .EXAMPLE
      New-ACITGlueSites -OrgId 1111111

      .EXAMPLE
      New-ACITGlueSites
    #>

  Param(
    [Parameter(Mandatory = $false)]
    [String]$OrgId
)
    begin {
        $ACEndpoint = "/central/v2/sites"
        $ACSites = (Invoke-ArubaCLRestMethod -uri $ACendpoint -limit 100).sites
        $ReturnArray = @()
        $ReturnData = [PSCustomObject]@{}
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
        $SiteCount= $ACSites.count
        $i = 0
    }
    process {
        # Check for valid Organization
        if (!(Get-ITGlueLocations -org_id $OrgId -ErrorAction SilentlyContinue) -as [bool]) {
            Write-Error "Invalid organization."
            break
        }
        foreach ($Site in $ACSites) {
            Write-Progress -Activity "Processing Site ($($Site.site_name))" -Status "$($i) of $($SiteCount)" -PercentComplete (($i / $SiteCount) * 100)
            $ITGlue_Location = (Get-ITGlueLocations -org_id $OrgId).data.attributes | Where-Object { $_.name -eq $Site.site_name }
            if (!$ITGlue_Location) {
                $data = @{
                    "organization_id" = $OrgId
                    "type" = "locations"
                    attributes = @{
                        "organization_id" = $OrgId
                        "name" = $Site.site_name
                        "address_1" = $Site.address
                        "adress_2" = $null
                        "city" = $Site.city
                        "region_name" = $Site.state
                        "region_id" = 63
                        "postal_code" = $Site.zipcode
                        "country_id" = 2 # Assumes US
                        "latitude" = $Site.latitude
                        "longitude" = $Site.longitude
                    }
                }
                New-ITGlueLocations -org_id $OrgId -data $data | Out-Null
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $Site.site_name
                    "Status" = $true
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            } else { 
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $Site.site_name
                    "Status" = $false
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            }
            $i++
        }
    }
    end { return $ReturnArray }
}