// ============================================================================
// Module: Azure Web App / Function App (AVM Wrapper)
// Description: Deploys an Azure Web App or Function App using the Azure Verified Module
// AVM Reference: br/public:avm/res/web/site:0.21.0
// ============================================================================

@description('Required. Name of the site.')
@minLength(2)
@maxLength(60)
param name string

@description('Required. Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

// =============================================================================
// Basic Configuration
// =============================================================================

@description('Required. Type of site to deploy.')
@allowed([
  'app'
  'functionapp'
  'functionapp,linux'
  'functionapp,workflowapp'
  'functionapp,workflowapp,linux'
  'functionapp,linux,container'
  'functionapp,linux,container,azurecontainerapps'
  'app,linux'
  'app,linux,container'
  'app,container,windows'
])
param kind string

@description('Required. The resource ID of the app service plan to use for the site.')
param serverFarmResourceId string

@description('Optional. If client affinity is enabled.')
param clientAffinityEnabled bool = true

@description('Optional. If client cert is enabled.')
param clientCertEnabled bool = false

@description('Optional. Client certificate mode.')
@allowed([
  'Optional'
  'OptionalInteractiveUser'
  'Required'
])
param clientCertMode string = 'Optional'

@description('Optional. Paths to exclude when using client certificates, separated by ;.')
param clientCertExclusionPaths string = ''

@description('Optional. Hostname SSL states are used to manage the SSL bindings for app\'s hostnames.')
param hostNameSslStates array = []

@description('Optional. To enable Hyper-V sandbox.')
param hyperV bool = false

@description('Optional. Determines whether the app preserves IP after swapping a slot.')
param redundancyMode string = 'None'

@description('Optional. Configures a site to accept only HTTPS requests.')
param httpsOnly bool = true

@description('Optional. Whether to use a managed identity for the storage account.')
param storageAccountUseIdentityAuthentication bool = false

// =============================================================================
// Site Configuration
// =============================================================================

@description('Optional. The site config object.')
param siteConfig object = {}

// =============================================================================
// App Settings & Connection Strings
// =============================================================================

@description('Optional. The app settings key-value pairs.')
param appSettingsKeyValuePairs object = {}

// =============================================================================
// Authentication
// =============================================================================

@description('Optional. The authentication/authorization settings for the site.')
param authSettingV2Configuration object = {}

// =============================================================================
// Identity
// =============================================================================

@description('Optional. The managed identity definition for this resource.')
param managedIdentities object = {}

// =============================================================================
// Virtual Network Integration
// =============================================================================

@description('Optional. Azure Resource Manager ID of the Virtual network and subnet to be joined by Regional VNET Integration.')
param virtualNetworkSubnetId string = ''

@description('Optional. To enable accessing content over virtual network.')
param vnetContentShareEnabled bool = false

@description('Optional. To enable pulling image over Virtual Network.')
param vnetImagePullEnabled bool = false

@description('Optional. Virtual Network Route All enabled.')
param vnetRouteAllEnabled bool = false

// =============================================================================
// Container & Functions Configuration
// =============================================================================

@description('Optional. Resource ID of the storage account used to manage triggers and logging function execution.')
param storageAccountResourceId string = ''

@description('Optional. Required if app service plan is different from functionapp.')
param storageAccountRequired bool = false

@description('Optional. Checks if Customer provided storage account is required.')
param functionsExtensionVersion string = '~4'

@description('Optional. The runtime stack used for functions.')
param functionsWorkerRuntime string = ''

@description('Optional. The number of days to keep Function App logs.')
param dailyMemoryTimeQuota int = 0

@description('Optional. If the public network access is enabled or not.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

// =============================================================================
// Slots
// =============================================================================

@description('Optional. Configuration for deployment slots for the site.')
param slots array = []

// =============================================================================
// Hybrid Connection
// =============================================================================

@description('Optional. The hybrid connection relay configurations.')
param hybridConnectionRelays array = []

// =============================================================================
// Private Endpoints
// =============================================================================

@description('Optional. Configuration details for private endpoints.')
param privateEndpoints array = []

// =============================================================================
// Diagnostics & Monitoring
// =============================================================================

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings array = []

@description('Optional. The logs settings configuration for the site.')
param basicPublishingCredentialsPolicies array = []

// =============================================================================
// Security & Access Control
// =============================================================================

@description('Optional. Array of role assignments to create.')
param roleAssignments array = []

@description('Optional. The lock settings of the service.')
param lock object = {}

// =============================================================================
// Application Insights
// =============================================================================

@description('Optional. Resource ID of the app insight to use for the site.')
param appInsightResourceId string = ''

// =============================================================================
// Key Vault References
// =============================================================================

@description('Optional. Azure Key Vault reference resource ID of the vault.')
param keyVaultAccessIdentityResourceId string = ''

// =============================================================================
// Telemetry
// =============================================================================

@description('Optional. Enable telemetry via the Azure Verified Module.')
param enableTelemetry bool = true

// =============================================================================
// Deploy Azure Web App / Function App using AVM 0.21.0
// =============================================================================

module site 'br/public:avm/res/web/site:0.21.0' = {
  name: '${uniqueString(deployment().name, location)}-site'
  params: {
    name: name
    location: location
    tags: tags
    kind: kind
    serverFarmResourceId: serverFarmResourceId
    clientAffinityEnabled: clientAffinityEnabled
    clientCertEnabled: clientCertEnabled
    clientCertMode: clientCertMode
    clientCertExclusionPaths: clientCertExclusionPaths
    hostNameSslStates: hostNameSslStates
    hyperV: hyperV
    redundancyMode: redundancyMode
    httpsOnly: httpsOnly
    storageAccountUseIdentityAuthentication: storageAccountUseIdentityAuthentication
    siteConfig: siteConfig
    appSettingsKeyValuePairs: appSettingsKeyValuePairs
    authSettingV2Configuration: authSettingV2Configuration
    managedIdentities: managedIdentities
    virtualNetworkSubnetId: virtualNetworkSubnetId
    vnetContentShareEnabled: vnetContentShareEnabled
    vnetImagePullEnabled: vnetImagePullEnabled
    vnetRouteAllEnabled: vnetRouteAllEnabled
    storageAccountResourceId: storageAccountResourceId
    storageAccountRequired: storageAccountRequired
    functionsExtensionVersion: functionsExtensionVersion
    functionsWorkerRuntime: functionsWorkerRuntime
    dailyMemoryTimeQuota: dailyMemoryTimeQuota
    publicNetworkAccess: publicNetworkAccess
    slots: slots
    hybridConnectionRelays: hybridConnectionRelays
    privateEndpoints: privateEndpoints
    diagnosticSettings: diagnosticSettings
    basicPublishingCredentialsPolicies: basicPublishingCredentialsPolicies
    roleAssignments: roleAssignments
    lock: lock
    appInsightResourceId: appInsightResourceId
    keyVaultAccessIdentityResourceId: keyVaultAccessIdentityResourceId
    enableTelemetry: enableTelemetry
  }
}

// =============================================================================
// Outputs
// =============================================================================

@description('The resource ID of the site.')
output resourceId string = site.outputs.resourceId

@description('The name of the site.')
output name string = site.outputs.name

@description('The resource group the site was deployed into.')
output resourceGroupName string = site.outputs.resourceGroupName

@description('The location the site was deployed into.')
output location string = site.outputs.location

@description('The default hostname of the site.')
output defaultHostname string = site.outputs.defaultHostname

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = site.outputs.?systemAssignedMIPrincipalId ?? ''

@description('The slots of the site.')
output slots array = site.outputs.?slots ?? []
