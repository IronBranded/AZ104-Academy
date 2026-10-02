// Lab 03-01 starting point. A storage account; Part 3 adds a blob container.
@description('Short prefix for the storage account name: lowercase letters and numbers.')
@minLength(3)
@maxLength(11)
param namePrefix string = 'az104lab'

@description('Region for every resource. Defaults to the resource group location.')
param location string = resourceGroup().location

@description('Storage redundancy.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param skuName string = 'Standard_LRS'

var storageName = '${namePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
  tags: {
    'az104-module': '03-01'
  }
}

output storageAccountName string = stg.name
output blobEndpoint string = stg.properties.primaryEndpoints.blob
