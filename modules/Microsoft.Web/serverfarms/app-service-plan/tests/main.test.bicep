// ============================================================================
// Test: Azure App Service Plan Module (AVM Wrapper)
// ============================================================================

targetScope = 'subscription'

@description('Location for test resources.')
param location string = 'eastus'

@description('Unique suffix for resource names.')
param uniqueSuffix string = uniqueString(subscription().subscriptionId, deployment().name)

// Resource Group for tests
resource testResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-asp-test-${uniqueSuffix}'
  location: location
}

// ============================================================================
// Test Case 1: Minimal Configuration (Basic SKU)
// ============================================================================
module testMinimal '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-asp-minimal'
  params: {
    name: 'aspmin${uniqueSuffix}'
    location: location
    skuName: 'B1'
    skuCapacity: 1
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
  name: 'test-asp-premium'
  params: {
    name: 'aspprem${uniqueSuffix}'
    location: location
    skuName: 'P1v3'
    skuCapacity: 3
    zoneRedundant: true
    perSiteScaling: true
    tags: {
      TestCase: 'Premium'
    }
  }
}

// ============================================================================
// Test Case 3: Linux App Service Plan
// ============================================================================
module testLinux '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-asp-linux'
  params: {
    name: 'asplinux${uniqueSuffix}'
    location: location
    skuName: 'P1v3'
    kind: 'linux'
    reserved: true
    tags: {
      TestCase: 'Linux'
    }
  }
}

// ============================================================================
// Test Case 4: WAF-Aligned Configuration
// ============================================================================
module testWafAligned '../main.bicep' = {
  scope: testResourceGroup
  name: 'test-asp-waf'
  params: {
    name: 'aspwaf${uniqueSuffix}'
    location: location
    skuName: 'P1v3'
    skuCapacity: 3
    zoneRedundant: true
    perSiteScaling: true
    lock: {
      kind: 'CanNotDelete'
      name: 'asp-test-lock'
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
output testPremiumId string = testPremium.outputs.resourceId
output testLinuxId string = testLinux.outputs.resourceId
output testWafAlignedId string = testWafAligned.outputs.resourceId
