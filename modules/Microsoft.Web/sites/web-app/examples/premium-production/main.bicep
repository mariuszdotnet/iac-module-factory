// ============================================================================
// Example: Premium Production Web App Deployment
// Description: Full-featured production deployment with all enterprise features
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'prod'

@description('The resource ID of the App Service Plan.')
param serverFarmResourceId string

@description('Log Analytics Workspace Resource ID for diagnostics.')
param logAnalyticsWorkspaceId string

@description('Virtual Network Subnet ID for integration.')
param virtualNetworkSubnetId string

@description('Private Endpoint Subnet Resource ID.')
param privateEndpointSubnetId string

@description('Private DNS Zone Resource ID for the private endpoint.')
param privateDnsZoneResourceId string

@description('Application Insights Resource ID.')
param appInsightResourceId string

@description('Principal ID for role assignment.')
param contributorPrincipalId string = ''

// Deploy a premium production web app
module webApp '../../main.bicep' = {
  name: 'webapp-premium-deployment'
  params: {
    name: 'app-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    kind: 'app,linux'
    serverFarmResourceId: serverFarmResourceId
    // Security: HTTPS only, disable public access
    httpsOnly: true
    publicNetworkAccess: 'Disabled'
    // VNet Integration for network isolation
    virtualNetworkSubnetId: virtualNetworkSubnetId
    vnetRouteAllEnabled: true
    vnetContentShareEnabled: true
    // Managed Identity for secure authentication
    managedIdentities: {
      systemAssigned: true
    }
    // Application Insights integration
    appInsightResourceId: appInsightResourceId
    // Secure site configuration
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      healthCheckPath: '/health'
      requestTracingEnabled: true
      detailedErrorLoggingEnabled: true
      httpLoggingEnabled: true
    }
    // Deployment slots for zero-downtime deployments
    slots: [
      {
        name: 'staging'
        siteConfig: {
          linuxFxVersion: 'DOTNETCORE|8.0'
          alwaysOn: true
          ftpsState: 'Disabled'
          minTlsVersion: '1.2'
        }
      }
    ]
    // Private endpoint configuration
    privateEndpoints: [
      {
        subnetResourceId: privateEndpointSubnetId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneResourceId
            }
          ]
        }
        tags: {
          Environment: environment
        }
      }
    ]
    // Diagnostic settings for comprehensive monitoring
    diagnosticSettings: [
      {
        name: 'webapp-diagnostics'
        workspaceResourceId: logAnalyticsWorkspaceId
        logs: [
          {
            categoryGroup: 'allLogs'
            enabled: true
          }
        ]
        metrics: [
          {
            category: 'AllMetrics'
            enabled: true
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
      name: 'webapp-production-lock'
    }
    tags: {
      Environment: environment
      CostCenter: 'IT-Production'
      Criticality: 'High'
      'hidden-title': 'Production Web App'
    }
  }
}

output webAppId string = webApp.outputs.resourceId
output webAppName string = webApp.outputs.name
output webAppHostname string = webApp.outputs.defaultHostname
output webAppLocation string = webApp.outputs.location
output webAppResourceGroup string = webApp.outputs.resourceGroupName
output systemAssignedPrincipalId string = webApp.outputs.systemAssignedMIPrincipalId
output deploymentSlots array = webApp.outputs.slots
