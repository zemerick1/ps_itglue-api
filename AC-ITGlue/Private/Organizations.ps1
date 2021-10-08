function Get-ACITGlueOrgId {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$OrgName,
        [Parameter(Mandatory = $true)]
        [String]$ITGAPIKey
    )
    begin {
        $organization = $OrgName
    }
    process {
        $org_id = (Get-ITGlueOrganizations -filter_name $organization).data.id
    }
    end {
        Set-Variable -Name ACITGlueOrgId -Value $org_id -Scope global
        return $ACITGlueOrgId
    }
}