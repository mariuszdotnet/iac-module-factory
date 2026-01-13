using '../../main.bicep'

param name = 'acrminimaltest001'
param location = 'eastus'
param acrSku = 'Standard'
param tags = {
  Environment: 'Test'
  Purpose: 'MinimalConfiguration'
}
