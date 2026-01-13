# Azure Key Vault Module (AVM Wrapper)

This module deploys an Azure Key Vault by wrapping the [Azure Verified Module (AVM)](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/key-vault/vault).

## Description

This is a wrapper module around the official Azure Verified Module for Key Vault. It provides organization-specific defaults and simplified parameters while leveraging the full capabilities of the AVM module.

**AVM Reference:** `br/public:avm/res/key-vault/vault:0.13.3`

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Name of the Key Vault (3-24 chars) |
| `location` | string | Location for all resources |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tags` | object | `{}` | Tags of the resource |
| `sku` | string | `'premium'` | SKU: standard or premium |
| `enableRbacAuthorization` | bool | `true` | Enable RBAC for data plane access |
| `publicNetworkAccess` | string | `'Disabled'` | Public network access setting |
| `enableSoftDelete` | bool | `true` | Enable soft delete feature |
| `softDeleteRetentionInDays` | int | `90` | Soft delete retention (7-90 days) |
| `enablePurgeProtection` | bool | `true` | Enable purge protection |
| `createMode` | string | `'default'` | Create mode: default or recover |
| `networkAcls` | object | `{ bypass: 'AzureServices', defaultAction: 'Deny' }` | Network ACL rules |
| `enableVaultForDeployment` | bool | `false` | Enable for VM deployment |
| `enableVaultForDiskEncryption` | bool | `false` | Enable for disk encryption |
| `enableVaultForTemplateDeployment` | bool | `false` | Enable for ARM template deployment |
| `accessPolicies` | array | `[]` | Access policies configuration |
| `keys` | array | `[]` | Keys to create in the vault |
| `secrets` | array | `[]` | Secrets to create in the vault |
| `privateEndpoints` | array | `[]` | Private endpoint configurations |
| `diagnosticSettings` | array | `[]` | Diagnostic settings |
| `roleAssignments` | array | `[]` | Role assignments |
| `lock` | object | `{}` | Resource lock settings |
| `managedIdentities` | object | `{}` | Managed identity configuration |
| `enableTelemetry` | bool | `true` | Enable AVM telemetry |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | The resource ID of the Key Vault |
| `name` | string | The name of the Key Vault |
| `uri` | string | The URI of the Key Vault |
| `resourceGroupName` | string | The resource group name |
| `location` | string | The deployed location |
| `systemAssignedMIPrincipalId` | string | System assigned identity principal ID |
| `privateEndpoints` | array | Private endpoint details |

## Usage Examples

### Basic Deployment

```bicep
module keyVault 'modules/Microsoft.KeyVault/vaults/key-vault/main.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: 'kv-myapp-dev'
    location: 'eastus'
    sku: 'standard'
    enableRbacAuthorization: true
  }
}
```

### Production Deployment with Private Endpoints

```bicep
module keyVault 'modules/Microsoft.KeyVault/vaults/key-vault/main.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: 'kv-myapp-prod'
    location: 'eastus'
    sku: 'premium'
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Disabled'
    privateEndpoints: [
      {
        subnetResourceId: '/subscriptions/.../subnets/private-endpoints'
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '/subscriptions/.../privateDnsZones/privatelink.vaultcore.azure.net'
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
      CostCenter: 'Platform'
    }
  }
}
```

### With RBAC Role Assignments

```bicep
module keyVault 'modules/Microsoft.KeyVault/vaults/key-vault/main.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: 'kv-myapp-prod'
    location: 'eastus'
    sku: 'premium'
    enableRbacAuthorization: true
    roleAssignments: [
      {
        principalId: '<user-or-service-principal-id>'
        roleDefinitionIdOrName: 'Key Vault Secrets Officer'
        principalType: 'User'
      }
      {
        principalId: '<managed-identity-principal-id>'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
```

### With Managed Identity

```bicep
module keyVault 'modules/Microsoft.KeyVault/vaults/key-vault/main.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: 'kv-myapp-prod'
    location: 'eastus'
    sku: 'premium'
    managedIdentities: {
      systemAssigned: true
    }
  }
}
```

### With Keys and Secrets

```bicep
module keyVault 'modules/Microsoft.KeyVault/vaults/key-vault/main.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: 'kv-myapp-prod'
    location: 'eastus'
    keys: [
      {
        name: 'encryption-key'
        kty: 'RSA'
        keySize: 4096
        keyOps: [
          'encrypt'
          'decrypt'
        ]
      }
    ]
    secrets: [
      {
        name: 'database-connection-string'
        value: '<secure-connection-string>'
        contentType: 'text/plain'
      }
    ]
  }
}
```

### With Access Policies (Legacy)

```bicep
module keyVault 'modules/Microsoft.KeyVault/vaults/key-vault/main.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    name: 'kv-myapp-dev'
    location: 'eastus'
    enableRbacAuthorization: false
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: '<user-object-id>'
        permissions: {
          keys: [
            'get'
            'list'
            'create'
          ]
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
      }
    ]
  }
}
```

## Security Considerations

- **Premium SKU by default** - Provides HSM-backed keys for enhanced security
- **Purge protection enabled** - Prevents permanent deletion during retention period
- **Soft delete enabled** - 90-day retention for accidental deletion recovery
- **RBAC authorization enabled** - Modern, granular access control (recommended over access policies)
- **Public network access disabled** - Forces private endpoint usage in production
- **Network ACLs default to Deny** - Explicit allow rules required
- **Azure Services bypass enabled** - Allows trusted Azure services access

## SKU Comparison

| Feature | Standard | Premium |
|---------|----------|---------|
| Software-protected keys | ✅ | ✅ |
| HSM-backed keys | ❌ | ✅ |
| FIPS 140-2 Level 2 | ✅ | ✅ |
| FIPS 140-2 Level 3 (HSM) | ❌ | ✅ |
| Price | Lower | Higher |

## Best Practices

1. **Use RBAC over Access Policies** - Enable `enableRbacAuthorization: true` for better access management
2. **Enable Purge Protection in Production** - Prevents accidental permanent deletion
3. **Use Private Endpoints** - Disable public access and use private connectivity
4. **Enable Diagnostic Logging** - Send audit logs to Log Analytics
5. **Implement Soft Delete** - Keep default 90-day retention for recovery
6. **Use Premium SKU for Production** - Leverage HSM-backed keys for sensitive data
7. **Network Isolation** - Configure network ACLs to restrict access
8. **Managed Identities** - Use managed identities instead of storing credentials

## AVM Module Reference

This module wraps the Azure Verified Module version **0.13.3**. For full parameter documentation, see:
- [AVM Key Vault Module](https://github.com/Azure/bicep-registry-modules/tree/avm/res/key-vault/vault/0.13.3/avm/res/key-vault/vault/README.md)
- [Bicep Public Registry](https://azure.github.io/bicep-registry-modules/)
