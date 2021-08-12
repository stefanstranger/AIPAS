param cgSubId string
param regionName string
param addressRange string

var rgNetworkName = 'rg-${cgSubId}-${regionName}-network'
var vnetName = 'vnet-${cgSubId}-${regionName}-01'

targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgNetworkName
  location: regionName
}

module vnet './modules/network.bicep' = {
  name: 'vnetDeployment'
  scope: rg
  params: {
    vnetName: vnetName
    addressRange: addressRange
  }
}
