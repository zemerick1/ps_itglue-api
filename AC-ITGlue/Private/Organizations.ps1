function Get-ACITGlueOrgId {
    Param(
        [Parameter(Mandatory = $true)]
        [String]$OrgName,
        [Parameter(Mandatory = $false)]
        [String]$ITGAPIKey
    )
    begin {
        $organization = $OrgName
        if (!$ITGAPIKey) { Write-Warning "No ITGlue API Key declared. The API call will be best effort." }
    }
    process {
        $org_id = (Get-ITGlueOrganizations -filter_name $organization).data.id
    }
    end {
        Set-Variable -Name ACITGlueOrgId -Value $org_id -Scope global
        return $ACITGlueOrgId
    }
}