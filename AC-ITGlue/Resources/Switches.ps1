function New-ACITGlueSwitch {
    <#
      .SYNOPSIS
      Sync Switches from Aruba Central to ITGlue configurations

      .DESCRIPTION
      Sync Switches from Aruba Central to ITGlue configurations. Function will also create non-existent models in ITGlue.

      .EXAMPLE
      New-ACITGlueSwitches -OrgId 1111111

      .EXAMPLE
      New-ACITGlueSwitches
    #>

    Param(
        [Parameter(Mandatory = $false)]
        [String]$OrgId
    )
    begin {
        $endpoint = "/monitoring/v1/switches"
        $switches = Invoke-ArubaCLRestMethod -uri $endpoint
        $ManufacturerId = 1657387
        $SwitchConfigId = 501527
        $ReturnArray = @()
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
    }
    process {
        foreach ($switch in $switches.switches) {
            # Find Model in IT Glue
            $model = (Get-ITGlueModels).data.attributes | Where-Object { $_.name -eq $switch.model}
            
            # If model doesn't exist create it.
            if (!$model) {
                $data = @{
                    type = "models"
                    attributes = @{
                        name = $switch.model
                        "manufacturer-id" = $ManufacturerId
                    }
                } 
                New-ITGlueModels -data $data | Out-Null
            }

            # Second API call to get the switch model id now that it is created.
            $model_id = ((Get-ITGlueModels).data | Where-Object { $_.attributes.name -eq $switch.model}).id
            $ITGlueLocationId = (Get-ITGlueLocations -org_id $OrgId -filter_name $switch.site).data.id
            $data = @{
                "organization_id" = $OrgId
                "type" = "configurations"
                attributes = @{
                    "organization_id" = $OrgId
                    "location_id" = $ITGlueLocationId
                    "name" = $switch.name
                    "mac_address" = $switch.macaddr
                    "serial_number" = $switch.serial
                    "primary_ip" = $switch.ip_address
                    "hostname" = $switch.name
                    "configuration-type-id" = $SwitchConfigId
                    "configuration-type-name" = "Switch"
                    "configuration-type-kind" = "switch"
                    "configuration-status-id" = 37495
                    "configuration-status-name" = "Active"
                    "manufacturer_id" = $ManufacturerId
                    "model_id" = $model_id
                }
            }
            # Check for existing configuration
            $configuration = (Get-ITGlueConfigurations -organization_id $OrgId).data.attributes | Where-Object { $_.name -eq $switch.name }
            if (!$configuration) {    
                New-ITGlueConfigurations -data $data | Out-Null
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $switch.name
                    "Status" = $true
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            } else { 
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $switch.name
                    "Status" = $false
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            }
        }
    }
    end { return $ReturnArray }
}
