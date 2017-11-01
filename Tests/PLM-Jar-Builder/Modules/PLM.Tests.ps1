Set-StrictMode -Version Latest

Import-Module -Name "${PSScriptRoot}\..\..\..\PLM-Jar-Builder\PLM-Jar-Builder.psd1" -Force
Import-Module -Name "${PSScriptRoot}\..\..\..\PLM-Jar-Builder\Modules\PLM.psm1" -Force

Describe "Get-PlmUri" {
    It "returns a PLM URI" {
        Get-PlmUri -Type "Login" | Should Be "https://www.plm.eecs.uni-kassel.de/uebung/index.php?pageID=001"
    }
}
