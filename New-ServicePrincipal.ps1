<#
    PowerShell script to create a Service Principal for the Poorman's IPAM Azure Function
#>

#region variables
$ResourceGroupName = "AIPAS-rg" #used to scope the permissions for the SPN
$RoleDefinitionName = "Storage Account Contributor"
$ADApplicationName = "AIPASdemo"
$PlainPassword = '[enter password]'
$StorageAccountName = "[Enter Storage Account Name]"
#endregion

#region Login to Azure
Add-AzAccount
#endregion
 
#region Select Azure Subscription
$subscription = 
(Get-AzSubscription |
    Out-GridView `
        -Title 'Select an Azure Subscription ...' `
        -PassThru)
 
Set-AzContext -SubscriptionId $subscription.subscriptionId -TenantId $subscription.TenantID
#endregion

#region create SPN with Password
$Password = ConvertTo-SecureString $PlainPassword  -AsPlainText -Force
New-AzADApplication -DisplayName $ADApplicationName -HomePage "https://www.AIPAS.io" -IdentifierUris "https://www.AIPAS.demo" -Password $Password -OutVariable app
$Scope = Get-AzResourceGroup -Name $ResourceGroupName
New-AzADServicePrincipal -ApplicationId $($app.ApplicationId) -Role $RoleDefinitionName -Scope $($Scope.ResourceId)
# Add read permissions on all Subscriptions!!! For retrieving VNet information using the Resource Graph...
New-AzRoleAssignment -RoleDefinitionName Reader -ServicePrincipalName $app.ApplicationId.Guid -Scope '/subscriptions/7c7797a7-ad81-4487-a9d6-5ffff4861a14'

Get-AzADApplication -DisplayNameStartWith $ADApplicationName -OutVariable app
Get-AzADServicePrincipal -ObjectId $($app.ApplicationId.Guid) -OutVariable SPN
#endregion

#region output info
[ordered]@{
    "clientId"       = "$($app.ApplicationId)"
    "clientSecret"   = "$PlainPassword"
    "subscriptionId" = "$($subscription.subscriptionId)"
    "tenantId"       = "$($subscription.TenantID)"
} | Convertto-json
#endregion

#region create local environment variabled
[Environment]::SetEnvironmentVariable("AIPASClientId", "$($app.ApplicationId)", "User")
[Environment]::SetEnvironmentVariable("AIPASClientSecret", "$PlainPassword", "User")
[Environment]::SetEnvironmentVariable("AIPASSubscriptionId", "$($subscription.subscriptionId)", "User")
[Environment]::SetEnvironmentVariable("AIPAStenantId", "$($subscription.TenantID)", "User")
[Environment]::SetEnvironmentVariable("AIPASStorageAccountName", $StorageAccountName, "User")

# Restart VSCode to have access to the environment variables
#endregion

# For deploying the App Settings during pipeline deployment create a JSON Object and store as Secret in Github
# https://github.com/Azure/appservice-settings

#region output info. Use in APP Settings Github Secret
@(
    [ordered]@{
        "name" = "AIPASClientId"
        "value" = "$($app.ApplicationId)"
    },
    [ordered]@{
        "name" = "AIPASClientSecret"
        "value" = "$PlainPassword"
    },
    [ordered]@{
        "name" = "AIPASTenantId"
        "value" = "$($subscription.TenantID)"
    },
    [ordered]@{
        "name" = "AIPASSubscriptionId"
        "value" = "$($subscription.subscriptionId)"
    },
    [ordered]@{
        "name" = "AIPASStorageAccountName"
        "value" = $StorageAccountName
    },
    [ordered]@{
        "name" = "AIPASResourceGroupName"
        "value" = $ResourceGroupName
    }
) | Convertto-json | clip
#endregion