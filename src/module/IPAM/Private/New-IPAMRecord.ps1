<#
    Azure Reserves 5 IP addresses within each subnet. More info see here. 
    https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets
#>

Function New-IPAMRecord {
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $NetworkAddress
    )

    process {
        $IPAMRecord = New-IPCalculator -NetworkAddress $NetworkAddress
        [PSCustomObject]@{
            'PartitionKey'         = 'ipam'
            'RowKey'               = $(New-Guid).Guid
            'CreatedDateTime'      = $(Get-Date -f o)
            'Allocated'            = 'False'
            'VirtualNetworkName'   = $null
            'NetworkAddress'       = $NetworkAddress
            'FirstAddress'         = $IPAMRecord.firstaddress
            'LastAddress'          = $IPAMRecord.lastaddress
            'Hosts'                = $($IPAMRecord.hosts)
            'Subscription'         = $null
            'ResourceGroup'        = $null
            'LastModifiedDateTime' = $(Get-Date -f o)
        }
    }
}