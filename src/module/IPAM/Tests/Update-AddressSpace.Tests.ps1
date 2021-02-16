BeforeAll {
    $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)
    $ModuleName = 'IPAM'
    $ManifestPath = "$ModulePath\$ModuleName.psd1"
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName -Force
    }
    Import-Module $ManifestPath -Verbose:$false
}

Describe 'Passes Update-AddressSpace Function' {
    It -name 'Passes Update-AddressSpace Function' {
        $params = @{
            'StorageAccountName' = $env:PoormansStorageAccountName
            'StorageTableName' = 'ipam'
            'TenantId' = $env:PoormansTenantId
            'SubscriptionId' = $env:PoormansSubscriptionId
            'ResourceGroupName' = 'poormansipam-rg'
            'PartitionKey' = 'IPAM'
            'ClientId' = $env:PoormansClientId
            'ClientSecret' = $env:PoormansClientSecret
        }
        $Result = Update-AddressSpace @params 
        $Result.Status | Should -Be 'OK'
    }
}