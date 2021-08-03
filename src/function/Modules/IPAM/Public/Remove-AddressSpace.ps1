Function Remove-AddressSpace {
    [CmdletBinding()]
    Param(
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
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $RowKey
    )

    begin {
        # Call helper functions Get-AccessToken and Get-SharedAccessKey
        Write-Verbose -Message ('Retrieving Access Token')
        $Token = Get-AccessToken -ClientId $ClientID -ClientSecret $ClientSecret -TenantId $TenantId
        Write-Verbose -Message ('Retrieving Storage Account Shared Keys')
        $SharedKeys = Get-SharedAccessKey -AccessToken $($Token.access_token) -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName 
        $StorageAccountKey = $($SharedKeys[0].value)
    }
    process {
        try {
            Write-Verbose -Message ('Removing RowKey {0}' -f $RowKey)
            $resource = "$StorageTableName(PartitionKey='$PartitionKey',RowKey='$RowKey')"
            $Headers = New-Header -Resource $Resource -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
            $Headers.Add("If-Match", "*")
            $uri = ('https://{0}.table.core.windows.net/{1}' -f $StorageAccountName, $resource)
            $params = @{
                'Uri'         = $uri
                'Headers'     = $Headers
                'Method'      = 'Delete'
                'ContentType' = 'application/json'
            }
            Invoke-RestMethod @params     
        }
        catch {
                
        }
    }
}