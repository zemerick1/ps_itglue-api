function New-ACITGlueSites {
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
    }
    process {
        # Check for valid Organization
        if (!(Get-ITGlueLocations -org_id $OrgId -ErrorAction SilentlyContinue) -as [bool]) {
            Write-Error "Invalid organization."
            break
        }
        foreach ($site in $ACSites) {
            $ITGlue_Location = (Get-ITGlueLocations -org_id $OrgId).data.attributes | Where-Object { $_.name -eq $site.site_name }
            if (!$ITGlue_Location) {
                $data = @{
                    "organization_id" = $OrgId
                    "type" = "locations"
                    attributes = @{
                        "organization_id" = $OrgId
                        "name" = $site.site_name
                        "address_1" = $site.address
                        "adress_2" = $null
                        "city" = $site.city
                        "region_name" = $site.state
                        "region_id" = 63
                        "postal_code" = $site.zipcode
                        "country_id" = 2
                        "latitude" = $site.latitude
                        "longitude" = $site.longitude
                    }
                }
                New-ITGlueLocations -org_id $OrgId -data $data | Out-Null
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $site.site_name
                    "Status" = $true
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            } else { 
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $site.site_name
                    "Status" = $false
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            }
        }
    }
    end { return $ReturnArray }
}
New-ACITglueSites -OrgId 5550979