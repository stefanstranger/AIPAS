Describe 'Static Analysis: Module Validation' {

    Context 'Module Import and Export' {

        BeforeAll {
            $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)
            $ModuleName = 'IPAM'
            $ManifestPath = "$ModulePath\$ModuleName.psd1"
            if (Get-Module -Name $ModuleName) {
                Remove-Module $ModuleName -Force
            }
            Import-Module $ManifestPath -Verbose:$false
        }

        Describe -Name 'Module ipam works' {
            It -name 'Passed Module load' {
                { Import-Module (Join-Path $ModulePath "$ModuleName.psm1") -Force } | Should -Not -Throw
            }

            It -name 'Passed Module removal' {
                $Script = {
                    Remove-Module $ModuleName
                    Import-Module (Join-Path -Path $ModulePath -ChildPath "$ModuleName.psm1")
                }
                $Script | Should -Not -Throw
            }
        }        
    }
}