<#
    Azure Reserves 5 IP addresses within each subnet. More info see here. 
    https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets
#>

Function New-IPCalculator {
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $NetworkAddress
    )   
   
    process {

        #region Transform Network Address
        [IPAddress]$IPAddress = $NetworkAddress.Split('/')[0]
        [IPAddress]$NetworkMask = (([string]'1' * $($NetworkAddress.Split('/')[1]) + [string]'0' * (32 - $($NetworkAddress.Split('/')[1]))) -split "(\d{8})" -match "\d" | ForEach-Object { [convert]::ToInt32($_, 2) }) -split "\D" -join "."
        $Hosts = ([math]::Pow(2, $(32 - $NetworkAddress.Split('/')[1])) - 5)
        $ipBinary = ($IPAddress.tostring().split('.') | ForEach-Object {
                [System.Convert]::ToString($_, 2).PadLeft(8, '0')
            }) -join ''

        $FirstAddressBinary = $($ipBinary.substring(0, $($NetworkAddress.Split('/')[1])).padright(29, '0') + '100')
        $lastAddressBinary = $($ipBinary.substring(0, $($NetworkAddress.Split('/')[1])).padright(31, '1') + '0')
        $FirstAddress = (('{0}.{1}.{2}.{3}' -f $($FirstAddressBinary.substring(0, 8)), $($FirstAddressBinary.substring(8, 8)), $($FirstAddressBinary.substring(16, 8)), $($FirstAddressBinary.substring(24, 8))) -split '\.' | 
            Foreach-Object {
                [System.Convert]::ToByte($_, 2)
            }) -join '.'
    

        $LastAddress = (('{0}.{1}.{2}.{3}' -f $($lastAddressBinary.substring(0, 8)), $($lastAddressBinary.substring(8, 8)), $($lastAddressBinary.substring(16, 8)), $($lastAddressBinary.substring(24, 8))) -split '\.' | 
            Foreach-Object {
                [System.Convert]::ToByte($_, 2)
            }) -join '.'
        #endregion

        #region IP Calculator Object
        [PSCustomObject]@{
            address      = $($IPAddress.ToString())
            bitmask      = $($NetworkAddress.Split('/')[1])
            netmask      = $($NetworkMask.ToString())
            firstaddress = $FirstAddress
            lastaddress  = $LastAddress
            hosts        = $Hosts
        }
        #endregion
        
    }
}