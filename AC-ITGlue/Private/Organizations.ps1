function Get-ACITGlueOrgId {
    Param (
    )
    begin {
        $organization = Read-Host 'Please enter ITGlue Organization Name'
    }
    process {
        $org_id = (Get-ITGlueOrganizations -filter_name $organization).data.id
    }
    end {
        Set-Variable -Name ACITGlueOrgId -Value $org_id -Scope global
        return $ACITGlueOrgId
    }
}