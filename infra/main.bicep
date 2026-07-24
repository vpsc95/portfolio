targetScope = 'subscription'

@description('Short environment name used for deterministic Azure resource naming.')
@minLength(1)
@maxLength(24)
param environmentName string

@description('Azure region for the resource group and Static Web App.')
param location string

var resourceSuffix = take(uniqueString(subscription().id, environmentName, location), 6)
var resourceGroupName = 'rg-vivek-portfolio-${environmentName}'
var baseTags = {
  'azd-env-name': environmentName
  workload: 'vivek-portfolio'
  environment: environmentName
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: baseTags
}

module staticWebApp 'br/public:avm/res/web/static-site:0.3.0' = {
  name: 'static-web-app'
  scope: resourceGroup
  params: {
    name: 'stapp-vivek-portfolio-${resourceSuffix}'
    location: location
    sku: 'Free'
    tags: union(baseTags, {
      'azd-service-name': 'web'
    })
  }
}

output AZURE_RESOURCE_GROUP string = resourceGroup.name
output SERVICE_WEB_RESOURCE_NAME string = staticWebApp.outputs.name
output WEB_URL string = 'https://${staticWebApp.outputs.defaultHostname}'
