#####################################################################################
# Public Function for AIPAS IPAM PowerShell module
# Description: 
# Retrieves free address space from Storage Table to be used as Address Space for the
# Azure Virtual Network deployment
# The Storage Account Key is being used to connect to the Storage Table
# Call help Function Get-SharedAccessKey using SubscriptionId, ResourceGroupName and StorageAccountName#
#####################################################################################

Function Register-AddressSpace {
    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]    
        $StorageAccountName,
        [parameter(Mandatory = $false)]    
        $StorageTableName,
        [parameter(Mandatory = $true)]    
        $TenantId,
        [parameter(Mandatory = $true)]    
        $SubscriptionId,
        [parameter(Mandatory = $true)]    
        $ResourceGroupName,
        [parameter(Mandatory = $true)]
        $PartitionKey,
        [parameter(Mandatory = $true)]    
        $ClientId,
        [parameter(Mandatory = $true)]    
        $ClientSecret,
        [parameter(Mandatory = $false)]    
        $InputObject
    )

    # Call helper functions Get-AccessToken and Get-SharedAccessKey
    Write-Verbose -Message ('Retrieving Access Token')
    $Token = Get-AccessToken -ClientId $ClientID -ClientSecret $ClientSecret -TenantId $TenantId
    Write-Verbose -Message ('Retrieving Storage Account Shared Keys')
    $SharedKeys = Get-SharedAccessKey -AccessToken $($Token.access_token) -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName 
    $StorageAccountKey = $($SharedKeys[0].value)

    $uri = ('https://{0}.table.core.windows.net/{1}' -f $StorageAccountName, $StorageTableName)

    $Headers = New-Header -Resource $StorageTableName -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

    $params = @{
        'Uri'         = $uri
        'Headers'     = $Headers
        'Method'      = 'Get'
        'ContentType' = 'application/json' 
    }

    # Return oldest free address space
    $params = @{
        'StorageAccountName' = $StorageAccountName
        'StorageTableName'   = 'ipam'
        'TenantId'           = $TenantId
        'SubscriptionId'     = $SubscriptionId
        'ResourceGroupName'  = $ResourceGroupName
        'PartitionKey'       = 'IPAM'
        'ClientId'           = $ClientId
        'ClientSecret'       = $ClientSecret
    }    
    
    try {
        # Check if Address Space was not already registered
        $InputObject = $InputObject | ConvertFrom-Json
        if (!(Get-AddressSpace @params | Where-Object { $_.ResourceGroup -eq $($inputObject.ResourceGroup) -and $_.VirtualNetworkName -eq $($inputObject.VirtualNetworkName) })) {
            # Get free address space
            $FreeAddressSpace = Get-AddressSpace @params | 
            Where-Object { $_.Allocated -eq 'False' } |                 
            Sort-Object -Property 'CreatedDateTime' | Select-Object -First 1

            if ($FreeAddressSpace.count -eq 1) {
                # Set Allocated property of assigned Address Space
                Write-Verbose -Message ('Setting Allocated property for assigned address space {0}' -f $($FreeAddressSpace.NetworkAddress))
                $resource = "$StorageTableName(PartitionKey='$($FreeAddressSpace.PartitionKey)',RowKey='$($FreeAddressSpace.RowKey)')"
                $uri = ('https://{0}.table.core.windows.net/{1}' -f $StorageAccountName, $resource)
                $Headers = New-Header -Resource $Resource -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    
                $Body = @{
                    'PartitionKey'         = $FreeAddressSpace.RowKey
                    'RowKey'               = $FreeAddressSpace.RowKey
                    'CreatedDateTime'      = $FreeAddressSpace.CreatedDateTime
                    'Allocated'            = "True"
                    'VirtualNetworkName'   = $null
                    'NetworkAddress'       = $FreeAddressSpace.NetworkAddress
                    'FirstAddress'         = $FreeAddressSpace.FirstAddress
                    'LastAddress'          = $FreeAddressSpace.LastAddress
                    'Hosts'                = $FreeAddressSpace.Hosts
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

                $null = Invoke-RestMethod @params
                # retrieve Updated Registered Address Space.
                $params = @{
                    'StorageAccountName' = $StorageAccountName
                    'StorageTableName'   = 'ipam'
                    'TenantId'           = $TenantId
                    'SubscriptionId'     = $SubscriptionId
                    'ResourceGroupName'  = $ResourceGroupName
                    'PartitionKey'       = 'IPAM'
                    'ClientId'           = $ClientId
                    'ClientSecret'       = $ClientSecret
                }

                Get-AddressSpace @params | Where-Object {$_.RowKey -eq $FreeAddressSpace.RowKey} | Select-Object -ExcludeProperty "odata*"
            }
            else {
                Throw
            }
        }
        # Return already registered Address Space
        Get-AddressSpace @params | Where-Object { $_.ResourceGroup -eq $($inputObject.ResourceGroup) -and $_.VirtualNetworkName -eq $($inputObject.VirtualNetworkName) } |
            Select-Object -ExcludeProperty "odata*"
    }
    catch {
        Throw ('Failed to register free address space')
    }
}