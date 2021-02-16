Function New-Header {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Resource,
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName,
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountKey 
    )
   
    $Version = '2020-04-08'
    $GMTTime = (Get-Date).ToUniversalTime().toString('R')
    $stringToSign = "$GMTTime`n/$storageAccountName/$resource"
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.key = [Convert]::FromBase64String($StorageAccountKey)
    $signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
    $signature = [Convert]::ToBase64String($signature)
    
    return @{
        'x-ms-date'     = $GMTTime
        'Authorization' = ('SharedKeyLite {0}:{1}' -f $StorageAccountName, $signature)
        'x-ms-version'  = $Version
        'Accept'        = 'application/json;odata=fullmetadata'
    }
}