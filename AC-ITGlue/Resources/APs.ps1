function New-ACITGlueAP {
    <#
      .SYNOPSIS
      Sync conductor AP from Aruba Central to ITGlue configurations

      .DESCRIPTION
      Sync conductor AP from Aruba Central to ITGlue configurations. Function will also create non-existent models in ITGlue.

      .EXAMPLE
      New-ACITGlueAP -OrgId 1111111

      .EXAMPLE
      New-ACITGlueAP
    #>

    Param(
        [Parameter(Mandatory = $false)]
        [String]$OrgId
    )
    begin {
        $endpoint = "/monitoring/v2/aps"
        $Aps = Invoke-ArubaCLRestMethod -uri $endpoint -limit 1000
        $ManufacturerId = 1657387
        $WifiConfigId = 501532
        $ReturnArray = @()
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
    }
    process {
        foreach ($ap in $aps.aps) {
            # Create models even if the AP is not the conductor.
            $model = (Get-ITGlueModels).data.attributes | Where-Object { $_.name -eq $ap.model}
          
            # If model doesn't exist create it.
            if (!$model) {
                $data = @{
                    type = "models"
                    attributes = @{
                        name = $ap.model
                        "manufacturer-id" = $ManufacturerId
                    }
                } 
                New-ITGlueModels -data $data | Out-Null
            }
            if ($ap.swarm_master -eq $false) { continue }

            $ITGlueLocationId = (Get-ITGlueLocations -org_id $OrgId -filter_name $ap.site).data.id
            $model_id = ((Get-ITGlueModels).data | Where-Object { $_.attributes.name -eq $ap.model}).id
            $data = @{
                "organization_id" = $OrgId
                "type" = "configurations"
                attributes = @{
                    "organization_id" = $OrgId
                    "location_id" = $ITGlueLocationId
                    "name" = $ap.name
                    "mac_address" = $ap.macaddr
                    "serial_number" = $ap.serial
                    "primary_ip" = $ap.ip_address
                    "hostname" = $ap.name
                    "operating_system_notes" = $ap.firmware_version
                    "configuration-type-id" = $WifiConfigId
                    "configuration-type-name" = "Wifi"
                    "configuration-type-kind" = "Wifi"
                    "configuration-status-id" = 37495
                    "configuration-status-name" = "Active"
                    "manufacturer_id" = $ManufacturerId
                    "model_id" = $model_id
                }
            }
            $configuration = (Get-ITGlueConfigurations).data.attributes | Where-Object { $_.name -eq $ap.name }
            if (!$configuration) {    
                New-ITGlueConfigurations -data $data | Out-Null
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $ap.name
                    "Status" = $true
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            } else { 
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $ap.name
                    "Status" = $false
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            }
        }
    }
    end { return $ReturnArray }
}

function New-ACITGlueAPConfiguration {
    <#
      .SYNOPSIS
      Sync VC configuration to document

      .DESCRIPTION
      This will build a document for the current configuration and link it to the VC configuration

      .EXAMPLE
      New-ACITGlueAPConfiguration -OrgId 1111111

    #>
    Param(
        [Parameter(Mandatory = $false)]
        [String]$OrgId
    )
    begin {
        $ACEndpoint = "/configuration/v2/groups?limit=20&offset=0"
        $ConfigEndpoint = "/configuration/v1/ap_cli/"

        $Groups = Invoke-ArubaCLRestMethod -uri $ACEndpoint
    }
    process {
        foreach ($Group in $Groups.data) {
            if ($Group -eq "default" -or $Group -eq "unprovisioned") { continue }
            $Config = Invoke-ArubaCLRestMethod -uri ($ConfigEndpoint + $Group)
        }
    }

    end { $Config }
}