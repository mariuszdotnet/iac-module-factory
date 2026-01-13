// ============================================================================
// Module: Azure Key Vault (AVM Wrapper)
// Description: Deploys an Azure Key Vault using the Azure Verified Module
// AVM Reference: br/public:avm/res/key-vault/vault
// ============================================================================

@description('Required. Name of the Key Vault.')
@minLength(3)
@maxLength(24)
param name string

@description('Required. Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

// =============================================================================
// SKU & Basic Configuration
// =============================================================================

@description('Optional. The SKU of the Key Vault.')
@allowed([
  'standard'
  'premium'
])
param sku string = 'premium'

@description('Optional. Property that controls how data actions are authorized.')
param enableRbacAuthorization bool = true

@description('Optional. Whether the vault will accept traffic from public internet.')
param publicNetworkAccess string = 'Disabled'

// =============================================================================
// Protection & Security Configuration
// =============================================================================

@description('Optional. Provide \'true\' to enable Key Vault\'s soft delete feature.')
param enableSoftDelete bool = true

@description('Optional. Soft delete retention in days.')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

@description('Optional. Provide \'true\' to enable Key Vault\'s purge protection feature.')
param enablePurgeProtection bool = true

@description('Optional. The vault\'s create mode to indicate whether the vault needs to be recovered or not.')
@allowed([
  'default'
  'recover'
])
param createMode string = 'default'

// =============================================================================
// Network Configuration
// =============================================================================

@description('Optional. Rules governing the accessibility of the resource from specific network locations.')
param networkAcls object = {
  bypass: 'AzureServices'
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: []
}

// =============================================================================
// Access Configuration
// =============================================================================

@description('Optional. Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault.')
param enableVaultForDeployment bool = false

@description('Optional. Whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enableVaultForDiskEncryption bool = false

@description('Optional. Whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault.')
param enableVaultForTemplateDeployment bool = false

@description('Optional. All access policies to create.')
param accessPolicies array = []

// =============================================================================
// Keys, Secrets & Certificates
// =============================================================================

@description('Optional. All keys to create.')
param keys array = []

@description('Optional. All secrets to create.')
param secrets array = []

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
// Identity & Encryption
// =============================================================================

@description('Optional. The managed identity definition for this resource.')
param managedIdentities object = {}

// =============================================================================
// Telemetry
// =============================================================================

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =============================================================================
// Deploy Azure Verified Module
// =============================================================================

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  name: '${uniqueString(deployment().name, location)}-kv'
  params: {
    // Required
    name: name
    location: location
    tags: tags

    // SKU & Basic
    sku: sku
    enableRbacAuthorization: enableRbacAuthorization
    publicNetworkAccess: publicNetworkAccess

    // Protection & Security
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    createMode: createMode

    // Network
    networkAcls: !empty(networkAcls) ? networkAcls : null

    // Access
    enableVaultForDeployment: enableVaultForDeployment
    enableVaultForDiskEncryption: enableVaultForDiskEncryption
    enableVaultForTemplateDeployment: enableVaultForTemplateDeployment
    accessPolicies: accessPolicies

    // Keys & Secrets
    keys: keys
    secrets: secrets

    // Private Endpoints
    privateEndpoints: privateEndpoints

    // Diagnostics
    diagnosticSettings: diagnosticSettings

    // Access Control
    roleAssignments: roleAssignments
    lock: !empty(lock) ? lock : null

    // Identity
    managedIdentities: !empty(managedIdentities) ? managedIdentities : null

    // Telemetry
    enableTelemetry: enableTelemetry
  }
}

// =============================================================================
// Outputs
// =============================================================================

@description('The resource ID of the Key Vault.')
output resourceId string = keyVault.outputs.resourceId

@description('The name of the Key Vault.')
output name string = keyVault.outputs.name

@description('The URI of the Key Vault.')
output uri string = keyVault.outputs.uri

@description('The name of the resource group the Key Vault was deployed into.')
output resourceGroupName string = keyVault.outputs.resourceGroupName

@description('The location the resource was deployed into.')
output location string = keyVault.outputs.location

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = keyVault.outputs.?systemAssignedMIPrincipalId

@description('The private endpoints of the Key Vault.')
output privateEndpoints array = keyVault.outputs.privateEndpoints
