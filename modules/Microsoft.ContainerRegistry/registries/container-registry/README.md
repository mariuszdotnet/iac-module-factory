# Azure Container Registry Module (AVM Wrapper)

This module deploys an Azure Container Registry by wrapping the [Azure Verified Module (AVM)](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/container-registry/registry).

## Description

This is a wrapper module around the official Azure Verified Module for Container Registry. It provides organization-specific defaults and simplified parameters while leveraging the full capabilities of the AVM module.

**AVM Reference:** `br/public:avm/res/container-registry/registry:0.9.3`

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Name of the Container Registry (5-50 chars) |
| `location` | string | Location for all resources |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tags` | object | `{}` | Tags of the resource |
| `acrSku` | string | `'Premium'` | Tier: Basic, Standard, or Premium |
| `acrAdminUserEnabled` | bool | `false` | Enable admin user |
| `anonymousPullEnabled` | bool | `false` | Enable anonymous pull |
| `publicNetworkAccess` | string | `''` | Public network access: Disabled, Enabled |
| `networkRuleBypassOptions` | string | `'AzureServices'` | Allow Azure services bypass |
| `networkRuleSetDefaultAction` | string | `'Deny'` | Default network rule action |
| `networkRuleSetIpRules` | array | `[]` | IP ACL rules (Premium only) |
| `zoneRedundancy` | string | `'Enabled'` | Zone redundancy (Premium only) |
| `trustPolicyStatus` | string | `'disabled'` | Content trust policy |
| `quarantinePolicyStatus` | string | `'disabled'` | Quarantine policy |
| `retentionPolicyStatus` | string | `'enabled'` | Retention policy |
| `retentionPolicyDays` | int | `15` | Retention days for untagged manifests |
| `exportPolicyStatus` | string | `'disabled'` | Export policy |
| `softDeletePolicyStatus` | string | `'disabled'` | Soft delete policy |
| `softDeletePolicyDays` | int | `7` | Soft delete retention days |
| `dataEndpointEnabled` | bool | `false` | Data endpoint per region |
| `azureADAuthenticationAsArmPolicyStatus` | string | `'enabled'` | Azure AD ARM auth policy |
| `managedIdentities` | object | `{}` | Managed identity configuration |
| `customerManagedKey` | object | `{}` | CMK encryption configuration |
| `replications` | array | `[]` | Geo-replications (Premium only) |
| `webhooks` | array | `[]` | Webhooks configuration |
| `cacheRules` | array | `[]` | Cache rules for artifact caching |
| `credentialSets` | array | `[]` | Credential sets for upstream auth |
| `scopeMaps` | array | `[]` | Scope maps for token permissions |
| `privateEndpoints` | array | `[]` | Private endpoint configurations |
| `diagnosticSettings` | array | `[]` | Diagnostic settings |
| `roleAssignments` | array | `[]` | Role assignments |
| `lock` | object | `{}` | Resource lock settings |
| `enableTelemetry` | bool | `true` | Enable AVM telemetry |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | The resource ID of the Container Registry |
| `name` | string | The name of the Container Registry |
| `loginServer` | string | The login server URL |
| `resourceGroupName` | string | The resource group name |
| `location` | string | The deployed location |
| `systemAssignedMIPrincipalId` | string | System assigned identity principal ID |
| `privateEndpoints` | array | Private endpoint details |
| `credentialSetsResourceIds` | array | Credential set resource IDs |
| `credentialSetsSystemAssignedMIPrincipalIds` | array | Credential set identity principal IDs |

## Usage Examples

### Basic Deployment

```bicep
module acr 'modules/Microsoft.ContainerRegistry/registries/container-registry/main.bicep' = {
  name: 'acrDeployment'
  params: {
    name: 'mycontainerregistry'
    location: 'eastus'
    acrSku: 'Standard'
  }
}
```

### Production Deployment with Private Endpoints

```bicep
module acr 'modules/Microsoft.ContainerRegistry/registries/container-registry/main.bicep' = {
  name: 'acrDeployment'
  params: {
    name: 'mycontainerregistry'
    location: 'eastus'
    acrSku: 'Premium'
    zoneRedundancy: 'Enabled'
    trustPolicyStatus: 'enabled'
    retentionPolicyStatus: 'enabled'
    retentionPolicyDays: 30
    privateEndpoints: [
      {
        subnetResourceId: '/subscriptions/.../subnets/private-endpoints'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '/subscriptions/.../privateDnsZones/privatelink.azurecr.io'
            }
          ]
        }
      }
    ]
    diagnosticSettings: [
      {
        workspaceResourceId: '/subscriptions/.../workspaces/my-law'
      }
    ]
    tags: {
      Environment: 'Production'
    }
  }
}
```

### With Geo-Replication

```bicep
module acr 'modules/Microsoft.ContainerRegistry/registries/container-registry/main.bicep' = {
  name: 'acrDeployment'
  params: {
    name: 'mycontainerregistry'
    location: 'eastus'
    acrSku: 'Premium'
    replications: [
      {
        name: 'westus2'
        location: 'westus2'
        zoneRedundancy: 'Enabled'
      }
      {
        name: 'westeurope'
        location: 'westeurope'
      }
    ]
  }
}
```

### With Customer-Managed Key Encryption

```bicep
module acr 'modules/Microsoft.ContainerRegistry/registries/container-registry/main.bicep' = {
  name: 'acrDeployment'
  params: {
    name: 'mycontainerregistry'
    location: 'eastus'
    acrSku: 'Premium'
    managedIdentities: {
      userAssignedResourceIds: [
        '/subscriptions/.../userAssignedIdentities/my-identity'
      ]
    }
    customerManagedKey: {
      keyName: 'my-key'
      keyVaultResourceId: '/subscriptions/.../vaults/my-keyvault'
      userAssignedIdentityResourceId: '/subscriptions/.../userAssignedIdentities/my-identity'
    }
  }
}
```

## Security Considerations

- **Admin user disabled by default** - Use RBAC/managed identities instead
- **Premium SKU recommended** - Enables private endpoints, geo-replication, and content trust
- **Network rules default to Deny** - Explicit allow rules required
- **Azure Services bypass enabled** - Allows trusted Azure services access
- **Zone redundancy enabled** - For high availability (Premium only)
- **Export policy disabled** - Prevents image export by default

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Storage | 10 GB | 100 GB | 500 GB |
| Throughput | Low | Medium | High |
| Geo-replication | ❌ | ❌ | ✅ |
| Private endpoints | ❌ | ❌ | ✅ |
| Content trust | ❌ | ❌ | ✅ |
| Zone redundancy | ❌ | ❌ | ✅ |
| Customer-managed keys | ❌ | ❌ | ✅ |
| Dedicated data endpoints | ❌ | ❌ | ✅ |

## AVM Module Reference

This module wraps the Azure Verified Module version **0.9.3**. For full parameter documentation, see:
- [AVM Container Registry Module](https://github.com/Azure/bicep-registry-modules/tree/avm/res/container-registry/registry/0.9.3/avm/res/container-registry/registry/README.md)
- [Bicep Public Registry](https://azure.github.io/bicep-registry-modules/)
