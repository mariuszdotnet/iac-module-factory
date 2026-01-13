# Azure Web App / Function App Module (AVM Wrapper)

This module deploys an Azure Web App or Function App by wrapping the [Azure Verified Module (AVM)](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/web/site).

## Description

This is a wrapper module around the official Azure Verified Module for Web/Site. It provides organization-specific defaults and simplified parameters while leveraging the full capabilities of the AVM module.

**AVM Reference:** `br/public:avm/res/web/site:0.21.0`

## Resource Types

| Resource Type | API Version |
|---------------|-------------|
| `Microsoft.Web/sites` | 2024-04-01 |
| `Microsoft.Web/sites/slots` | 2024-04-01 |
| `Microsoft.Web/sites/config` | 2024-04-01 |
| `Microsoft.Web/sites/hybridconnectionnamespaces/relays` | 2024-04-01 |
| `Microsoft.Authorization/locks` | 2020-05-01 |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview |
| `Microsoft.Network/privateEndpoints` | 2023-11-01 |

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Name of the site (2-60 chars) |
| `location` | string | Location for all resources |
| `kind` | string | Type of site to deploy (app, functionapp, etc.) |
| `serverFarmResourceId` | string | Resource ID of the App Service Plan |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tags` | object | `{}` | Tags of the resource |
| `clientAffinityEnabled` | bool | `true` | Enable client affinity |
| `clientCertEnabled` | bool | `false` | Enable client certificates |
| `clientCertMode` | string | `'Optional'` | Client certificate mode |
| `clientCertExclusionPaths` | string | `''` | Paths to exclude for client certs |
| `hostNameSslStates` | array | `[]` | Hostname SSL states |
| `hyperV` | bool | `false` | Enable Hyper-V sandbox |
| `redundancyMode` | string | `'None'` | Redundancy mode |
| `sslLtrEnabled` | bool | `true` | Allow SSL cipher suite selection |
| `httpsOnly` | bool | `true` | Accept only HTTPS requests |
| `storageAccountUseIdentityAuthentication` | bool | `false` | Use managed identity for storage |
| `siteConfig` | object | `{}` | Site configuration object |
| `appSettingsKeyValuePairs` | object | `{}` | App settings key-value pairs |
| `authSettingV2Configuration` | object | `{}` | Authentication settings |
| `managedIdentities` | object | `{}` | Managed identity configuration |
| `virtualNetworkSubnetId` | string | `''` | VNet subnet ID for integration |
| `vnetContentShareEnabled` | bool | `false` | Enable content access over VNet |
| `vnetImagePullEnabled` | bool | `false` | Enable image pull over VNet |
| `vnetRouteAllEnabled` | bool | `false` | Route all traffic through VNet |
| `storageAccountResourceId` | string | `''` | Storage account for functions |
| `storageAccountRequired` | bool | `false` | Require customer storage account |
| `functionsExtensionVersion` | string | `'~4'` | Functions runtime version |
| `functionsWorkerRuntime` | string | `''` | Functions worker runtime |
| `dailyMemoryTimeQuota` | int | `0` | Daily memory time quota |
| `publicNetworkAccess` | string | `'Enabled'` | Public network access |
| `slots` | array | `[]` | Deployment slots configuration |
| `hybridConnectionRelays` | array | `[]` | Hybrid connection relays |
| `privateEndpoints` | array | `[]` | Private endpoints configuration |
| `diagnosticSettings` | array | `[]` | Diagnostic settings |
| `basicPublishingCredentialsPolicies` | array | `[]` | Publishing credential policies |
| `roleAssignments` | array | `[]` | Role assignments |
| `lock` | object | `{}` | Resource lock settings |
| `appInsightResourceId` | string | `''` | Application Insights resource ID |
| `keyVaultAccessIdentityResourceId` | string | `''` | Key Vault access identity |
| `enableTelemetry` | bool | `true` | Enable AVM telemetry |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | The resource ID of the site |
| `name` | string | The name of the site |
| `resourceGroupName` | string | The resource group name |
| `location` | string | The deployed location |
| `defaultHostname` | string | The default hostname of the site |
| `systemAssignedMIPrincipalId` | string | System assigned identity principal ID |
| `slots` | array | The deployed slots |

## Usage Examples

### Basic Web App Deployment

```bicep
module webApp 'modules/Microsoft.Web/sites/web-app/main.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: 'app-mywebapp-dev'
    location: 'eastus'
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    tags: {
      Environment: 'Development'
    }
  }
}
```

### Linux Web App with VNet Integration

```bicep
module webApp 'modules/Microsoft.Web/sites/web-app/main.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: 'app-mywebapp-prod'
    location: 'eastus'
    kind: 'app,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    virtualNetworkSubnetId: '/subscriptions/.../subnets/webapp-subnet'
    vnetRouteAllEnabled: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}
