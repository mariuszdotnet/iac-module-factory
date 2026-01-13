// ============================================================================
// Example: WAF-Aligned App Service Plan Deployment
// Description: Deploys an App Service Plan following Azure Well-Architected Framework
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'prod'

@description('Log Analytics Workspace Resource ID for diagnostics.')
param logAnalyticsWorkspaceId string

// Deploy a WAF-aligned app service plan
module appServicePlan '../../main.bicep' = {
  name: 'asp-waf-deployment'
  params: {
    name: 'asp-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    // Premium SKU for zone redundancy support
    skuName: 'P1v3'
    skuCapacity: 3
    // Enable zone redundancy for high availability
    zoneRedundant: true
    // Enable per-site scaling for flexibility
    perSiteScaling: true
    // Diagnostic settings for monitoring
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceId
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
      }
    ]
    // Resource lock to prevent accidental deletion
    lock: {
      kind: 'CanNotDelete'
      name: 'asp-delete-lock'
    }
    tags: {
      Environment: environment
      Compliance: 'WAF-Aligned'
      'hidden-title': 'App Service Plan (WAF-Aligned)'
    }
  }
}

output aspId string = appServicePlan.outputs.resourceId
output aspName string = appServicePlan.outputs.name
output aspLocation string = appServicePlan.outputs.location
