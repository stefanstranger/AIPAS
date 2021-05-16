using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function AddAddressSpace processed a request."

# Get TriggerMetadata
Write-Verbose ($TriggerMetadata | Convertto-Json) -Verbose

Write-Verbose ('Request Object: {0}' -f ($request | convertto-json)) -Verbose

# Interact with the body of the request.
if ($Request.Body) {  
    try {
        $params = @{
            'StorageAccountName' = $env:AIPASStorageAccountName
            'StorageTableName'   = 'ipam'
            'TenantId'           = $env:AIPASTenantId
            'SubscriptionId'     = $env:AIPASSubscriptionId
            'ResourceGroupName'  = $env:AIPASResourceGroupName
            'PartitionKey'       = 'IPAM'
            'ClientId'           = $env:AIPASClientId
            'ClientSecret'       = $env:AIPASClientSecret
            'NetworkAddress'     = $Request.Body | ConvertTo-Json
        }

        $Body = Add-AddressSpace @params -ErrorAction Stop
        $StatusCode = [HttpStatusCode]::OK

    }
    catch {
        $StatusCode = [HttpStatusCode]::BadRequest
        $Body = $_.Exception.Message
    }    
}
else {
    #Create error because there is no body input
    $StatusCode = [HttpStatusCode]::BadRequest
    $Body = 'Missing Body of Request'
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $StatusCode
        Body       = $Body
    })
