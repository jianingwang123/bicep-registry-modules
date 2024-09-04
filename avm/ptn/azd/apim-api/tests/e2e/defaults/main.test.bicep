targetScope = 'subscription'

metadata name = 'Using only defaults'
metadata description = 'This instance deploys the module with the minimum set of required parameters.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-apim-api-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

param apimServicename string = '${namePrefix}-as-${serviceShort}001'

param apiName string = '${namePrefix}-an-${serviceShort}001'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'aapmin'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    serverFarmName: 'dep-${namePrefix}-sf-${serviceShort}'
    siteName: 'dep-${namePrefix}-st-${serviceShort}'
    apimServicename: apimServicename
    publisherName: 'dep-${namePrefix}-az-amorg-x-001'
    applicationInsightsName: 'dep-${namePrefix}-ai-${serviceShort}'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-law-${serviceShort}'
  }
}

// ============== //
// Test Execution //
// ============== //

module testDeployment '../../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}'
  params: {
    location: resourceLocation
    name: apimServicename
    apiDisplayName: '${namePrefix}-apd-${serviceShort}'
    apiPath: '${namePrefix}-apipath-${serviceShort}'
    webFrontendUrl: nestedDependencies.outputs.siteHostName
    apiBackendUrl: nestedDependencies.outputs.siteHostName
    apiDescription: 'api description'
    apiName: apiName
  }
}
