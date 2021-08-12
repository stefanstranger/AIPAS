param addressRange string

resource vnet 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: 'vnetname'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressRange
      ]
    }
  }
}
