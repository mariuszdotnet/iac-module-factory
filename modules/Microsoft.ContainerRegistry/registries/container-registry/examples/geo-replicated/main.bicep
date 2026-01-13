// ============================================================================
// Example: Geo-Replicated Container Registry
// ============================================================================

targetScope = 'resourceGroup'

@description('Primary location for the registry.')
param location string = resourceGroup().location

@description('Environment name.')
param environment string = 'prod'

@description('Secondary regions for geo-replication.')
param replicationLocations array = [
  'westus2'
  'westeurope'
]

// Deploy a geo-replicated container registry
module acr '../../main.bicep' = {
  name: 'acr-georeplicated-deployment'
  params: {
    name: 'acr${environment}${uniqueString(resourceGroup().id)}'
    location: location
    
    // Premium required for geo-replication
    acrSku: 'Premium'
    
    // Enable zone redundancy in primary region
    zoneRedundancy: 'Enabled'
    
    // Configure replications
    replications: [for replicationLocation in replicationLocations: {
      name: replicationLocation
      location: replicationLocation
      zoneRedundancy: 'Enabled'
      regionEndpointEnabled: true
    }]
    
    // Security settings
    acrAdminUserEnabled: false
    retentionPolicyStatus: 'enabled'
    retentionPolicyDays: 30
    
    tags: {
      Environment: environment
      Purpose: 'Global Container Registry'
      Replication: 'Geo-Replicated'
    }
  }
}

output acrId string = acr.outputs.resourceId
output acrName string = acr.outputs.name
output loginServer string = acr.outputs.loginServer
