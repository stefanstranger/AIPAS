using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function UpdateAddressSpace processed a request."

try {
    $params = @{
        'StorageAccountName' = $env:AIPASStorageAccountName
        'StorageTableName'   = 'ipam'
        'TenantId'           = $env:AIPASTenantId
        'SubscriptionId'     = $env:AIPASSubscriptionId
        'ResourceGroupName'  = 'AIPAS-rg'
        'PartitionKey'       = 'ipam'
        'ClientId'           = $env:AIPASClientId
        'ClientSecret'       = $env:AIPASClientSecret
    }

    $Body = Update-AddressSpace @params -ErrorAction Stop
    $StatusCode = [HttpStatusCode]::OK

}
catch {
    $Body = $_.Exception.Message
    $StatusCode = [HttpStatusCode]::BadRequest
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $StatusCode
    Body = $body
})
