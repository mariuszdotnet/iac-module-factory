// ============================================================================
// Test: Azure Key Vault Module (AVM Wrapper)
// ============================================================================

targetScope = 'subscription'

@description('Location for test resources.')
param location string = 'eastus'

@description('Unique suffix for resource names.')
param uniqueSuffix string = uniqueString(subscription().subscriptionId, deployment().name)

// Resource Group for tests
resource testResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-kv-test-${uniqueSuffix}'
  location: location
}

// ============================================================================
// Test Case 1: Minimal Configuration (Standard SKU)
// ============================================================================
module testMinimal '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-kv-minimal'
  params: {
    name: 'kvmin${uniqueSuffix}'
    location: location
    sku: 'standard'
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    tags: {
      TestCase: 'Minimal'
    }
  }
}

// ============================================================================
// Test Case 2: Premium with RBAC Authorization
// ============================================================================
module testPremiumRbac '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-kv-premium-rbac'
  params: {
    name: 'kvprem${uniqueSuffix}'
    location: location
    sku: 'premium'
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Disabled'
    tags: {
      TestCase: 'PremiumRBAC'
    }
  }
}

// ============================================================================
// Test Case 3: With Managed Identity
// ============================================================================
module testWithIdentity '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-kv-identity'
  params: {
    name: 'kvid${uniqueSuffix}'
    location: location
    sku: 'premium'
    enableRbacAuthorization: true
    managedIdentities: {
      systemAssigned: true
    }
    tags: {
      TestCase: 'ManagedIdentity'
    }
  }
}

// ============================================================================
// Test Case 4: With Access Policies (Legacy)
// ============================================================================
module testAccessPolicies '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-kv-accesspolicies'
  params: {
    name: 'kvap${uniqueSuffix}'
    location: location
    sku: 'standard'
    enableRbacAuthorization: false
    publicNetworkAccess: 'Enabled'
    tags: {
      TestCase: 'AccessPolicies'
    }
  }
}

// ============================================================================
// Test Case 5: With Network Restrictions
// ============================================================================
module testNetworkRestricted '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-kv-network'
  params: {
    name: 'kvnet${uniqueSuffix}'
    location: location
    sku: 'premium'
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    tags: {
      TestCase: 'NetworkRestricted'
    }
  }
}

// ============================================================================
// Outputs for validation
// ============================================================================
output minimalKeyVaultId string = testMinimal.outputs.resourceId
output minimalKeyVaultUri string = testMinimal.outputs.uri
output premiumKeyVaultId string = testPremiumRbac.outputs.resourceId
output identityKeyVaultId string = testWithIdentity.outputs.resourceId
output identityPrincipalId string = testWithIdentity.outputs.systemAssignedMIPrincipalId
output accessPoliciesKeyVaultId string = testAccessPolicies.outputs.resourceId
output networkRestrictedKeyVaultId string = testNetworkRestricted.outputs.resourceId
