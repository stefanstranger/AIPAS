param cgSubId string
param regionId string
param regionName string
param addressRange string

var rgNetworkName = 'rg-${cgSubId}-${regionId}-network'

targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgNetworkName
  location: regionName
}

module vnet './vnet.bicep' = {
  name: 'vnetDeployment'
  scope: rg
  params: {
    addressRange: addressRange
  }
}
