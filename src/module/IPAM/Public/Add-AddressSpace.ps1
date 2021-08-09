#####################################################################################
# Public Function for AIPAS IPAM PowerShell module
# Description: 
# Adds new address space to Storage Table which can be used as Address Space for the
# Azure Virtual Network deployment
# The Storage Account Key is being used to connect to the Storage Table
# Call help Function Get-SharedAccessKey using SubscriptionId, ResourceGroupName and StorageAccountName
#####################################################################################

Function Add-AddressSpace {

    [cmdletbinding()]
    param (
        [parameter(Mandatory = $true)]    
        [String]$StorageAccountName,
        [parameter(Mandatory = $true)]    
        [String]$StorageTableName,
        [parameter(Mandatory = $true)]    
        [String]$TenantId,
        [parameter(Mandatory = $true)]    
        [String]$SubscriptionId,
        [parameter(Mandatory = $true)]    
        [String]$ResourceGroupName,
        [parameter(Mandatory = $true)]
        [String]$PartitionKey,
        [parameter(Mandatory = $true)]    
        [String]$ClientId,
        [parameter(Mandatory = $true)]    
        [String]$ClientSecret,
        [parameter(Mandatory = $true)]
        [String[]]$NetworkAddress
    )

    begin {
        # Get all address spaces stored in Storage Table
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
        $AddressSpaces = Get-AddressSpace @params
        
        # Call helper functions Get-AccessToken and Get-SharedAccessKey
        Write-Verbose -Message ('Retrieving Access Token')
        $Token = Get-AccessToken -ClientId $ClientID -ClientSecret $ClientSecret -TenantId $TenantId
        Write-Verbose -Message ('Retrieving Storage Account Shared Keys')
        $SharedKeys = Get-SharedAccessKey -AccessToken $($Token.access_token) -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName 
        $StorageAccountKey = $($SharedKeys[0].value)

        $uri = ('https://{0}.table.core.windows.net/{1}' -f $StorageAccountName, $StorageTableName)       
        $Version = '2020-04-08'
        $GMTTime = (Get-Date).ToUniversalTime().toString('R')
        $stringToSign = "$GMTTime`n/$storageAccountName/$StorageTableName"
        $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
        $hmacsha.key = [Convert]::FromBase64String($StorageAccountKey)
        $signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
        $signature = [Convert]::ToBase64String($signature)

        $headers = @{
            'x-ms-date'    = $GMTTime
            Authorization  = ('SharedKeyLite {0}:{1}' -f $StorageAccountName, $signature)
            "x-ms-version" = $Version
            Accept         = 'application/json'
        }

    }
    process {
        foreach ($Address in $NetworkAddress) {
            # Add new record
            $Result = New-IPAMRecord -NetworkAddress $Address | ConvertTo-Json        
  
            if ($Address -notin $AddressSpaces.NetworkAddress) {
                Write-Verbose -Message ('Network Address {0} not in Storage Table {1}' -f $Address, $StorageTableName)

                $params = @{
                    'Uri'         = $uri
                    'Headers'     = $Headers
                    'Method'      = 'Post'
                    'ContentType' = 'application/json'
                    'Body'        = $Result
                }
                Invoke-RestMethod @params
            }
            else {
                Write-Error -Message ('Address Space {0} HAS ALREADY BEEN added' -f $Address)
            }
        }
    }
    end {
        #Clean up
        Remove-Variable -Name Result, AddressSpaces, NetworkAddress
    
    }   
}
