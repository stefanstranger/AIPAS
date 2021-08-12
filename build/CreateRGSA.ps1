<#
    Run from within your cloned repo folder
#>

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

#region Create a new Resource Group
New-AzResourceGroup -Name 'rg-ipam-04' -Location 'uksouth'
#endregion

#region Deploy Azure Storage Table in Resource Group
$params = @{
    'ResourceGroupName' = 'rg-ipam-04'
    'Mode' = 'Incremental'
    'Name' = 'AIPAS_IPAM_Deployment'
    'TemplateFile' = '.\src\templates\azuredeploy.json'
    'TemplateParameterFile' = '.\src\templates\azuredeploy.parameters.json'
}

New-AzResourceGroupDeployment @params
#endregion
