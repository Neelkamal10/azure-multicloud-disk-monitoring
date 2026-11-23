# Validation plan

## Automated repository checks

- `pytest -q` verifies the cost model and paginated Resource Graph discovery behavior.
- Ansible playbooks are syntax-checked.
- GitHub Actions builds `infra/main.bicep` with Bicep CLI.

These checks do not prove tenant permissions, KQL behavior, counter availability, alert delivery, or Azure deployment.

## Live pilot exit criteria

| Test | Expected result |
|---|---|
| Azure Windows VM | AMA healthy, Windows DCR associated, both disk counters appear in `Perf` |
| Azure Linux VM | AMA healthy, Linux DCR associated, filesystem counters appear with expected names |
| AWS Windows/Linux | Arc resource connected, AMA installed, correct DCR applied, source-cloud tags retained |
| GCP Windows/Linux | Same as AWS, using the approved GCP bootstrap path |
| Warning threshold | Sustained test disk condition creates one actionable warning |
| Critical threshold | Sustained critical condition creates the critical alert and Action Group notification |
| Recovery | Alert resolves after two healthy windows |
| Stale telemetry | Recently reporting but now quiet agents are identified; compare with eligible inventory separately to find machines that have never reported |
| Scale | Pilot extrapolation remains within query latency, alert dimension, and budget limits |
| Security | No inbound management port is required for steady-state collection |

## Evidence to retain

Save the deployment command, Policy compliance view, DCR associations, representative `Perf` rows, KQL results, alert history, Action Group receipt, Workbook screenshot, `_BilledSize` query, and rollback result. Redact subscription IDs and endpoints before public publication.
