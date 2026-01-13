// ============================================================================
// Example: Premium Container Registry for Production
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'prod'

// Deploy a premium container registry with production settings
module acr '../../main.bicep' = {
  name: 'acr-premium-deployment'
  params: {
    name: 'acr${environment}${uniqueString(resourceGroup().id)}'
    location: location
    skuName: 'Premium'
    zoneRedundancy: true
    retentionPolicyEnabled: true
    retentionPolicyDays: 30
    contentTrust: true
    tags: {
      Environment: environment
      Purpose: 'Production Container Registry'
      CostCenter: 'Platform'
    }
  }
}

output acrId string = acr.outputs.resourceId
output acrName string = acr.outputs.name
output loginServer string = acr.outputs.loginServer
