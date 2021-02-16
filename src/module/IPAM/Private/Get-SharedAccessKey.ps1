Function Get-SharedAccessKey {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$AccessToken,
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,
        [Parameter(Mandatory = $true)]
        [string]$ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string]$StorageAccountName
    )


    $uri = ('https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Storage/storageAccounts/{2}/listKeys?api-version=2019-06-01&$expand=kerb' -f $Subscriptionid, $ResourceGroupName, $StorageAccountName)
    $Headers = @{
        'Authorization' = ('Bearer {0}' -f $($token.access_token)) 
    }

    $params = @{
        ContentType = 'application/x-www-form-urlencoded'
        Headers     = $Headers
        Method      = 'Post'
        URI         = $uri
    }

    try {
        Write-Verbose -message ('Retrieving Shared Access Keys')
        $Keys = Invoke-RestMethod @params -ErrorAction Stop
        return $($Keys.keys)

    }
    catch {
        Write-Error -Message ('Failed to retrieve Shared Access Key')
    }    
}