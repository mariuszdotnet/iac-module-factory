# IaC Module Factory

A repository of Azure Infrastructure as Code (IaC) Bicep modules that wrap [Azure Verified Modules (AVM)](https://aka.ms/avm) with organization-specific defaults and best practices.

## Overview

This factory provides production-ready Bicep modules for deploying Azure resources. Each module:

- **Wraps Azure Verified Modules (AVM)** - Leverages Microsoft's official, well-tested modules as the foundation
- **Secure by Default** - Parameters default to secure configurations (e.g., Premium SKUs, zone redundancy enabled)
- **WAF-Aligned** - Includes examples following Azure Well-Architected Framework principles
- **Fully Tested** - Comprehensive test coverage with multiple parameter configurations

## Available Modules

| Module | Resource Provider | Description |
|--------|-------------------|-------------|
| [Container Registry](./modules/Microsoft.ContainerRegistry/registries/container-registry) | `Microsoft.ContainerRegistry/registries` | Azure Container Registry with Premium defaults |
| [App Service Plan](./modules/Microsoft.Web/serverfarms/app-service-plan) | `Microsoft.Web/serverfarms` | Azure App Service Plan with zone redundancy |

## Module Structure

All modules follow a standardized structure:

```
modules/
└── {ResourceProvider}/           # e.g., Microsoft.ContainerRegistry
    └── {ResourceType}/           # e.g., registries
        └── {ModuleName}/         # e.g., container-registry
            ├── main.bicep        # Primary module definition
            ├── metadata.json     # Module metadata and versioning
            ├── README.md         # Documentation
            ├── examples/         # Usage examples
            │   ├── basic/
            │   ├── waf-aligned/
            │   └── {scenario}/
            └── tests/
                ├── main.test.bicep
                └── parameters/
```

## Usage

### Reference a Module

```bicep
module acr 'modules/Microsoft.ContainerRegistry/registries/container-registry/main.bicep' = {
  name: 'container-registry-deployment'
  params: {
    name: 'mycontainerregistry'
    location: 'eastus'
    tags: {
      Environment: 'Production'
    }
  }
}
```

### Quick Start Examples

#### Container Registry (Premium with Zone Redundancy)

```bicep
module acr 'modules/Microsoft.ContainerRegistry/registries/container-registry/main.bicep' = {
  name: 'acr-deployment'
  params: {
    name: 'myacr${uniqueString(resourceGroup().id)}'
    location: resourceGroup().location
    acrSku: 'Premium'
    zoneRedundancy: 'Enabled'
    retentionPolicyStatus: 'enabled'
    retentionPolicyDays: 30
  }
}
```

#### App Service Plan (Zone Redundant)

```bicep
module asp 'modules/Microsoft.Web/serverfarms/app-service-plan/main.bicep' = {
  name: 'asp-deployment'
  params: {
    name: 'my-app-service-plan'
    location: resourceGroup().location
    skuName: 'P1v3'
    skuCapacity: 3
    zoneRedundant: true
  }
}
```

## Key Principles

1. **AVM Wrapper Pattern** - All modules wrap Azure Verified Modules with organization-specific defaults
2. **Secure by Default** - Security-conscious default values for all parameters
3. **WAF Alignment** - Examples demonstrating Well-Architected Framework best practices
4. **Testability** - Every module includes comprehensive test coverage
5. **Documentation** - Complete parameter documentation and usage examples

## Creating New Modules

Use the `.template` module as a starting point:

```bash
cp -r modules/.template modules/{ResourceProvider}/{resourceType}/{module-name}
```

See the [GitHub Copilot Agent](.github/agents/iac-bicep.agent.md) for detailed guidance on creating modules.

## Contributing

1. Follow the standardized folder structure
2. Wrap Azure Verified Modules (AVM) as the base
3. Include examples for basic, WAF-aligned, and production scenarios
4. Add comprehensive tests with multiple parameter configurations
5. Document all parameters and outputs in README.md

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
