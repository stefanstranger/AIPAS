#####################################################################################
# Public Function for AIPAS IPAM PowerShell module
# Description: 
# Retrieves all deployed Vnets and validates these against the Address Spaces used in the Storage Tabel
# Azure Virtual Network deployment
# The Storage Account Key is being used to connect to the Storage Table
# Call help Function Get-SharedAccessKey using SubscriptionId, ResourceGroupName and StorageAccountName
#####################################################################################

Function Update-AddressSpace {

    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]    
        [String]$StorageAccountName,
        [parameter(Mandatory = $true)]    
        [String]$StorageTableName,
        [parameter(Mandatory = $true)]    
        [String]$TenantId,
        [parameter(Mandatory = $true)]    
        $SubscriptionId,
        [parameter(Mandatory = $true)]    
        [String]$ResourceGroupName,
        [parameter(Mandatory = $true)]
        [String]$PartitionKey,
        [parameter(Mandatory = $true)]    
        [String]$ClientId,
        [parameter(Mandatory = $true)]    
        [String]$ClientSecret
    )

    begin {

        # Call helper functions Get-AccessToken and Get-SharedAccessKey
        $params = @{
            'ClientId'     = $ClientId
            'ClientSecret' = $ClientSecret
            'TenantId'     = $TenantId
        }
        $Token = Get-AccessToken @params

        $params = @{
            'AccessToken'        = $($Token.access_token)
            'SubscriptionId'     = $SubscriptionId
            'ResourceGroupName'  = $ResourceGroupName
            'StorageAccountName' = $StorageAccountName
        }
        $SharedKeys = Get-SharedAccessKey @params     
        $StorageAccountKey = $($SharedKeys[0].value)

        # Get Azure Subscriptions the SPN has access too. SPN requires Read RBAC to all Subscriptions where Vnet can be deployed to.
        $uri = 'https://management.azure.com/subscriptions?api-version=2020-01-01'

        $Headers = @{
            'Authorization' = ('Bearer {0}' -f $($Token.access_token)) 
        }

        $params = @{
            ContentType = 'application/json'
            Headers     = $Headers
            Method      = 'Get'
            URI         = $uri
        }

        $SubscriptionIds = ((Invoke-RestMethod @params).value).SubscriptionId
        Write-Verbose -Message ('The AIPAS IPAM SPN has access to the following Subscription(s): {0}' -f ($SubscriptionIds | out-string))

        $VNets = @()
        Foreach($SubscriptionId in $SubscriptionIds) {

        # Get Vnets using Resource Graph
        $uri = ('https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2020-04-01-preview')
        $Headers = @{
            'Authorization' = ('Bearer {0}' -f $($Token.access_token)) 
        }

        $Query = "Resources | join kind=leftouter(ResourceContainers | where type=='microsoft.resources/subscriptions' | project subscriptionName=name, subscriptionId) on subscriptionId | where type =~ 'Microsoft.Network/virtualNetworks' | extend addressPrefixes=array_length(properties.addressSpace.addressPrefixes) | extend vNetAddressSpace=properties.addressSpace.addressPrefixes | mvexpand  vNetAddressSpace=properties.addressSpace.addressPrefixes | project subscriptionName, resourceGroup, vNetName=name, vNetLocation=location, addressPrefixes, vNetAddressSpace, properties"
        $Body = @{
            "subscriptions" = @(
                $SubscriptionId 
            )
            "query"         = $Query
            "options"       = @{
                "resultFormat" = "ObjectArray"
            }
        } | ConvertTo-Json


        $params = @{
            ContentType = 'application/json'
            Headers     = $Headers
            Method      = 'Post'
            URI         = $uri
            Body        = $Body
        }

        $VNets += (Invoke-RestMethod @params).data
        }
        
        # Get all address spaces stored in Storage Table with Allocated True
        Write-Verbose -Message ('Get all Address Spaces stored in Storage Table')
        $params = @{
            'StorageAccountName' = $StorageAccountName
            'StorageTableName'   = $StorageTableName
            'TenantId'           = $TenantId
            'SubscriptionId'     = $SubscriptionId
            'ResourceGroupName'  = $ResourceGroupName
            'PartitionKey'       = $PartitionKey
            'ClientId'           = $ClientId
            'ClientSecret'       = $ClientSecret
        }
        $AllocatedAddressSpaces = Get-AddressSpace @params | Where-Object { $_.Allocated -eq 'True' }
        Write-Verbose -Message ('Number of AllocatedAddressSpaces: {0}' -f $($AllocatedAddressSpaces.count))
    }
    process {
        # Check for each deployed Azure VNet the status in the Table Storage

        Foreach ($AllocatedAddressSpace in $AllocatedAddressSpaces) {
            Write-Verbose -Message ('Iterating AllAddressSpaces: {0}' -f $AllocatedAddressSpace)

            if ($AllocatedAddressSpaces | Where-Object { $VNets.vNetAddressSpace -contains $_.NetworkAddress }) {

                Write-Verbose -Message ('Updating used address space {0}' -f $($AllocatedAddressSpace.NetworkAddress))
                $RowKey = $AllocatedAddressSpace.RowKey
                $PartitionKey = $AllocatedAddressSpace.PartitionKey
                $Vnet = $Vnets | Where-Object { $_.vNetAddressSpace -eq $AllocatedAddressSpace.NetworkAddress }
                $resource = "$StorageTableName(PartitionKey='$PartitionKey',RowKey='$Rowkey')"
                $uri = ('https://{0}.table.core.windows.net/{1}' -f $StorageAccountName, $resource)
                $Headers = New-Header -Resource $Resource -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    
                $Body = @{
                    'PartitionKey'         = $PartitionKey
                    'RowKey'               = $RowKey
                    'CreatedDateTime'      = $AllocatedAddressSpace.CreatedDateTime
                    'Allocated'            = "True"
                    'VirtualNetworkName'   = $Vnet.vNetName
                    'NetworkAddress'       = $AllocatedAddressSpace.NetworkAddress
                    'FirstAddress'         = $AllocatedAddressSpace.FirstAddress
                    'LastAddress'          = $AllocatedAddressSpace.LastAddress
                    'Hosts'                = $AllocatedAddressSpace.Hosts
                    'Subscription'         = $Vnet.subscriptionName
                    'ResourceGroup'        = $Vnet.ResourceGroup
                    'LastModifiedDateTime' = $(Get-Date -f o)
                } | ConvertTo-Json

                Write-Verbose -Message ('{0}' -f $Body)
    
                $params = @{
                    'Uri'         = $uri
                    'Headers'     = $Headers
                    'Method'      = 'Put'
                    'ContentType' = 'application/json'
                    'Body'        = $Body
                }
    
                try {
                    $null = Invoke-RestMethod @params
                }
                catch {
                    Write-Error -Message ('Failed to update records')
                } 

            }
            else {
                Write-Verbose -Message ('reset record {0}' -f $AllocatedAddressSpace)
                $RowKey = $AllocatedAddressSpace.RowKey
                $PartitionKey = $AllocatedAddressSpace.PartitionKey
                $Vnet = $Vnets | Where-Object { $_.vNetAddressSpace -eq $AllocatedAddressSpace.NetworkAddress }
                $resource = "$StorageTableName(PartitionKey='$PartitionKey',RowKey='$Rowkey')"
                $uri = ('https://{0}.table.core.windows.net/{1}' -f $StorageAccountName, $resource)
                $Headers = New-Header -Resource $Resource -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    
    
                $Body = @{
                    'PartitionKey'         = $PartitionKey
                    'RowKey'               = $RowKey
                    'CreatedDateTime'      = $AllocatedAddressSpace.CreatedDateTime
                    'Allocated'            = "False"
                    'VirtualNetworkName'   = $null
                    'NetworkAddress'       = $AllocatedAddressSpace.NetworkAddress
                    'FirstAddress'         = $AllocatedAddressSpace.FirstAddress
                    'LastAddress'          = $AllocatedAddressSpace.LastAddress
                    'Hosts'                = $AllocatedAddressSpace.Hosts
                    'Subscription'         = $null
                    'ResourceGroup'        = $null
                    'LastModifiedDateTime' = $(Get-Date -f o)
                } | ConvertTo-Json

                Write-Verbose -Message ('{0}' -f $Body)
    
                $params = @{
                    'Uri'         = $uri
                    'Headers'     = $Headers
                    'Method'      = 'Put'
                    'ContentType' = 'application/json'
                    'Body'        = $Body
                }
                try {
                    $null = Invoke-RestMethod @params

                }
                catch {
                    Write-Error -Message ('Failed to update records')
                }                
            }
        }        
    }
}