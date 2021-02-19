#####################################################################################
# Public Function for AIPAS IPAM PowerShell module
# Description: 
# Retrieves all address space from Storage Table to be used as Address Space for the
# Azure Virtual Network deployment
# The Storage Account Key is being used to connect to the Azure Storage Table
# Call help Function Get-SharedAccessKey using SubscriptionId, ResourceGroupName and StorageAccountName
#####################################################################################

Function Get-AddressSpace {
    [cmdletbinding()]
    [OutputType([string])]
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
        $ClientSecret
    )

    try {

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

        # Return all Address Spaces from Storage Table
        (Invoke-RestMethod @params).value

    }
    catch {

        Throw ('Error Message {0}' -f ($_ | ConvertFrom-Json).error)
        
    }



}