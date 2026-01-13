using '../../main.bicep'

param name = 'asp-premium-test'
param location = 'eastus'
param skuName = 'P1v3'
param skuCapacity = 3
param zoneRedundant = true
param perSiteScaling = true
param tags = {
  Environment: 'Test'
  TestCase: 'Premium'
}
