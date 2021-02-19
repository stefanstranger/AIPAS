# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"


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

    Update-AddressSpace @params -ErrorAction Stop
}
catch {
    Write-Output -inputobject ($_.Exception.Message)
}