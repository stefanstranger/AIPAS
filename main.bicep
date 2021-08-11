param cgSubId string
param regionId string

@description('The name of the Azure region to deploy resources to.')
@allowed([
  'uksouth'
  'ukwest'
  'northeurope'
  'westeurope'
])
param regionName string
param addressRange string

var rgNetworkName = 'rg-${cgSubId}-${regionId}-network'
var rgIdentityName = 'rg-${cgSubId}-${regionId}-identity'
var rgSharedSvcsName = 'rg-${cgSubId}-${regionId}-sharedsvcs'
var rgManagementName = 'rg-${cgSubId}-${regionId}-management'
var addressPrefix = ${addressRange}

targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgNetworkName
  location: regionName
}
