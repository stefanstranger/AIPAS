using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function RegisterAddressSpace processed a request."

# Interact with query parameters or the body of the request.
$InputObject = $Request.Body.InputObject

try {
    $params = @{
        'StorageAccountName' = $env:PoormansStorageAccountName
        'StorageTableName'   = 'ipam'
        'TenantId'           = $env:PoormansTenantId
        'SubscriptionId'     = $env:PoormansSubscriptionId
        'ResourceGroupName'  = 'poormansipam-rg'
        'PartitionKey'       = 'ipam'
        'ClientId'           = $env:PoormansClientId
        'ClientSecret'       = $env:PoormansClientSecret
        'InputObject'        = $InputObject | ConvertTo-Json -Compress
    }

    $Body = Register-AddressSpace @params -ErrorAction Stop
    $StatusCode = [HttpStatusCode]::OK

}
catch {
    $Body = $_.Exception.Message
    $StatusCode = [HttpStatusCode]::BadRequest
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $StatusCode
        Body       = $body
    })
