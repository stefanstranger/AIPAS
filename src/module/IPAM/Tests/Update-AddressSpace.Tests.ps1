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
            'StorageAccountName' = $env:AIPASStorageAccountName
            'StorageTableName' = 'ipam'
            'TenantId' = $env:AIPASTenantId
            'SubscriptionId' = $env:AIPASSubscriptionId
            'ResourceGroupName' = $env:AIPASResourceGroupName
            'PartitionKey' = 'IPAM'
            'ClientId' = $env:AIPASClientId
            'ClientSecret' = $env:AIPASClientSecret
        }
        {Update-AddressSpace @params} | Should -Not -Throw
    }
}