function New-ACITGlueAP {
    <#
      .SYNOPSIS
      Sync conductor AP from Aruba Central to ITGlue configurations

      .DESCRIPTION
      Sync conductor AP from Aruba Central to ITGlue configurations. Function will also create non-existent models in ITGlue.

      .EXAMPLE
      New-ACITGlueAP -OrgId 1111111
      
      .EXAMPLE
      New-ACITGlueAP -OrgId 1111111 -IncludeAll

      .EXAMPLE
      New-ACITGlueAP
    #>

    Param(
        [Parameter(
            Mandatory = $false,
            HelpMessage = "ITGlue Organization ID."
            )]
        [String]$OrgId,
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include all APs, not just the conductors. CAUTION: This will include ALL APs at every site for the Aruba Central instance."
            )]
        [switch]$IncludeAll = $false
    )
    begin {
        $endpoint = "/monitoring/v2/aps"
        $APs = Invoke-ArubaCLRestMethod -uri $endpoint -limit 1000
        $ManufacturerId = 1657387
        $WifiConfigId = 501532
        $ReturnArray = @()
        $APCount = $APs.Count
        $i = 0
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
        if ($IncludeAll) { Write-Warning -Message "IncludeAll switch used. This could take some time." }
    }
    process {
        foreach ($ap in $APs.aps) {
            Write-Progress -Activity "Processing AP ($($AP.name))" -Status "$($i) of $($APCount)" -PercentComplete (($i / $APCount) * 100)
            # Create models even if the AP is not the conductor.
            $model = (Get-ITGlueModels).data.attributes | Where-Object { $_.name -eq $AP.model}
          
            # If model doesn't exist create it.
            if (!$model) {
                $data = @{
                    type = "models"
                    attributes = @{
                        name = $AP.model
                        "manufacturer-id" = $ManufacturerId
                    }
                } 
                New-ITGlueModels -data $data | Out-Null
            }
            if (!$IncludeAll) {
                if ($AP.swarm_master -eq $false) { 
                    $i++
                    continue 
                }
            }

            $ITGlueLocationId = (Get-ITGlueLocations -org_id $OrgId -filter_name $AP.site).data.id
            $model_id = ((Get-ITGlueModels).data | Where-Object { $_.attributes.name -eq $AP.model}).id
            $data = @{
                "organization_id" = $OrgId
                "type" = "configurations"
                attributes = @{
                    "organization_id" = $OrgId
                    "location_id" = $ITGlueLocationId
                    "name" = $AP.name
                    "mac_address" = $AP.macaddr
                    "serial_number" = $AP.serial
                    "primary_ip" = $AP.ip_address
                    "hostname" = $AP.name
                    "operating_system_notes" = $AP.firmware_version
                    "configuration-type-id" = $WifiConfigId
                    "configuration-type-name" = "Wifi"
                    "configuration-type-kind" = "Wifi"
                    "configuration-status-id" = 37495
                    "configuration-status-name" = "Active"
                    "manufacturer_id" = $ManufacturerId
                    "model_id" = $model_id
                }
            }
            $configuration = (Get-ITGlueConfigurations -organization_id $OrgId).data.attributes | Where-Object { $_."serial-number" -eq $ap.serial }
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
            $i++
        }
    }
    end { return $ReturnArray }
}

function Update-ACITGlueAP {
    <#
      .SYNOPSIS
      Update conductor AP from Aruba Central to ITGlue configurations

      .DESCRIPTION
      Update conductor AP from Aruba Central to ITGlue configurations. Function will also create non-existent models in ITGlue.

      .EXAMPLE
      Update-ACITGlueAP -OrgId 1111111

      .EXAMPLE
      Update-ACITGlueAP
    #>

    Param(
        [Parameter(
            Mandatory = $false,
            HelpMessage = "ITGlue Organization ID."
            )]
        [String]$OrgId
    )
    begin {
        $endpoint = "/monitoring/v2/aps"
        $APs = Invoke-ArubaCLRestMethod -uri $endpoint -limit 1000
        $ManufacturerId = 1657387
        $WifiConfigId = 501532
        $ReturnArray = @()
        $APCount = $APs.Count
        $i = 0
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
    }
    process {
        foreach ($AP in $APs.aps) {
            Write-Progress -Activity "Processing AP ($($AP.name))" -Status "$($i) of $($APCount)" -PercentComplete (($i / $APCount) * 100)
            # Create models even if the AP is not the conductor.
            $model = (Get-ITGlueModels).data.attributes | Where-Object { $_.name -eq $AP.model}

            # If model doesn't exist create it.
            if (!$model) {
                $data = @{
                    type = "models"
                    attributes = @{
                        name = $AP.model
                        "manufacturer-id" = $ManufacturerId
                    }
                } 
                New-ITGlueModels -data $data | Out-Null
            }
            if ($AP.swarm_master -eq $false) { 
                $i++
                continue 
        }

            $ITGlueLocationId = (Get-ITGlueLocations -org_id $OrgId -filter_name $AP.site).data.id
            $model_id = ((Get-ITGlueModels).data | Where-Object { $_.attributes.name -eq $AP.model}).id
            $data = @{
                "organization_id" = $OrgId
                "type" = "configurations"
                attributes = @{
                    "organization_id" = $OrgId
                    "location_id" = $ITGlueLocationId
                    "name" = $AP.name
                    "mac_address" = $AP.macaddr
                    "serial_number" = $AP.serial
                    "primary_ip" = $AP.ip_address
                    "hostname" = $AP.name
                    "operating_system_notes" = $AP.firmware_version
                    "configuration-type-id" = $WifiConfigId
                    "configuration-type-name" = "Wifi"
                    "configuration-type-kind" = "Wifi"
                    "configuration-status-id" = 37495
                    "configuration-status-name" = "Active"
                    "manufacturer_id" = $ManufacturerId
                    "model_id" = $model_id
                }
            }
            $ConfigurationData = (Get-ITGlueConfigurations -organization_id $OrgId -page_size 250).data | Where-Object `
                { $_.attributes."configuration-type-name" -eq "Wifi" -and $_.attributes."serial-number" -eq $AP.serial }

            if ($ConfigurationData) {
                [int]$ConfigurationID = $ConfigurationData.id
                Set-ITGlueConfigurations -organization_id $OrgId -data $data -id $ConfigurationID | Out-Null
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $AP.name
                    "Status" = $true
                }
                $ReturnData = New-Object -TypeName PSObject -Property $Properties
                $ReturnArray += $ReturnData
            } else { 
                $Properties = @{
                    "OrgId" = $OrgId
                    "Name" = $AP.name
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
        $ACEndpoint = "/configuration/v1/ap_cli/CCMS"

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