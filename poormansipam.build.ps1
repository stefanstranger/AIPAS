<#
Build script to be used with all build tasks for the Poormans IPAM Solution

.Synopsis
    Build script (https://github.com/nightroman/Invoke-Build)
    

#>


#region use the most strict mode
Set-StrictMode -Version Latest
#endregion


#region Task to Copy PowerShell Module files to Azure Function Modules folder
task CopyModuleFiles {

    # Copy Module Files to Output Folder
    if (-not (Test-Path .\src\function\Modules\IPAM)) {

        $null = New-Item -Path .\src\function\Modules\IPAM -ItemType Directory

    }

    Copy-Item -Path '.\src\module\IPAM\Private\' -Filter *.* -Recurse -Destination .\src\function\Modules\IPAM -Force
    Copy-Item -Path '.\src\module\IPAM\Public\' -Filter *.* -Recurse -Destination .\src\function\Modules\IPAM -Force
    Copy-Item -Path '.\src\module\IPAM\Tests\' -Filter *.* -Recurse -Destination .\src\function\Modules\IPAM -Force

    #Copy Module Manifest files
    Copy-Item -Path @(
        '.\src\module\IPAM\IPAM.psd1'
        '.\src\module\IPAM\IPAM.psm1'
    ) -Destination .\src\function\Modules\IPAM -Force        
}
#endregion

#region Task to run all IPAM PowerShell Module Pester tests
task Test {
    $Tests = @('ModuleValidation.Tests.ps1','Add-AddressSpace.Tests.ps1','Get-AddressSpace.Tests.ps1','Register-AddressSpace.Tests.ps1','Update-AddressSpace.Tests.ps1','Remove-AddressSpace.Tests.ps1')
    $Result = 0
    Foreach ($Test in $Tests) {
        $TestResult = Invoke-Pester .\src\module\IPAM\Tests\$Test -PassThru
        $Result = $Result + $TestResult.FailedCount 
    }
    if ($Result -gt 0) {
        throw 'Pester tests failed'
    }
}
#endregion

#region start azure function
task Startfunction {
    exec { Set-Location .\src\function; Invoke-Expression ('func {0}' -f 'start --functions AddAddressSpace RegisterAddressSpace UpdateAddressSpace') }
}
#endregion

#region Task clean up Output folder
task Clean {
    # Clean output folder
    if ((Test-Path .\src\function\Modules)) {
        Remove-Item -Path .\src\function\Modules -Recurse -Force
    }
}
#endregion

#region Default Task. Runs Clean, Test, CopyModuleFiles Tasks
task . Clean, Test, CopyModuleFiles, Startfunction
#endregion

#region Default Task. Runs Clean, Test, CopyModuleFiles Tasks
task TestFunction Clean, CopyModuleFiles, Startfunction
#endregion