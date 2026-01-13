// ============================================================================
// Module: Azure Container Registry (AVM Wrapper)
// Description: Deploys an Azure Container Registry using the Azure Verified Module
// AVM Reference: br/public:avm/res/container-registry/registry
// ============================================================================

@description('Required. Name of the Container Registry.')
@minLength(5)
@maxLength(50)
param name string

@description('Required. Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

// =============================================================================
// SKU & Basic Configuration
// =============================================================================

@description('Optional. Tier of your Azure container registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

@description('Optional. Enable admin user that has push/pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Optional. Enables registry-wide pull from unauthenticated clients.')
param anonymousPullEnabled bool = false

// =============================================================================
// Network & Security Configuration
// =============================================================================

@description('Optional. Whether or not public network access is allowed for this resource.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string?

@description('Optional. Whether to allow trusted Azure services to access a network restricted registry.')
@allowed([
  'AzureServices'
  'None'
])
param networkRuleBypassOptions string = 'AzureServices'

@description('Optional. The default action of allow or deny when no other rules match.')
@allowed([
  'Allow'
  'Deny'
])
param networkRuleSetDefaultAction string = 'Deny'

@description('Optional. The IP ACL rules. Note, requires the acrSku to be Premium.')
param networkRuleSetIpRules array = []

// =============================================================================
// Policy Configuration
// =============================================================================

@description('Optional. Whether or not zone redundancy is enabled for this container registry.')
@allowed([
  'Disabled'
  'Enabled'
])
param zoneRedundancy string = 'Enabled'

@description('Optional. The value that indicates whether the trust policy is enabled or not.')
@allowed([
  'disabled'
  'enabled'
])
param trustPolicyStatus string = 'disabled'

@description('Optional. The value that indicates whether the quarantine policy is enabled or not.')
@allowed([
  'disabled'
  'enabled'
])
param quarantinePolicyStatus string = 'disabled'

@description('Optional. The value that indicates whether the retention policy is enabled or not.')
@allowed([
  'disabled'
  'enabled'
])
param retentionPolicyStatus string = 'enabled'

@description('Optional. The number of days to retain an untagged manifest after which it gets purged.')
param retentionPolicyDays int = 15

@description('Optional. The value that indicates whether the export policy is enabled or not.')
@allowed([
  'disabled'
  'enabled'
])
param exportPolicyStatus string = 'disabled'

@description('Optional. Soft Delete policy status.')
@allowed([
  'disabled'
  'enabled'
])
param softDeletePolicyStatus string = 'disabled'

@description('Optional. The number of days after which a soft-deleted item is permanently deleted.')
param softDeletePolicyDays int = 7

@description('Optional. Enable a single data endpoint per region for serving data.')
param dataEndpointEnabled bool = false

@description('Optional. The value that indicates whether the policy for using ARM audience token is enabled.')
@allowed([
  'disabled'
  'enabled'
])
param azureADAuthenticationAsArmPolicyStatus string = 'enabled'

// =============================================================================
// Identity & Encryption
// =============================================================================

@description('Optional. The managed identity definition for this resource.')
param managedIdentities object = {}

@description('Optional. The customer managed key definition for encryption.')
param customerManagedKey object = {}

// =============================================================================
// Advanced Features
// =============================================================================

@description('Optional. All replications to create.')
param replications array = []

@description('Optional. All webhooks to create.')
param webhooks array = []

@description('Optional. Array of Cache Rules.')
param cacheRules array = []

@description('Optional. Array of Credential Sets.')
param credentialSets array = []

@description('Optional. Scope maps setting.')
param scopeMaps array = []

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

// =============================================================================
// Access Control
// =============================================================================

@description('Optional. Array of role assignments to create.')
param roleAssignments array = []

@description('Optional. The lock settings of the service.')
param lock object = {}

// =============================================================================
// Telemetry
// =============================================================================

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =============================================================================
// Deploy Azure Verified Module
// =============================================================================

module containerRegistry 'br/public:avm/res/container-registry/registry:0.9.3' = {
  name: '${uniqueString(deployment().name, location)}-acr'
  params: {
    // Required
    name: name
    location: location
    tags: tags

    // SKU & Basic
    acrSku: acrSku
    acrAdminUserEnabled: acrAdminUserEnabled
    anonymousPullEnabled: anonymousPullEnabled

    // Network & Security
    publicNetworkAccess: !empty(publicNetworkAccess) ? publicNetworkAccess : null
    networkRuleBypassOptions: networkRuleBypassOptions
    networkRuleSetDefaultAction: networkRuleSetDefaultAction
    networkRuleSetIpRules: networkRuleSetIpRules

    // Policies
    zoneRedundancy: zoneRedundancy
    trustPolicyStatus: trustPolicyStatus
    quarantinePolicyStatus: quarantinePolicyStatus
    retentionPolicyStatus: retentionPolicyStatus
    retentionPolicyDays: retentionPolicyDays
    exportPolicyStatus: exportPolicyStatus
    softDeletePolicyStatus: softDeletePolicyStatus
    softDeletePolicyDays: softDeletePolicyDays
    dataEndpointEnabled: dataEndpointEnabled
    azureADAuthenticationAsArmPolicyStatus: azureADAuthenticationAsArmPolicyStatus

    // Identity & Encryption
    managedIdentities: !empty(managedIdentities) ? managedIdentities : null
    customerManagedKey: !empty(customerManagedKey) ? customerManagedKey : null

    // Advanced Features
    replications: replications
    webhooks: webhooks
    cacheRules: cacheRules
    credentialSets: credentialSets
    scopeMaps: scopeMaps

    // Private Endpoints
    privateEndpoints: privateEndpoints

    // Diagnostics
    diagnosticSettings: diagnosticSettings

    // Access Control
    roleAssignments: roleAssignments
    lock: !empty(lock) ? lock : null

    // Telemetry
    enableTelemetry: enableTelemetry
  }
}

// =============================================================================
// Outputs
// =============================================================================

@description('The resource ID of the Container Registry.')
output resourceId string = containerRegistry.outputs.resourceId

@description('The name of the Container Registry.')
output name string = containerRegistry.outputs.name

@description('The login server URL of the Container Registry.')
output loginServer string = containerRegistry.outputs.loginServer

@description('The name of the resource group the Container Registry was deployed into.')
output resourceGroupName string = containerRegistry.outputs.resourceGroupName

@description('The location the resource was deployed into.')
output location string = containerRegistry.outputs.location

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = containerRegistry.outputs.?systemAssignedMIPrincipalId

@description('The private endpoints of the Container Registry.')
output privateEndpoints array = containerRegistry.outputs.privateEndpoints

@description('The Resource IDs of the ACR Credential Sets.')
output credentialSetsResourceIds array = containerRegistry.outputs.credentialSetsResourceIds

@description('The Principal IDs of the ACR Credential Sets system-assigned identities.')
output credentialSetsSystemAssignedMIPrincipalIds array = containerRegistry.outputs.credentialSetsSystemAssignedMIPrincipalIds
