param location string
param workspaceResourceId string
param workspaceCustomerId string
param actionGroupResourceId string
param samplingFrequencyInSeconds int = 300
param warningQuery string
param criticalQuery string
param staleQuery string

resource windowsDcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-disk-windows'
  location: location
  kind: 'Windows'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'disk-windows'
          streams: [ 'Microsoft-Perf' ]
          samplingFrequencyInSeconds: samplingFrequencyInSeconds
          counterSpecifiers: [
            '\\LogicalDisk(*)\\% Free Space'
            '\\LogicalDisk(*)\\Free Megabytes'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'central-law'
          workspaceResourceId: workspaceResourceId
          workspaceId: workspaceCustomerId
        }
      ]
    }
    dataFlows: [
      { streams: [ 'Microsoft-Perf' ], destinations: [ 'central-law' ] }
    ]
  }
}

resource linuxDcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'dcr-disk-linux'
  location: location
  kind: 'Linux'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'disk-linux'
          streams: [ 'Microsoft-Perf' ]
          samplingFrequencyInSeconds: samplingFrequencyInSeconds
          counterSpecifiers: [
            '\\Logical Disk(*)\\% Free Space'
            '\\Logical Disk(*)\\Free Megabytes'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'central-law'
          workspaceResourceId: workspaceResourceId
          workspaceId: workspaceCustomerId
        }
      ]
    }
    dataFlows: [
      { streams: [ 'Microsoft-Perf' ], destinations: [ 'central-law' ] }
    ]
  }
}

resource warningAlert 'Microsoft.Insights/scheduledQueryRules@2023-12-01' = {
  name: 'alert-disk-warning'
  location: location
  kind: 'LogAlert'
  properties: {
    displayName: 'Disk space warning'
    description: 'A monitored filesystem has less than 20% or 10 GiB free, excluding critical disks.'
    enabled: true
    severity: 2
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [ workspaceResourceId ]
    autoMitigate: true
    skipQueryValidation: true
    criteria: {
      allOf: [
        {
          query: warningQuery
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          dimensions: [
            { name: '_ResourceId', operator: 'Include', values: [ '*' ] }
            { name: 'Disk', operator: 'Include', values: [ '*' ] }
          ]
          failingPeriods: {
            numberOfEvaluationPeriods: 2
            minFailingPeriodsToAlert: 2
          }
        }
      ]
    }
    actions: {
      actionGroups: [ actionGroupResourceId ]
    }
  }
}

resource criticalAlert 'Microsoft.Insights/scheduledQueryRules@2023-12-01' = {
  name: 'alert-disk-critical'
  location: location
  kind: 'LogAlert'
  properties: {
    displayName: 'Disk space critical'
    description: 'A monitored filesystem has less than 10% or 5 GiB free.'
    enabled: true
    severity: 0
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [ workspaceResourceId ]
    autoMitigate: true
    skipQueryValidation: true
    criteria: {
      allOf: [
        {
          query: criticalQuery
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          dimensions: [
            { name: '_ResourceId', operator: 'Include', values: [ '*' ] }
            { name: 'Disk', operator: 'Include', values: [ '*' ] }
          ]
          failingPeriods: {
            numberOfEvaluationPeriods: 2
            minFailingPeriodsToAlert: 2
          }
        }
      ]
    }
    actions: {
      actionGroups: [ actionGroupResourceId ]
    }
  }
}

resource staleAlert 'Microsoft.Insights/scheduledQueryRules@2023-12-01' = {
  name: 'alert-disk-telemetry-stale'
  location: location
  kind: 'LogAlert'
  properties: {
    displayName: 'Disk telemetry stale'
    description: 'A machine with recent disk telemetry has not reported a disk sample for 15 minutes.'
    enabled: true
    severity: 2
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [ workspaceResourceId ]
    autoMitigate: true
    skipQueryValidation: true
    criteria: {
      allOf: [
        {
          query: staleQuery
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 0
          dimensions: [
            { name: '_ResourceId', operator: 'Include', values: [ '*' ] }
          ]
          failingPeriods: {
            numberOfEvaluationPeriods: 2
            minFailingPeriodsToAlert: 2
          }
        }
      ]
    }
    actions: {
      actionGroups: [ actionGroupResourceId ]
    }
  }
}

output windowsDcrResourceId string = windowsDcr.id
output linuxDcrResourceId string = linuxDcr.id
output warningAlertResourceId string = warningAlert.id
output criticalAlertResourceId string = criticalAlert.id
output staleAlertResourceId string = staleAlert.id
