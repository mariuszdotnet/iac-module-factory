// ============================================================================
// Module: Azure App Service Plan (AVM Wrapper)
// Description: Deploys an Azure App Service Plan using the Azure Verified Module
// AVM Reference: br/public:avm/res/web/serverfarm:0.6.0
// ============================================================================

@description('Required. Name of the App Service Plan.')
@minLength(1)
@maxLength(40)
param name string

@description('Required. Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

// =============================================================================
// SKU & Basic Configuration
// =============================================================================

@description('Optional. The name of the SKU. Determines the tier, size, family of the App Service Plan. Defaults to P1v3 for zone redundancy support.')
param skuName string = 'P1v3'

@description('Optional. Number of workers associated with the App Service Plan. Defaults to 3 for zone redundancy.')
@minValue(1)
param skuCapacity int = 3

@description('Optional. Kind of server OS.')
@allowed([
  'app'
  'elastic'
  'functionapp'
  'linux'
  'windows'
])
param kind string = 'app'

@description('Optional. If true, this App Service Plan will be Linux-based. Required for Linux apps.')
param reserved bool = kind == 'linux'

// =============================================================================
// Scaling Configuration
// =============================================================================

@description('Optional. If true, apps assigned to this App Service plan can be scaled independently.')
param perSiteScaling bool = false

@description('Optional. Enable ElasticScaleEnabled App Service Plan.')
param elasticScaleEnabled bool = maximumElasticWorkerCount > 1

@description('Optional. Maximum number of total workers allowed for ElasticScaleEnabled App Service Plan.')
param maximumElasticWorkerCount int = 1

@description('Optional. Scaling worker count.')
param targetWorkerCount int = 0

@description('Optional. The instance size of the hosting plan (small, medium, or large).')
@allowed([
  0
  1
  2
])
param targetWorkerSize int = 0

@description('Optional. Target worker tier assigned to the App Service plan.')
param workerTierName string = ''

// =============================================================================
// High Availability & Resilience
// =============================================================================

@description('Optional. Enable zone redundancy. Only available for Premium and ElasticPremium SKUs in supported regions.')
param zoneRedundant bool = startsWith(skuName, 'P') || startsWith(skuName, 'EP') ? true : false

// =============================================================================
// App Service Environment & Hyper-V
// =============================================================================

@description('Optional. The Resource ID of the App Service Environment to use for the App Service Plan.')
param appServiceEnvironmentResourceId string = ''

@description('Optional. If Hyper-V container app service plan true, false otherwise.')
param hyperV bool?

// =============================================================================
// Diagnostics & Monitoring
// =============================================================================

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings array = []

// =============================================================================
// Security & Access Control
// =============================================================================

@description('Optional. Array of role assignments to create.')
param roleAssignments array = []

@description('Optional. The lock settings of the service.')
param lock object = {}

// =============================================================================
// Telemetry
// =============================================================================

@description('Optional. Enable telemetry via the Azure Verified Module.')
param enableTelemetry bool = true

// =============================================================================
// Deploy Azure App Service Plan using AVM 0.6.0
// =============================================================================

module appServicePlan 'br/public:avm/res/web/serverfarm:0.6.0' = {
  params: {
    name: name
    location: location
    tags: tags
    skuName: skuName
    skuCapacity: skuCapacity
    kind: kind
    reserved: reserved
    perSiteScaling: perSiteScaling
    elasticScaleEnabled: elasticScaleEnabled
    maximumElasticWorkerCount: maximumElasticWorkerCount
    targetWorkerCount: targetWorkerCount
    targetWorkerSize: targetWorkerSize
    workerTierName: workerTierName
    zoneRedundant: zoneRedundant
    appServiceEnvironmentResourceId: appServiceEnvironmentResourceId
    hyperV: hyperV
    diagnosticSettings: diagnosticSettings
    roleAssignments: roleAssignments
    lock: lock
    enableTelemetry: enableTelemetry
  }
}

// =============================================================================
// Outputs
// =============================================================================

@description('The resource ID of the App Service Plan.')
output resourceId string = appServicePlan.outputs.resourceId

@description('The name of the App Service Plan.')
output name string = appServicePlan.outputs.name

@description('The resource group the App Service Plan was deployed into.')
output resourceGroupName string = appServicePlan.outputs.resourceGroupName

@description('The location the App Service Plan was deployed into.')
output location string = appServicePlan.outputs.location
