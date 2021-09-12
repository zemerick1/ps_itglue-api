function New-ACITGlueSync {
    <#
      .SYNOPSIS
      Syncs all data from Aruba Central to ITGlue

      .DESCRIPTION
      Syncs all data from Aruba Central to ITGlue

      .EXAMPLE
      New-ACITGlueSync -OrgId 111111

      .EXAMPLE
      New-ACITGlueSync 
    #>

    Param(
        [Parameter(Mandatory = $false)]
        [String]$OrgId
    )
    begin { 
        if (!$OrgId) { $OrgId = $ACITGlueOrgId }
    }
    process {
        New-ACITGlueSites
        New-ACITGlueNetwork
        New-ACITGlueSwitch
        New-ACITGlueAP
        Set-ACITGlueNetwork
    }
    end {}
}
#New-ACITGlueSync -OrgId 5550979
