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
        $Switches = Invoke-ArubaCLRestMethod -uri $endpoint
        $ManufacturerId = 1657387
        $SwitchConfigId = 501527
        $ReturnArray = @()
        $SwitchCount = $Switches.Count
        $i = 0
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
    }
    process {
        foreach ($switch in $switches.switches) {
            Write-Progress -Activity "Processing switch ($($switch.name))" -Status "$($i) of $($SwitchCount)" -PercentComplete (($i / $SwitchCount) * 100)

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
            $configuration = (Get-ITGlueConfigurations -organization_id $OrgId).data.attributes | Where-Object { $_."serial-number" -eq $switch.serial }
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
            $i++
        }
    }
    end { return $ReturnArray }
}

function Update-ACITGlueSwitch {
    <#
      .SYNOPSIS
      Update Switches from Aruba Central to ITGlue configurations

      .DESCRIPTION
      Update Switches from Aruba Central to ITGlue configurations. Function will also create non-existent models in ITGlue.

      .EXAMPLE
      Update-ACITGlueSwitches -OrgId 1111111

      .EXAMPLE
      Update-ACITGlueSwitches
    #>

    Param(
        [Parameter(Mandatory = $false)]
        [String]$OrgId
    )
    begin {
        if ($false -eq $ACITGlueStatus) { 
            Write-Error -Message "ERROR: ITGlue or Aruba Central are not connected."
            New-ACITglueConnection 
        }
        $ACEndpoint = "/monitoring/v1/switches"
        $Switches = Invoke-ArubaCLRestMethod -uri $ACEndpoint
        $ManufacturerId = 1657387
        $SwitchConfigId = 501527
        $ReturnArray = @()
        $SwitchCount = $switches.Count
        $i = 0

        if ($null -eq $OrgId -and $null -eq $ACITGlueOrgId) { 
            $OrgId = Get-ACITGlueOrgId
        }
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
    }
    process {
        foreach ($Switch in $switches.switches) {
            Write-Progress -Activity "Processing switch ($($Switch.name))" -Status "$($i) of $($SwitchCount)" -PercentComplete (($i / $SwitchCount) * 100)
            # Find Model in IT Glue
            $model = (Get-ITGlueModels).data.attributes | Where-Object { $_.name -eq $Switch.model}
            
            # If model doesn't exist create it.
            if (!$model) {
                $data = @{
                    type = "models"
                    attributes = @{
                        name = $Switch.model
                        "manufacturer-id" = $ManufacturerId
                    }
                } 
                New-ITGlueModels -data $data | Out-Null
            }
            $model_id = ((Get-ITGlueModels).data | Where-Object { $_.attributes.name -eq $Switch.model}).id
            $ITGlueLocationId = (Get-ITGlueLocations -org_id $OrgId -filter_name $Switch.site).data.id
            $data = @{
                "organization_id" = $OrgId
                "type" = "configurations"
                attributes = @{
                    "organization_id" = $OrgId
                    "location_id" = $ITGlueLocationId
                    "name" = $Switch.name
                    "mac_address" = $Switch.macaddr
                    "serial_number" = $Switch.serial
                    "primary_ip" = $Switch.ip_address
                    "hostname" = $Switch.name
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
            $ConfigurationData = (Get-ITGlueConfigurations -organization_id $OrgId -page_size 250).data | Where-Object `
            { $_.attributes."configuration-type-name" -eq "Switch" -and $_.attributes."serial-number" -eq $Switch.serial }
            
            # ConfigurationData returns a lot of results. . do I need another foreach? FFS I hope not.

            if ($ConfigurationData) {
                [int]$ConfigurationID = $ConfigurationData.id
                Set-ITGlueConfigurations -organization_id $OrgId -data $data -id $ConfigurationID | Out-Null
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $switch.name
                    "Status" = $true
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            } else { 
                Write-Warning -Message "Asset doesn't exist in IT Glue. ($($switch.name))"
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $switch.name
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
