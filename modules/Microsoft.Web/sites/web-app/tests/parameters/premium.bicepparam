using '../../main.bicep'

param name = 'app-premium-test'
param location = 'eastus'
param kind = 'app,linux'
param serverFarmResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Web/serverfarms/asp-test'
param httpsOnly = true
param managedIdentities = {
  systemAssigned: true
}
param siteConfig = {
  linuxFxVersion: 'DOTNETCORE|8.0'
  alwaysOn: true
  ftpsState: 'Disabled'
  minTlsVersion: '1.2'
  http20Enabled: true
}
param tags = {
  Environment: 'Test'
  TestCase: 'Premium'
}
