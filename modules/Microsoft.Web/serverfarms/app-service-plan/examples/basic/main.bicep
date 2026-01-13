// ============================================================================
// Example: Basic App Service Plan Deployment
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'dev'

// Deploy a basic app service plan using the AVM wrapper
module appServicePlan '../../main.bicep' = {
  name: 'asp-basic-deployment'
  params: {
    name: 'asp-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    skuName: 'B1'
    skuCapacity: 1
    tags: {
      Environment: environment
      Purpose: 'Web Hosting'
    }
  }
}

output aspId string = appServicePlan.outputs.resourceId
output aspName string = appServicePlan.outputs.name
