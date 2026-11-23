targetScope = 'resourceGroup'

@description('Deployment region for monitoring resources.')
param location string = resourceGroup().location
param workspaceName string = 'law-disk-monitoring-prod'
param actionGroupName string = 'ag-disk-monitoring-ops'
param operationsEmail string
param retentionDays int = 31
param samplingFrequencyInSeconds int = 300

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: retentionDays
    features: { enableLogAccessUsingOnlyResourcePermissions: true }
  }
}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'
  properties: {
    groupShortName: 'DiskOps'
    enabled: true
    emailReceivers: [
      {
        name: 'operations'
        emailAddress: operationsEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid(resourceGroup().id, workspace.name, 'disk-monitoring-workbook')
  location: location
  kind: 'shared'
  properties: {
    category: 'workbook'
    displayName: 'Disk monitoring fleet'
    serializedData: loadTextContent('../workbooks/disk-overview.json')
    sourceId: workspace.id
    version: '1.0'
  }
}

module rules 'monitoring.bicep' = {
  name: 'disk-data-collection-rules'
  params: {
    location: location
    workspaceResourceId: workspace.id
    workspaceCustomerId: workspace.properties.customerId
    actionGroupResourceId: actionGroup.id
    samplingFrequencyInSeconds: samplingFrequencyInSeconds
    warningQuery: loadTextContent('../kql/alert-warning.kql')
    criticalQuery: loadTextContent('../kql/alert-critical.kql')
    staleQuery: loadTextContent('../kql/stale-telemetry.kql')
  }
}

output workspaceResourceId string = workspace.id
output windowsDcrResourceId string = rules.outputs.windowsDcrResourceId
output linuxDcrResourceId string = rules.outputs.linuxDcrResourceId
output actionGroupResourceId string = actionGroup.id
output workbookResourceId string = workbook.id
output warningAlertResourceId string = rules.outputs.warningAlertResourceId
output criticalAlertResourceId string = rules.outputs.criticalAlertResourceId
output staleAlertResourceId string = rules.outputs.staleAlertResourceId
