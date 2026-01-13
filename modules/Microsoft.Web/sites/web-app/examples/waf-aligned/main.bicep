// ============================================================================
// Example: WAF-Aligned Web App Deployment
// Description: Deploys a Web App following Azure Well-Architected Framework
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

// Deploy a WAF-aligned web app
module webApp '../../main.bicep' = {
  name: 'webapp-waf-deployment'
  params: {
    name: 'app-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    kind: 'app,linux'
    serverFarmResourceId: serverFarmResourceId
    // Security: HTTPS only
    httpsOnly: true
    // VNet Integration for network isolation
    virtualNetworkSubnetId: virtualNetworkSubnetId
    vnetRouteAllEnabled: true
    // Managed Identity for secure authentication
    managedIdentities: {
      systemAssigned: true
    }
    // Secure site configuration
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      healthCheckPath: '/health'
    }
    // Diagnostic settings for monitoring
    diagnosticSettings: [
      {
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
    // Resource lock to prevent accidental deletion
    lock: {
      kind: 'CanNotDelete'
      name: 'webapp-delete-lock'
    }
    tags: {
      Environment: environment
      Compliance: 'WAF-Aligned'
      'hidden-title': 'Web App (WAF-Aligned)'
    }
  }
}

output webAppId string = webApp.outputs.resourceId
output webAppName string = webApp.outputs.name
output webAppHostname string = webApp.outputs.defaultHostname
output webAppLocation string = webApp.outputs.location
output systemAssignedPrincipalId string = webApp.outputs.systemAssignedMIPrincipalId
