// ============================================================================
// Example: Basic Container Registry Deployment
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'dev'

// Deploy a basic container registry using the AVM wrapper
module acr '../../main.bicep' = {
  name: 'acr-basic-deployment'
  params: {
    name: 'acr${environment}${uniqueString(resourceGroup().id)}'
    location: location
    acrSku: 'Standard'
    tags: {
      Environment: environment
      Purpose: 'Container Images'
    }
  }
}

output acrId string = acr.outputs.resourceId
output acrName string = acr.outputs.name
output loginServer string = acr.outputs.loginServer