```

### Function App with Application Insights

```bicep
module functionApp 'modules/Microsoft.Web/sites/web-app/main.bicep' = {
  name: 'functionAppDeployment'
  params: {
    name: 'func-myapp-prod'
    location: 'eastus'
    kind: 'functionapp'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    storageAccountResourceId: storageAccount.outputs.resourceId
    functionsExtensionVersion: '~4'
    functionsWorkerRuntime: 'dotnet-isolated'
    appInsightResourceId: appInsights.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
  }
}
```

### WAF-Aligned Production Deployment

```bicep
module webApp 'modules/Microsoft.Web/sites/web-app/main.bicep' = {
  name: 'webAppDeployment'
  params: {
    name: 'app-mywebapp-prod'
    location: 'eastus'
    kind: 'app,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    httpsOnly: true
    virtualNetworkSubnetId: subnetResourceId
    vnetRouteAllEnabled: true
    publicNetworkAccess: 'Disabled'
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
    }
    managedIdentities: {
      systemAssigned: true
    }
    diagnosticSettings: [
      {
        workspaceResourceId: '/subscriptions/.../workspaces/law-central'
        logs: [
          { categoryGroup: 'allLogs', enabled: true }
        ]
        metrics: [
          { category: 'AllMetrics', enabled: true }
        ]
      }
    ]
    privateEndpoints: [
      {
        subnetResourceId: privateEndpointSubnetId
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: privateDnsZoneId
            }
          ]
        }
      }
    ]
    lock: {
      kind: 'CanNotDelete'
      name: 'webapp-lock'
    }
    tags: {
      Environment: 'Production'
      Compliance: 'WAF-Aligned'
    }
  }
}
```

## Kind Reference

| Kind | Description |
|------|-------------|
| `app` | Windows Web App |
| `app,linux` | Linux Web App |
| `app,linux,container` | Linux Container Web App |
| `app,container,windows` | Windows Container Web App |
| `functionapp` | Windows Function App |
| `functionapp,linux` | Linux Function App |
| `functionapp,linux,container` | Linux Container Function App |
| `functionapp,workflowapp` | Logic App Standard (Windows) |
| `functionapp,workflowapp,linux` | Logic App Standard (Linux) |
| `functionapp,linux,container,azurecontainerapps` | Function App on Container Apps |

## Cross-referenced Modules

| Reference | Type |
|-----------|------|
| `br/public:avm/res/web/site:0.21.0` | Azure Verified Module |
| `br/public:avm/utl/types/avm-common-types:0.6.0` | Common Types |

## Prerequisites

- Azure subscription
- Resource group
- App Service Plan (matching the kind - Linux plan for Linux apps)
- Storage account (for Function Apps)
- Appropriate permissions to create Web Apps

## Related Resources

- [Azure App Service Documentation](https://learn.microsoft.com/azure/app-service/)
- [Azure Functions Documentation](https://learn.microsoft.com/azure/azure-functions/)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [AVM Web/Site Module](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/web/site)
