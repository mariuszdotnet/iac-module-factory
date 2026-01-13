// ============================================================================
// Test: Azure Container Registry Module (AVM Wrapper)
// ============================================================================

targetScope = 'subscription'

@description('Location for test resources.')
param location string = 'eastus'

@description('Unique suffix for resource names.')
param uniqueSuffix string = uniqueString(subscription().subscriptionId, deployment().name)

// Resource Group for tests
resource testResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-acr-test-${uniqueSuffix}'
  location: location
}

// ============================================================================
// Test Case 1: Minimal Configuration (Standard SKU)
// ============================================================================
module testMinimal '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-acr-minimal'
  params: {
    name: 'acrmin${uniqueSuffix}'
    location: location
    acrSku: 'Standard'
    tags: {
      TestCase: 'Minimal'
    }
  }
}

// ============================================================================
// Test Case 2: Premium with Zone Redundancy
// ============================================================================
module testPremium '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-acr-premium'
  params: {
    name: 'acrprem${uniqueSuffix}'
    location: location
    acrSku: 'Premium'
    zoneRedundancy: 'Enabled'
    retentionPolicyStatus: 'enabled'
    retentionPolicyDays: 30
    trustPolicyStatus: 'enabled'
    tags: {
      TestCase: 'Premium'
    }
  }
}

// ============================================================================
// Test Case 3: Premium with Managed Identity
// ============================================================================
module testWithIdentity '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-acr-identity'
  params: {
    name: 'acrid${uniqueSuffix}'
    location: location
    acrSku: 'Premium'
    managedIdentities: {
      systemAssigned: true
    }
    tags: {
      TestCase: 'ManagedIdentity'
    }
  }
}

// ============================================================================
// Test Case 4: With Diagnostic Settings
// ============================================================================
// Note: Requires Log Analytics workspace - uncomment when available
// module testWithDiagnostics '../main.bicep' = {
//   scope: testResourceGroup
//   name: 'test-acr-diagnostics'
//   params: {
//     name: 'acrdiag${uniqueSuffix}'
//     location: location
//     acrSku: 'Premium'
//     diagnosticSettings: [
//       {
//         workspaceResourceId: '<log-analytics-workspace-id>'
//       }
//     ]
//     tags: {
//       TestCase: 'Diagnostics'
//     }
//   }
// }

// ============================================================================
// Outputs for validation
// ============================================================================
output minimalAcrId string = testMinimal.outputs.resourceId
output minimalLoginServer string = testMinimal.outputs.loginServer
output premiumAcrId string = testPremium.outputs.resourceId
output identityAcrId string = testWithIdentity.outputs.resourceId
output identityPrincipalId string = testWithIdentity.outputs.systemAssignedMIPrincipalId
