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
        New-ACITGlueSite -OrgId $OrgId
        New-ACITGlueNetwork -OrgId $OrgId
        New-ACITGlueSwitch -OrgId $OrgId
        New-ACITGlueAP -OrgId $OrgId
        Update-ACITGlueNetwork -OrgId $OrgId
        New-ACITGlueSubscription -OrgId $OrgId
    }
    end {}
}
