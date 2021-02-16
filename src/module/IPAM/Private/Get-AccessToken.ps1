Function Get-AccessToken {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        # ClientId from Service Principal (Service Endpoint)
        [string]$ClientId,
        # ClientSecret from Service Principal (Service Endpoint)
        [Parameter(Mandatory = $true)]
        [string]$ClientSecret,
        [Parameter(Mandatory = $true)]
        [string]$TenantId
    )
    
    $TokenEndpoint = ('https://login.windows.net/{0}/oauth2/token' -f $TenantId )

    $Body = @{
        'resource'      = 'https://management.core.windows.net/'
        'client_id'     = $ClientID
        'grant_type'    = 'client_credentials'
        'client_secret' = $ClientSecret
    }

    $params = @{
        ContentType = 'application/x-www-form-urlencoded'
        Headers     = @{'accept' = 'application/json'}
        Body        = $Body
        Method      = 'Post'
        URI         = $TokenEndpoint
    }

    try {
        Write-Verbose -message ('Retrieving Access Token for ClientID: {0}' -f $clientId)
        $Token = Invoke-RestMethod @params -ErrorAction Stop
        return $($Token)

    }
    catch {
        Write-Error -Message ('Failed to retrieve Access Token')
    }
}