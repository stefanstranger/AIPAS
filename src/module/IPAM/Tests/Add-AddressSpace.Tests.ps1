
BeforeAll {
    $ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $PSCommandPath)
    $ModuleName = 'IPAM'
    $ManifestPath = "$ModulePath\$ModuleName.psd1"
    if (Get-Module -Name $ModuleName) {
        Remove-Module $ModuleName -Force
    }
    Import-Module $ManifestPath -Verbose:$false

    $NetworkAddresses = Get-Content -Path "$PSScriptRoot\Example-AddAddressSpace-Input-Body.json"
}

Describe 'Passes Add-AddressSpace Function' {
    It -name 'Passes Add-AddressSpace Function' {

        $params = @{
            'StorageAccountName' = $env:AIPASStorageAccountName
            'StorageTableName'   = 'ipam'
            'TenantId'           = $env:AIPASTenantId
            'SubscriptionId'     = $env:AIPASSubscriptionId
            'ResourceGroupName'  = $env:AIPASResourceGroupName
            'PartitionKey'       = 'IPAM'
            'ClientId'           = $env:AIPASClientId
            'ClientSecret'       = $env:AIPASClientSecret
            'NetworkAddress'     = $NetworkAddresses #"10.0.0.0/16", "10.1.0.0/16"
        }
        $Result = Add-AddressSpace @params 
        $Result.Allocated | Should -Contain 'False'
    }
}