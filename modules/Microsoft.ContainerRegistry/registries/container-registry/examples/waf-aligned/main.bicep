// ============================================================================
// Example: WAF-Aligned Container Registry (Production)
// ============================================================================
// This example follows Azure Well-Architected Framework best practices

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'prod'

@description('Resource ID of the subnet for private endpoints.')
param privateEndpointSubnetId string

@description('Resource ID of the private DNS zone for ACR.')
param privateDnsZoneId string

@description('Resource ID of the Log Analytics workspace for diagnostics.')
param logAnalyticsWorkspaceId string

// Deploy a WAF-aligned container registry
module acr '../../main.bicep' = {
  name: 'acr-waf-deployment'
  params: {
    name: 'acr${environment}${uniqueString(resourceGroup().id)}'
    location: location
    
    // Premium SKU for enterprise features
    acrSku: 'Premium'
    
    // Security hardening
    acrAdminUserEnabled: false
    trustPolicyStatus: 'enabled'
    exportPolicyStatus: 'disabled'
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    
    // Reliability
    zoneRedundancy: 'Enabled'
    retentionPolicyStatus: 'enabled'
    retentionPolicyDays: 30
    
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
      Purpose: 'Production Container Registry'
      Compliance: 'WAF-Aligned'
    }
  }
}

output acrId string = acr.outputs.resourceId
output acrName string = acr.outputs.name
output loginServer string = acr.outputs.loginServer
output principalId string = acr.outputs.systemAssignedMIPrincipalId
