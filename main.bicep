param cgSubId string
param regionId string
param regionName string

var rgName = 'rg-${cgSubId}-${regionId}-network'

targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgName
  location: regionName
}
