// ============================================================================
// Test: <Module Name>
// ============================================================================

targetScope = 'subscription'

@description('Location for test resources.')
param location string = 'eastus'

@description('Unique suffix for resource names.')
param uniqueSuffix string = uniqueString(subscription().subscriptionId, deployment().name)

// Resource Group for tests
resource testResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-<module>-test-${uniqueSuffix}'
  location: location
}

// ============================================================================
// Test Case 1: Default Configuration
// ============================================================================
module testDefault '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-<module>-default'
  params: {
    name: '<resource>-default-${uniqueSuffix}'
    location: location
    tags: {
      TestCase: 'Default'
    }
  }
}

// ============================================================================
// Test Case 2: <Describe test case>
// ============================================================================
// Add additional test cases here

// ============================================================================
// Outputs for validation
// ============================================================================
output defaultResourceId string = testDefault.outputs.resourceId
