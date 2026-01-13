using '../../main.bicep'

param name = 'acrdefaulttest001'
param location = 'eastus'
param tags = {
  Environment: 'Test'
  Purpose: 'DefaultConfiguration'
}
