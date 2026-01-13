// ============================================================================
// Example: Basic Web App Deployment
// ============================================================================

targetScope = 'resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'dev'

@description('The resource ID of the App Service Plan.')
param serverFarmResourceId string

// Deploy a basic web app using the AVM wrapper
module webApp '../../main.bicep' = {
  name: 'webapp-basic-deployment'
  params: {
    name: 'app-${environment}-${uniqueString(resourceGroup().id)}'
    location: location
    kind: 'app'
    serverFarmResourceId: serverFarmResourceId
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      alwaysOn: false
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
    tags: {
      Environment: environment
      Purpose: 'Web Application'
    }
  }
}

output webAppId string = webApp.outputs.resourceId
output webAppName string = webApp.outputs.name
output webAppHostname string = webApp.outputs.defaultHostname
