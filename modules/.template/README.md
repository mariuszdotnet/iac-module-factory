# Module Name

Brief description of what this module deploys.

## Description

Detailed description of the module, its purpose, and what resources it creates.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | Yes | - | Name of the resource |
| `location` | string | Yes | - | Location for all resources |
| `tags` | object | No | `{}` | Tags of the resource |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | The resource ID of the deployed resource |
| `name` | string | The name of the deployed resource |

## Usage

```bicep
module example 'modules/<RP>/<resourceType>/<moduleName>/main.bicep' = {
  name: 'exampleDeployment'
  params: {
    name: 'example-resource'
    location: 'eastus'
    tags: {
      Environment: 'Production'
    }
  }
}
```

## Security Considerations

- List security-related defaults and considerations
- Document any compliance requirements
- Note any sensitive parameters

## Dependencies

List any dependencies or prerequisites for this module.

## Known Limitations

Document any known limitations or constraints.
