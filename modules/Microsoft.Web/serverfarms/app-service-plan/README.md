# Azure App Service Plan Module (AVM Wrapper)

This module deploys an Azure App Service Plan by wrapping the [Azure Verified Module (AVM)](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/web/serverfarm).

## Description

This is a wrapper module around the official Azure Verified Module for App Service Plan. It provides organization-specific defaults and simplified parameters while leveraging the full capabilities of the AVM module.

**AVM Reference:** `br/public:avm/res/web/serverfarm:0.6.0`

## Resource Types

| Resource Type | API Version |
|---------------|-------------|
| `Microsoft.Web/serverfarms` | 2024-11-01 |
| `Microsoft.Authorization/locks` | 2020-05-01 |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview |

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Name of the App Service Plan (1-40 chars) |
| `location` | string | Location for all resources |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tags` | object | `{}` | Tags of the resource |
| `skuName` | string | `'P1v3'` | SKU name: F1, B1, S1, P1v3, etc. |
| `skuCapacity` | int | `3` | Number of workers (default 3 for zone redundancy) |
| `kind` | string | `'app'` | Kind: app, elastic, functionapp, linux, windows |
| `reserved` | bool | `false` | Set to true for Linux App Service Plans |
| `perSiteScaling` | bool | `false` | Enable per-site scaling |
| `elasticScaleEnabled` | bool | `false` | Enable elastic scale |
| `maximumElasticWorkerCount` | int | `1` | Max workers for elastic scale |
| `targetWorkerCount` | int | `0` | Scaling worker count |
| `targetWorkerSize` | int | `0` | Instance size (0=small, 1=medium, 2=large) |
| `workerTierName` | string | `''` | Target worker tier |
| `zoneRedundant` | bool | `true` (Premium) | Enable zone redundancy |
| `appServiceEnvironmentResourceId` | string | `''` | ASE resource ID |
| `hyperV` | bool | `null` | Enable Hyper-V container support |
| `diagnosticSettings` | array | `[]` | Diagnostic settings configuration |
| `roleAssignments` | array | `[]` | Role assignments |
| `lock` | object | `{}` | Resource lock settings |
| `enableTelemetry` | bool | `true` | Enable AVM telemetry |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | The resource ID of the App Service Plan |
| `name` | string | The name of the App Service Plan |
| `resourceGroupName` | string | The resource group name |
| `location` | string | The deployed location |

## Usage Examples

### Basic Deployment

```bicep
module appServicePlan 'modules/Microsoft.Web/serverfarms/app-service-plan/main.bicep' = {
  name: 'aspDeployment'
  params: {
    name: 'asp-myapp-dev'
    location: 'eastus'
    skuName: 'B1'
    skuCapacity: 1
  }
}
```

### Production Deployment with Zone Redundancy

```bicep
module appServicePlan 'modules/Microsoft.Web/serverfarms/app-service-plan/main.bicep' = {
  name: 'aspDeployment'
  params: {
    name: 'asp-myapp-prod'
    location: 'eastus'
    skuName: 'P1v3'
    skuCapacity: 3
    zoneRedundant: true
    perSiteScaling: true
    tags: {
      Environment: 'Production'
      CostCenter: 'IT'
    }
  }
}
```

### WAF-Aligned Deployment

```bicep
module appServicePlan 'modules/Microsoft.Web/serverfarms/app-service-plan/main.bicep' = {
  name: 'aspDeployment'
  params: {
    name: 'asp-myapp-waf'
    location: 'eastus'
    skuName: 'P1v3'
    skuCapacity: 3
    zoneRedundant: true
    diagnosticSettings: [
      {
        workspaceResourceId: '/subscriptions/.../workspaces/law-central'
        metricCategories: [
          { category: 'AllMetrics' }
        ]
      }
    ]
    lock: {
      kind: 'CanNotDelete'
      name: 'asp-lock'
    }
    tags: {
      Environment: 'Production'
      Compliance: 'WAF-Aligned'
    }
  }
}
```

### Linux App Service Plan

```bicep
module appServicePlan 'modules/Microsoft.Web/serverfarms/app-service-plan/main.bicep' = {
  name: 'aspDeployment'
  params: {
    name: 'asp-linux-app'
    location: 'eastus'
    skuName: 'P1v3'
    kind: 'linux'
    reserved: true
  }
}
```

### Flexible Consumption (Functions)

```bicep
module appServicePlan 'modules/Microsoft.Web/serverfarms/app-service-plan/main.bicep' = {
  name: 'aspDeployment'
  params: {
    name: 'asp-functions-flex'
    location: 'eastus'
    skuName: 'FC1'
    reserved: true
    zoneRedundant: false
  }
}
```

## SKU Reference

| SKU | Tier | Features |
|-----|------|----------|
| F1, D1 | Free/Shared | Dev/test, no SLA |
| B1, B2, B3 | Basic | Dev/test, manual scale |
| S1, S2, S3 | Standard | Production, auto-scale, slots |
| P1v2, P2v2, P3v2 | Premium v2 | Enhanced performance |
| P0v3, P1v3, P2v3, P3v3 | Premium v3 | Zone redundancy, enhanced |
| I1v2, I2v2, I3v2, I4v2, I5v2, I6v2 | Isolated v2 | ASE, network isolation |
| EP1, EP2, EP3 | Elastic Premium | Functions premium |
| FC1 | Flex Consumption | Functions flex consumption |
| Y1 | Consumption | Functions consumption |

## Cross-referenced Modules

| Reference | Type |
|-----------|------|
| `br/public:avm/utl/types/avm-common-types:0.6.0` | Remote reference |

## Prerequisites

- Azure subscription
- Resource group
- Appropriate permissions to create App Service Plans

## Related Resources

- [Azure App Service Plan Documentation](https://learn.microsoft.com/azure/app-service/overview-hosting-plans)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [AVM Serverfarm Module](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/web/serverfarm)
