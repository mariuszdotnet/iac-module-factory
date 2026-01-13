// ============================================================================
// Example: Premium Key Vault for Production
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'prod'

// Deploy a premium key vault with production settings
module keyVault '../../main.bicep' = {
  name: 'kv-premium-deployment'
  params: {
    name: 'kv-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    sku: 'premium'
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Disabled'
    managedIdentities: {
      systemAssigned: true
    }
    tags: {
      Environment: environment
      Purpose: 'Production Key Vault'
      CostCenter: 'Platform'
    }
  }
}

output keyVaultId string = keyVault.outputs.resourceId
output keyVaultName string = keyVault.outputs.name
output keyVaultUri string = keyVault.outputs.uri
