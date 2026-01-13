// ============================================================================
// Test: Azure Web App / Function App Module (AVM Wrapper)
// ============================================================================

targetScope = 'subscription'

@description('Location for test resources.')
param location string = 'eastus'

@description('Unique suffix for resource names.')
param uniqueSuffix string = uniqueString(subscription().subscriptionId, deployment().name)

// Resource Group for tests
resource testResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-webapp-test-${uniqueSuffix}'
  location: location
}

// App Service Plan for Web Apps
module appServicePlan 'br/public:avm/res/web/serverfarm:0.6.0' = {
  scope: testResourceGroup
  name: 'test-asp'
  params: {
    name: 'asp${uniqueSuffix}'
    location: location
    kind: 'linux'
    reserved: true
    skuName: 'P1v3'
    skuCapacity: 1
  }
}

// Storage Account for Function App tests
module storageAccount 'br/public:avm/res/storage/storage-account:0.19.0' = {
  scope: testResourceGroup
  name: 'test-storage'
  params: {
    name: 'st${uniqueSuffix}'
    location: location
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
  }
}

// ============================================================================
// Test Case 1: Minimal Web App Configuration
// ============================================================================
module testMinimal '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-webapp-minimal'
  params: {
    name: 'appmin${uniqueSuffix}'
    location: location
    kind: 'app,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
    }
    tags: {
      TestCase: 'Minimal'
    }
  }
}

// ============================================================================
// Test Case 2: Web App with VNet Integration
// ============================================================================
module testVnetIntegration '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-webapp-vnet'
  params: {
    name: 'appvnet${uniqueSuffix}'
    location: location
    kind: 'app,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    httpsOnly: true
    managedIdentities: {
      systemAssigned: true
    }
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
    tags: {
      TestCase: 'VNetIntegration'
    }
  }
}

// ============================================================================
// Test Case 3: Function App
// ============================================================================
module testFunctionApp '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-functionapp'
  params: {
    name: 'func${uniqueSuffix}'
    location: location
    kind: 'functionapp,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    storageAccountResourceId: storageAccount.outputs.resourceId
    functionsExtensionVersion: '~4'
    functionsWorkerRuntime: 'dotnet-isolated'
    httpsOnly: true
    managedIdentities: {
      systemAssigned: true
    }
    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      alwaysOn: true
    }
    tags: {
      TestCase: 'FunctionApp'
    }
  }
}

// ============================================================================
// Test Case 4: WAF-Aligned Web App Configuration
// ============================================================================
module testWafAligned '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-webapp-waf'
  params: {
    name: 'appwaf${uniqueSuffix}'
    location: location
    kind: 'app,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    httpsOnly: true
    managedIdentities: {
      systemAssigned: true
    }
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      healthCheckPath: '/health'
    }
    lock: {
      kind: 'CanNotDelete'
      name: 'webapp-test-lock'
    }
    tags: {
      TestCase: 'WAF-Aligned'
      Compliance: 'WAF'
    }
  }
}

// ============================================================================
// Outputs
// ============================================================================
output testMinimalId string = testMinimal.outputs.resourceId
output testVnetIntegrationId string = testVnetIntegration.outputs.resourceId
output testFunctionAppId string = testFunctionApp.outputs.resourceId
output testWafAlignedId string = testWafAligned.outputs.resourceId
