// ============================================================================
// Example: WAF-Aligned Key Vault (Production)
// ============================================================================
// This example follows Azure Well-Architected Framework best practices

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'prod'

@description('Resource ID of the subnet for private endpoints.')
param privateEndpointSubnetId string

@description('Resource ID of the private DNS zone for Key Vault.')
param privateDnsZoneId string

@description('Resource ID of the Log Analytics workspace for diagnostics.')
param logAnalyticsWorkspaceId string

// Deploy a WAF-aligned key vault
module keyVault '../../main.bicep' = {
  name: 'kv-waf-deployment'
  params: {
    name: 'kv-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    
    // Premium SKU for HSM-backed keys
    sku: 'premium'
    
    // Security hardening
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Disabled'
    
    // Network isolation
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    
    // Identity for secure access
    managedIdentities: {
      systemAssigned: true
    }
    
    // Private connectivity
    privateEndpoints: [
      {
        subnetResourceId: privateEndpointSubnetId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneId
            }
          ]
        }
      }
    ]
    
    // Monitoring & diagnostics
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceId
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
          }
          {
            categoryGroup: 'audit'
          }
        ]
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
      }
    ]
    
    tags: {
      Environment: environment
      Purpose: 'Production Key Vault'
      Compliance: 'WAF-Aligned'
    }
  }
}

output keyVaultId string = keyVault.outputs.resourceId
output keyVaultName string = keyVault.outputs.name
output keyVaultUri string = keyVault.outputs.uri
output principalId string? = keyVault.outputs.systemAssignedMIPrincipalId
