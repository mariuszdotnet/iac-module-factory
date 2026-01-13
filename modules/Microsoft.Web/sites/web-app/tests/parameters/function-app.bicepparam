using '../../main.bicep'

param name = 'func-test'
param location = 'eastus'
param kind = 'functionapp,linux'
param serverFarmResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Web/serverfarms/asp-test'
param storageAccountResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Storage/storageAccounts/sttest'
param functionsExtensionVersion = '~4'
param functionsWorkerRuntime = 'dotnet-isolated'
param httpsOnly = true
param managedIdentities = {
  systemAssigned: true
}
param siteConfig = {
  linuxFxVersion: 'DOTNET-ISOLATED|8.0'
  alwaysOn: true
  ftpsState: 'Disabled'
  minTlsVersion: '1.2'
}
param tags = {
  Environment: 'Test'
  TestCase: 'FunctionApp'
}
