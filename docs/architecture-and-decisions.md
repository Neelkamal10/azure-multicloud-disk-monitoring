# Architecture and design decisions

## Scope

The assignment asks for one provider, so Azure is the implemented baseline. The design also shows how the same monitoring plane can accept guest telemetry from AWS EC2 and Google Compute Engine through Azure Arc-enabled Servers.

## Decision summary

| Decision | Choice | Reason |
|---|---|---|
| Primary monitoring plane | Azure Monitor and Log Analytics | Central query, visualization, alerts, and policy integration |
| Guest collector | Azure Monitor Agent | Keeps collection off the Ansible controller |
| Collection policy | Separate Windows and Linux DCRs | Avoids mixing counters across operating systems |
| Azure onboarding | Ansible for the pilot; management-group Azure Policy for steady state | The playbook supports auditable enrollment; Policy provides desired-state scale-out |
| AWS/GCP onboarding | Azure Arc bootstrap, automated with Ansible | Gives non-Azure machines an Azure resource identity and extension framework |
| Stable machine key | Full Azure or Arc resource ID | Names can collide across subscriptions, accounts, and projects |
| Alert thresholds | Warning <20% or <10 GiB; critical <10% or <5 GiB | Percentage and absolute thresholds catch different failure patterns |
| Default interval | 300 seconds | Reduces ingestion and alert noise while remaining useful for capacity risk |
| Data destination | Central workspace, unless residency demands regional workspaces | Simplifies fleet views and operating ownership |

## Data flow

1. Resource discovery identifies eligible machines and records cloud, account/subscription/project, operating system, region, tags, and resource ID.
2. The pilot playbook enables VM system-assigned identity, installs AMA, and associates the OS-specific DCR. For production scale-out, assign Azure Policy at management-group scope. AWS/GCP machines first receive the Azure Connected Machine agent and become Arc-enabled resources.
3. AMA reads the configured logical disk counters and sends them over outbound HTTPS to Azure Monitor.
4. Log Analytics stores logs-based performance counter records in the `Perf` table.
5. KQL normalizes Windows and Linux counter names, groups by resource ID and filesystem, and evaluates warning, critical, and stale-telemetry conditions.
6. Scheduled-query alerts call the Action Group; the Workbook provides the operator view.

## Why Ansible is not the telemetry collector

A controller-side polling design requires network reachability and credentials for every VM, creates a scaling bottleneck, and has a blind spot when the controller is unavailable. In this design, Ansible manages desired state. The agent reports directly to Azure Monitor, so continuous collection survives a controller outage.

## Workspace topology

Start with one workspace owned by the central operations team. Split by region only where residency, latency, ownership, or measured volume justifies it. A multi-workspace design adds cross-workspace query, alert, access, and cost-governance work and should not be the default merely because the fleet spans subscriptions.
