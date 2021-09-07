<#
    PowerShell script to create a Service Principal for the Poorman's IPAM Azure Function
#>

#region variables
$ResourceGroupName = "AIPAS-rg" #used to scope the permissions for the SPN. This is where the Storage Account is being deployed.
$RoleDefinitionName = "Storage Account Contributor"
$ADApplicationName = "AIPAS"
$PlainPassword = "Bosse1234567890!"
$StorageAccountName = "csok5jwr5norcstorage"
$SubscriptionId = "[enter subscriptionid]" #SubscriptionId where the Vnets will be deployed. E.g. the Landing Zone Subscription. If multiple Subscriptions are used rerun for each Subscription

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
New-AzADApplication -DisplayName $ADApplicationName -HomePage "https://www.testAIPAS.test" -IdentifierUris "https://www.testAIPAS.test" -Password $Password -OutVariable app
$Scope = Get-AzResourceGroup -Name $ResourceGroupName
New-AzADServicePrincipal -ApplicationId $($app.ApplicationId) -Role $RoleDefinitionName -Scope $($Scope.ResourceId)
# Add read permissions on all Subscriptions!!! For retrieving VNet information using the Resource Graph...
New-AzRoleAssignment -RoleDefinitionName Reader -ServicePrincipalName $($app.ApplicationId.Guid) -Scope ('/subscriptions/{0}' -f $SubscriptionId)

Get-AzADApplication -DisplayNameStartWith $ADApplicationName -OutVariable app
Get-AzADServicePrincipal -ServicePrincipalName $($app.ApplicationId.Guid) -OutVariable SPN
#endregion

#region output info. Store below output in secret vault you might need them in the future.
[ordered]@{
    "clientId"       = "$($app.ApplicationId)"
    "clientSecret"   = "$PlainPassword"
    "subscriptionId" = "$($subscription.subscriptionId)"
    "tenantId"       = "$($subscription.TenantID)"
} | Convertto-json
#endregion

#region create local environment variables
[Environment]::SetEnvironmentVariable("AIPASClientId", "$($app.ApplicationId)", "User")
[Environment]::SetEnvironmentVariable("AIPASClientSecret", "$PlainPassword", "User")
[Environment]::SetEnvironmentVariable("AIPASSubscriptionId", "$($subscription.subscriptionId)", "User")
[Environment]::SetEnvironmentVariable("AIPAStenantId", "$($subscription.TenantID)", "User")
[Environment]::SetEnvironmentVariable("AIPASResourceGroupName", $ResourceGroupName, "User")
[Environment]::SetEnvironmentVariable("AIPASStorageAccountName", $StorageAccountName, "User")
# Restart VSCode to have access to the environment variables
#endregion