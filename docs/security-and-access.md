# Security and access model

## Identities

- **Azure-hosted automation:** use a managed identity.
- **External AAP or CI:** use workload identity federation (OIDC) and short-lived tokens.
- **AWS discovery:** use an IAM role with read-only EC2 inventory permissions; use Systems Manager or an approved bootstrap path for Arc installation.
- **GCP discovery:** use a service account or workload identity with Compute Viewer; use an approved OS management or bootstrap path for Arc installation.
- **Human administration:** require MFA and use privileged activation for elevated roles.

No VM password, SSH private key, WinRM secret, or cloud access key belongs in this repository.

The Azure pilot playbooks use the already-authenticated Azure CLI context. Set `AZURE_SUBSCRIPTION_ID` to the subscription containing the workspace and DCRs. Grant discovery read access on the subscriptions in scope, and grant the enrollment identity only the VM identity/extension and DCR-association rights required at the pilot VM scopes. Review effective permissions in a non-production subscription before rollout.

## Role separation

| Role | Scope | Typical rights |
|---|---|---|
| Platform deployer | Monitoring resource group | Deploy workspace, DCRs, Workbook, alerts, and Action Group |
| Fleet discovery | Management group / subscriptions | Read Resource Graph inventory |
| Enrollment automation | Target VM scopes and monitoring DCRs | Read machines; enable system-assigned identity; install/repair AMA; create DCR associations |
| Arc bootstrap operator | Approved AWS/GCP scope and Arc landing resource group | Discover, install Connected Machine agent, register server |
| Monitoring viewer | Workspace and Workbook | Read logs, alerts, and dashboards |
| Monitoring operator | Monitoring resource group | Acknowledge, investigate, and manage alert actions |
| Diagnostic operator | Explicit exception scope | Run approved diagnostics; kept separate from normal monitoring |

## Network path

Normal operation is outbound. Do not open inbound SSH or WinRM from Azure for routine monitoring. Allow only the documented Azure Arc and Azure Monitor endpoints through the egress controls. Where required, use Azure Monitor Private Link Scope for Azure-side ingestion/query design, but test how non-Azure machines reach the required endpoints before enforcing private-only paths.

## Guardrails

- Exclusion is explicit: `disk-monitoring=disabled`, with owner and expiry recorded.
- Tag every resource with environment, application owner, business service, and cloud origin.
- Log policy changes and Arc onboarding actions.
- Keep Action Group webhooks and ITSM credentials in a secret store.
- Alert on missing telemetry; an absent signal is an operating condition, not a healthy disk.
