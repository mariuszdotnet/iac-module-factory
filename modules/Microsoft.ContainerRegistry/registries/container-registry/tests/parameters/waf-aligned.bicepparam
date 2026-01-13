using '../../main.bicep'

// WAF-aligned configuration following Azure Well-Architected Framework best practices
param name = 'acrwaftest001'
param location = 'eastus'
param acrSku = 'Premium'

// Security
param acrAdminUserEnabled = false
param trustPolicyStatus = 'enabled'
param exportPolicyStatus = 'disabled'
param azureADAuthenticationAsArmPolicyStatus = 'enabled'

// Reliability
param zoneRedundancy = 'Enabled'
param retentionPolicyStatus = 'enabled'
param retentionPolicyDays = 30

// Identity
param managedIdentities = {
  systemAssigned: true
}

param tags = {
  Environment: 'Test'
  Purpose: 'WAFAlignedConfiguration'
}
