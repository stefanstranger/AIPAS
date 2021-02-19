BeforeAll {
    $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)
    $ModuleName = 'IPAM'
    $ManifestPath = "$ModulePath\$ModuleName.psd1"
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName -Force
    }
    Import-Module $ManifestPath -Verbose:$false
}

Describe 'Passes Remove-AddressSpace Function' {
    It -name 'Passes Remove-AddressSpace Function' -Test {
        InModuleScope IPAM {
            $params = @{
                'StorageAccountName' = $env:AIPASStorageAccountName
                'StorageTableName' = 'ipam'
                'TenantId' = $env:AIPASTenantId
                'SubscriptionId' = $env:AIPASSubscriptionId
                'ResourceGroupName' = $env:AIPASResourceGroupName
                'PartitionKey' = 'ipam'
                'ClientId' = $env:AIPASClientId
                'ClientSecret' = $env:AIPASClientSecret
            }
            
            Get-AddressSpace @params |
                Remove-AddressSpace -StorageAccountName $env:AIPASStorageAccountName -StorageTableName 'ipam' -TenantId $env:AIPASTenantId -SubscriptionId $env:AIPASSubscriptionId -ResourceGroupName 'AIPAS-rg' -PartitionKey 'ipam' -ClientId $env:AIPASClientId -ClientSecret $env:AIPASClientSecret

            Get-AddressSpace @params | Should -BeNullOrEmpty
            
        }
    }
}