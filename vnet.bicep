param addressRange string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'vnetname'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressRange
      ]
    }
    subnets: [
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}
