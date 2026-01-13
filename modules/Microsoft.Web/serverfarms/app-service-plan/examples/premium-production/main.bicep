// ============================================================================
// Example: Premium Production App Service Plan Deployment
// Description: Full-featured production deployment with all enterprise features
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'prod'

@description('Log Analytics Workspace Resource ID for diagnostics.')
param logAnalyticsWorkspaceId string

@description('Principal ID for role assignment.')
param contributorPrincipalId string = ''

// Deploy a premium production app service plan
module appServicePlan '../../main.bicep' = {
  name: 'asp-premium-deployment'
  params: {
    name: 'asp-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    // Premium v3 SKU for best performance and zone redundancy
    skuName: 'P2v3'
    skuCapacity: 3
    kind: 'app'
    // Enable zone redundancy for high availability
    zoneRedundant: true
    // Enable per-site scaling for multi-tenant scenarios
    perSiteScaling: true
    // Diagnostic settings for comprehensive monitoring
    diagnosticSettings: [
      {
        name: 'asp-diagnostics'
        workspaceResourceId: logAnalyticsWorkspaceId
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
      }
    ]
    // Role assignments for contributors
    roleAssignments: !empty(contributorPrincipalId) ? [
      {
        principalId: contributorPrincipalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Website Contributor'
      }
    ] : []
    // Resource lock to prevent accidental deletion
    lock: {
      kind: 'CanNotDelete'
      name: 'asp-production-lock'
    }
    tags: {
      Environment: environment
      CostCenter: 'IT-Production'
      Criticality: 'High'
      'hidden-title': 'Production App Service Plan'
    }
  }
}

output aspId string = appServicePlan.outputs.resourceId
output aspName string = appServicePlan.outputs.name
output aspLocation string = appServicePlan.outputs.location
output aspResourceGroup string = appServicePlan.outputs.resourceGroupName
