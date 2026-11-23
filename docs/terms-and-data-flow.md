# Terms and the disk-data path

| Term | Plain-language meaning | Use in this solution |
|---|---|---|
| OIDC | OpenID Connect federation | Lets an external AAP runner or CI workflow obtain short-lived Azure credentials without a stored client secret |
| AMA | Azure Monitor Agent | Reads guest operating-system telemetry on Azure VMs and Arc-enabled servers |
| DCR | Data Collection Rule | States which counters to collect, the interval, stream, and destination |
| Perf table | Log Analytics table for performance-counter records | Holds logs-based disk samples sent by AMA |
| KQL | Kusto Query Language | Normalizes, aggregates, and evaluates fleet disk data |
| Azure Arc-enabled Server | Azure resource representation of a non-Azure machine | Allows AWS and GCP VMs to use Azure Policy, extensions, AMA, DCRs, tags, and RBAC |
| AAP | Ansible Automation Platform | Runs discovery, onboarding, repair, and validation jobs |

## Worked example

A Windows machine reports `LogicalDisk / % Free Space = 12` for `C:` and `Free Megabytes = 8192`. AMA collected both because the Windows DCR listed them. The DCR sent the records to the workspace. The fleet query joins the latest records for that resource ID and disk. The result is a warning because 12% is below 20% and 8 GiB is below 10 GiB. The critical rule does not fire unless the sustained value is below 10% or 5 GiB.

A Linux machine follows the same path, but it is associated with the Linux DCR and may expose a different object/counter naming convention. That is why the queries normalize names and the pilot must confirm the exact counter set on representative distributions.
