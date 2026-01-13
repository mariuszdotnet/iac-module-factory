// ============================================================================
// Module: <Module Name>
// Description: <Brief description of what this module deploys>
// ============================================================================

@description('Required. Name of the resource.')
param name string

@description('Required. Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

// Add additional parameters here

resource mainResource '<ResourceProvider>/<ResourceType>@<API-Version>' = {
  name: name
  location: location
  tags: tags
  properties: {
    // Add resource properties here
  }
}

// Add additional resources here

@description('The resource ID of the deployed resource.')
output resourceId string = mainResource.id

@description('The name of the deployed resource.')
output name string = mainResource.name

// Add additional outputs here
