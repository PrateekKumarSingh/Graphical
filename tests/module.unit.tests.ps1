<#
.Synopsis
    Pester test to verify the content of the manifest and the documentation of each functions.
.Description
    Pester test to verify the content of the manifest and the documentation of each functions.
#>
[CmdletBinding()]
PARAM(
    [System.String]$modulePath=(split-path -parent -Path $PSScriptRoot),
    [System.String]$moduleName='Graphical',
    [System.String]$srcPath=(Join-Path -Path (split-path -parent -Path $PSScriptRoot) -ChildPath 'src')
)
begin{
    # Find the Manifest file
    $ManifestFile = "$modulePath\$ModuleName.psd1"

    # Unload any module with same name
    Get-Module -Name $ModuleName -All | Remove-Module -Force -ErrorAction Ignore

    # Import Module
    $ModuleInformation = Import-Module -Name $ManifestFile -Force -ErrorAction Stop -PassThru

    # Get the functions present in the Manifest
    $ExportedFunctions = $ModuleInformation.ExportedFunctions.Values.name

    # Public functions
    $publicFiles = @(Get-ChildItem -Path $srcPath\public\*.ps1 -ErrorAction SilentlyContinue)
}
end{
    Remove-Module -Name $moduleName -ErrorAction SilentlyContinue}
process{
Describe "$ModuleName Module - Testing Manifest File (.psd1)"{

    Context 'Module Version'{'Loaded Version vs Get-Command return for the module'}
    Context 'Manifest'{
        It 'Should contains RootModule'{$ModuleInformation.RootModule|Should not BeNullOrEmpty}
        It 'Should contains Author'{$ModuleInformation.Author|Should not BeNullOrEmpty}
        It 'Should contains Company Name'{$ModuleInformation.CompanyName|Should not BeNullOrEmpty}
        It 'Should contains Description'{$ModuleInformation.Description|Should not BeNullOrEmpty}
        It 'Should contains Copyright'{$ModuleInformation.Copyright|Should not BeNullOrEmpty}
        It 'Should contains License'{$ModuleInformation.LicenseURI|Should not BeNullOrEmpty}
        It 'Should contains a Project Link'{$ModuleInformation.ProjectURI|Should not BeNullOrEmpty}
        It 'Should contains a Tags (For the PSGallery)'{$ModuleInformation.Tags.count|Should not BeNullOrEmpty}

        It "Should have equal number of Function Exported and the Public PS1 files found ($($ExportedFunctions.count) and $($publicFiles.count))"{
            $ExportedFunctions.count -eq $publicFiles.count |Should -Be $true}
        It "Compare the missing function"{
            if (-not($ExportedFunctions.count -eq $publicFiles.count)){
                $Compare = Compare-Object -ReferenceObject $ExportedFunctions -DifferenceObject $publicFiles.basename
                $Compare.inputobject -join ',' |
                Should BeNullOrEmpty
            }
        }
    }
}


# Testing the Module
Describe "$ModuleName Module - HELP" -Tags "Module" {
    #$Commands = (get-command -Module ADSIPS).Name

    FOREACH ($c in $ExportedFunctions)
    {
        $Help = Get-Help -Name $c -Full
        $Notes = ($Help.alertSet.alert.text -split '\n')
        $FunctionContent = Get-Content function:$c
        $AST = [System.Management.Automation.Language.Parser]::ParseInput($FunctionContent, [ref]$null, [ref]$null)

        Context "$c - Help"{

            It "Synopsis"{$help.Synopsis| Should not BeNullOrEmpty}
            It "Description"{$help.Description| Should not BeNullOrEmpty}
            It "Notes - Github Project" {$Notes -match "$GithubRepository$ModuleName" | Should Be $true}

            # Get the parameters declared in the Comment Based Help
            #  minus the RiskMitigationParameters
            $RiskMitigationParameters = 'Whatif', 'Confirm'
            $HelpParameters = $help.parameters.parameter | Where-Object name -NotIn $RiskMitigationParameters

            # Parameter Count VS AST Parameter
            $ASTParameters = $ast.ParamBlock.Parameters.Name.variablepath.userpath
            It "Parameter - Compare Count Help/AST" {
                $HelpParameters.name.count -eq $ASTParameters.count | Should Be $true}

            # Parameters Description
            $HelpParameters| Foreach-Object -Process {
                It "Parameter $($_.Name) - Should contains description"{
                    $_.description | Should not BeNullOrEmpty
                }
            }

            # Parameters separated by a space
            $ParamText=$ast.ParamBlock.extent.text -split '\r\n' # split on return
            $ParamText=$ParamText.trim()
            $ParamTextSeparator=$ParamText |select-string ',$' #line that finish by a ','

            if($ParamTextSeparator)
            {
                Foreach ($ParamLine in $ParamTextSeparator.linenumber)
                {
                    it "Parameter - Separated by space (Line $ParamLine)"{
                        #$ParamText[$ParamLine] -match '\s+' | Should Be $true
                        $ParamText[$ParamLine] -match '^$|\s+' | Should Be $true
                    }
                }
            }

            # Examples
            it "Example - Count should be greater than 0"{
                $Help.examples.example.code.count | Should BeGreaterthan 0
                $Help.examples | Should not BeNullOrEmpty
            }
        }
    }
}
}