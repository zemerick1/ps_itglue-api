# API Connections
function New-ACITglueConnection {
    begin{
        $ITGlueStatus = $false
        $ACITGlueStatus = $false
    }
    process {
        $ErrorActionPreference = 'SilentlyContinue'
        if (!(Get-ITGlueAPIKey) -as [bool]) {
            $APIKey = Read-Host -Prompt 'Please enter ITGlue API Key'
            $ITGlueStatus = (Add-ITGlueAPIKey -Api_Key $APIKey) -as [bool]
        } else { $ITGlueStatus = $true }
        $ErrorActionPreference = 'Continue'

        if (!(Get-ArubaCLTokenStatus)) {
            Connect-ArubaCL
        }

        if (!$ACITGlueOrgId) {
            $OrgId = Get-ACITGlueOrgId
        } else { $ACITGlueStatus = $true }

        if ($OrgId -or $null -ne $OrgId) {
            $ACITGlueStatus = $true
        }
        $Properties = @{
            "ITGlueStatus" = $ITGlueStatus
            "ACStatus" = (Get-ArubaCLTokenStatus)
            "ACITGlueStatus" = $ACITGlueStatus
        }
        $ReturnData = New-Object -TypeName PSObject -Property $Properties
    }
    end { 
        Set-Variable -Name ACITGlueStatus -Value $ReturnData -Scope global
        return $ReturnData 
    }
}