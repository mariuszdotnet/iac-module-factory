using '../../main.bicep'

param name = 'asp-waf-test'
param location = 'eastus'
param skuName = 'P1v3'
param skuCapacity = 3
param zoneRedundant = true
param perSiteScaling = true
param lock = {
  kind: 'CanNotDelete'
  name: 'asp-waf-lock'
}
param tags = {
  Environment: 'Test'
  TestCase: 'WAF-Aligned'
  Compliance: 'WAF'
}
