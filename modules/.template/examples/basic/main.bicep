// ============================================================================
// Example: Basic <Module Name> Deployment
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'dev'

// Deploy the resource
module resource '../../main.bicep' = {
  name: '<resource>-deployment'
  params: {
    name: '<resource>-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    tags: {
      Environment: environment
      Purpose: '<Purpose>'
    }
  }
}

output resourceId string = resource.outputs.resourceId
output resourceName string = resource.outputs.name
