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
                'StorageAccountName' = $env:PoormansStorageAccountName
                'StorageTableName' = 'ipam'
                'TenantId' = $env:PoormansTenantId
                'SubscriptionId' = $env:PoormansSubscriptionId
                'ResourceGroupName' = 'poormansipam-rg'
                'PartitionKey' = 'ipam'
                'ClientId' = $env:PoormansClientId
                'ClientSecret' = $env:PoormansClientSecret
            }
            
            Get-AddressSpace @params |
                Remove-AddressSpace -StorageAccountName $env:PoormansStorageAccountName -StorageTableName 'ipam' -TenantId $env:PoormansTenantId -SubscriptionId $env:PoormansSubscriptionId -ResourceGroupName 'poormansipam-rg' -PartitionKey 'ipam' -ClientId $env:PoormansClientId -ClientSecret $env:PoormansClientSecret

            Get-AddressSpace @params | Should -BeNullOrEmpty
            
        }
    }
}