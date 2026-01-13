using '../../main.bicep'

param name = 'acrpremiumtest001'
param location = 'eastus'
param skuName = 'Premium'
param zoneRedundancy = true
param retentionPolicyEnabled = true
param retentionPolicyDays = 30
param tags = {
  Environment: 'Test'
  Purpose: 'PremiumConfiguration'
}
