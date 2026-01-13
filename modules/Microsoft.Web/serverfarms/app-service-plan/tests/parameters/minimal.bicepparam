using '../../main.bicep'

param name = 'asp-minimal-test'
param location = 'eastus'
param skuName = 'B1'
param skuCapacity = 1
param tags = {
  Environment: 'Test'
  TestCase: 'Minimal'
}
