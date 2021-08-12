param cgSubId string
param regionId string
param regionName string

var rgNetworkName = 'rg-${cgSubId}-${regionId}-network'

targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgNetworkName
  location: regionName
}

module vnet './vnet.bicep' = {
  name: 'vnetDeployment'
  scope: rg
  params: {
    addressRange: '10.7.0.0/16'
  }
}
