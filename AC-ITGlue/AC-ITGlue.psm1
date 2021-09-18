# Install / Import
Install-Module -Name ITGlueAPI -SkipPublisherCheck
Import-Module -Name ITGlueAPI

Install-Module -Name PowerArubaCL -SkipPublisherCheck -Force
Import-Module -Name PowerArubaCL
# end

# https://github.com/PowerAruba/PowerArubaCL/blob/master/PowerArubaCL/PowerArubaCL.psd1
# Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Resources\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
Foreach ($import in @($Private + $Public)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}