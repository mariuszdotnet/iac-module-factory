using '../../main.bicep'

param name = 'app-minimal-test'
param location = 'eastus'
param kind = 'app,linux'
param serverFarmResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Web/serverfarms/asp-test'
param siteConfig = {
  linuxFxVersion: 'DOTNETCORE|8.0'
}
param tags = {
  Environment: 'Test'
  TestCase: 'Minimal'
}
