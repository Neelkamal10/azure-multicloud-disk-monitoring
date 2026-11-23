# Cost and effort comparison

## Pricing basis

The model uses the public Azure Monitor Analytics Logs price of **USD 2.30/GB** and the documented first **5 GB/month per billing account free** for the tier. Public prices are estimates, not a signed quote; agreement, region, date, and currency can change the result. The final budget must be rebuilt in the signed-in Azure Pricing Calculator and checked with a pilot's `_BilledSize`.

## Engineering assumptions

- 100, 150, and 200 machines across 10 Azure subscriptions
- four monitored filesystems per machine
- two records per filesystem per sample (`% Free Space` and `Free Megabytes`)
- 300-second interval, 30-day month
- 500 billable bytes per `Perf` record (planning estimate, not a Microsoft guarantee)
- Analytics Logs price: USD 2.30/GB
- first 5 GB/month available to this billing account
- alert rules, notifications, cross-cloud egress, Arc-connected services, and labor excluded from the ingestion line

| Machines | Records/month | Estimated ingestion | Modeled ingestion charge |
|---:|---:|---:|---:|
| 100 | 6,912,000 | 3.456 GB | USD 0.00 |
| 150 | 10,368,000 | 5.184 GB | USD 0.42 |
| 200 | 13,824,000 | 6.912 GB | USD 4.40 |

A one-minute interval creates five times as many samples. This is why the design begins at five minutes and changes frequency only when the operating value justifies the cost and noise.

## Effort

| Area | Ansible-assisted Azure | Azure-native | Multicloud extension |
|---|---:|---:|---:|
| Initial implementation | 36-56 hours | 30-46 hours | add 40-72 hours for Arc bootstrap, cloud IAM, egress, and pilot |
| Ongoing operation | 4-8 hours/month | 2-4 hours/month | add 4-10 hours/month, depending on onboarding churn and agent reachability |
| Controller dependency | For onboarding/repair only | No | For cloud discovery/bootstrap if selected |
| Continuous data path | AMA to Azure Monitor | AMA to Azure Monitor | AMA on Arc-enabled servers to Azure Monitor |

These are planning ranges, not invoices. Existing AAP capacity is treated as sunk cost; licensing or additional workers must be added if that assumption is wrong.
