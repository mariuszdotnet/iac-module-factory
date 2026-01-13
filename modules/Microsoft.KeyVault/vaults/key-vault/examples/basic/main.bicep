// ============================================================================
// Example: Basic Key Vault Deployment
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'dev'

// Deploy a basic key vault using the AVM wrapper
module keyVault '../../main.bicep' = {
  name: 'kv-basic-deployment'
  params: {
    name: 'kv-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    sku: 'standard'
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    tags: {
      Environment: environment
      Purpose: 'Secrets Management'
    }
  }
}

output keyVaultId string = keyVault.outputs.resourceId
output keyVaultName string = keyVault.outputs.name
output keyVaultUri string = keyVault.outputs.uri
