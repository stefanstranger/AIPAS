
BeforeAll {
    $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)
    $ModuleName = 'IPAM'
    $ManifestPath = "$ModulePath\$ModuleName.psd1"
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName -Force
    }
    Import-Module $ManifestPath -Verbose:$false
}

Describe 'Passes Add-AddressSpace Function' {
    It -name 'Passes Add-AddressSpace Function' {

        $params = @{
            'StorageAccountName' = $env:PoormansStorageAccountName
            'StorageTableName'   = 'ipam'
            'TenantId'           = $env:PoormansTenantId
            'SubscriptionId'     = $env:PoormansSubscriptionId
            'ResourceGroupName'  = 'poormansipam-rg'
            'PartitionKey'       = 'IPAM'
            'ClientId'           = $env:PoormansClientId
            'ClientSecret'       = $env:PoormansClientSecret
            'NetworkAddress'     = "10.0.0.0/16", "10.1.0.0/16"
        }
        $Result = Add-AddressSpace @params 
        $Result.Allocated | Should -Contain 'False'
    }
}