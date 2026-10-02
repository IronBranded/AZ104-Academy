// Solution for Lab 03-01 Part 3: storage.bicep plus ZRS and a blob container.
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
  'Standard_ZRS'
])
param skuName string = 'Standard_LRS'

@description('Name of the blob container to create.')
param containerName string = 'reports'

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

// No dependsOn: 'parent' references stg and blobSvc by symbolic name,
// so Bicep generates the dependencies itself.
resource blobSvc 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: stg
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobSvc
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}

output storageAccountName string = stg.name
output blobEndpoint string = stg.properties.primaryEndpoints.blob
output containerId string = container.id
