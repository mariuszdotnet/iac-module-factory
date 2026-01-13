// ============================================================================
// Example: Function App Deployment
// Description: Deploys an Azure Function App with common configurations
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'dev'

@description('The resource ID of the App Service Plan.')
param serverFarmResourceId string

@description('The resource ID of the Storage Account for the Function App.')
param storageAccountResourceId string

@description('Application Insights Resource ID.')
param appInsightResourceId string = ''

// Deploy a Function App using the AVM wrapper
module functionApp '../../main.bicep' = {
  name: 'functionapp-deployment'
  params: {
    name: 'func-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    kind: 'functionapp,linux'
    serverFarmResourceId: serverFarmResourceId
    // Storage account for function triggers and logging
    storageAccountResourceId: storageAccountResourceId
    storageAccountUseIdentityAuthentication: true
    // Functions runtime configuration
    functionsExtensionVersion: '~4'
    functionsWorkerRuntime: 'dotnet-isolated'
    // Security: HTTPS only
    httpsOnly: true
    // Application Insights for monitoring
    appInsightResourceId: appInsightResourceId
    // Managed Identity for secure authentication
    managedIdentities: {
      systemAssigned: true
    }
    // Site configuration
    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
    }
    tags: {
      Environment: environment
      Purpose: 'Function App'
      Runtime: 'dotnet-isolated'
    }
  }
}

output functionAppId string = functionApp.outputs.resourceId
output functionAppName string = functionApp.outputs.name
output functionAppHostname string = functionApp.outputs.defaultHostname
output systemAssignedPrincipalId string = functionApp.outputs.systemAssignedMIPrincipalId
