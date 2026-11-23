# Operations runbook

## Daily checks

1. Review critical and warning alerts by application owner.
2. Review stale telemetry separately from capacity alerts.
3. Compare eligible fleet inventory with reporting resource IDs.
4. Confirm new subscriptions/accounts/projects are represented in the onboarding view.
5. Check failed Policy remediation and failed Arc/AMA extension states.

## Triage order

1. **Confirm the signal:** check the latest two samples and sample age.
2. **Confirm the object:** map resource ID, cloud origin, VM, and mount point.
3. **Estimate time to exhaustion:** use the trend query rather than assuming linear growth is harmless.
4. **Engage the owner:** identify safe cleanup, log rotation, retention, or disk expansion.
5. **Record the action:** owner, expected completion, and any temporary suppression.
6. **Close only after recovery:** require two healthy evaluation windows.

## Stale telemetry

A stale result can mean a stopped/deallocated VM, agent failure, DCR association failure, blocked egress, unsupported counter, or ingestion delay. Check power state first, then AMA/Arc extension state, DCR association, and network reachability. Do not send a disk-capacity escalation until the telemetry path is understood.

## Change and release

Pilot changes on a mixed Windows/Linux ring. Record query results, ingestion volume, alert count, and false positives for at least one business cycle. Promote the DCR, query, and alert changes together so the stored data and evaluation logic remain compatible.
