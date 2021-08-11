//param cgSubName string
//param regionId string
param regionName string

targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'rg-contoso'
  location: regionName
}
