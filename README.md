# Scalable Disk Monitoring for Cloud Environments

**Chosen provider:** Microsoft Azure

**Public repository:** https://github.com/Neelkamal10/azure-multicloud-disk-monitoring

## Assignment summary

This submission designs and implements guest filesystem-capacity monitoring for Azure virtual machines across multiple subscriptions. Azure Monitor Agent (AMA) collects disk counters through operating-system-specific Data Collection Rules (DCRs). A central Log Analytics workspace stores the data, while KQL alerts and an Azure Workbook surface disk risks and stale telemetry.

Ansible handles paginated VM discovery and pilot enrollment; it is not used to poll every disk continuously. For production-scale onboarding, the design recommends management-group Azure Policy. That Policy assignment is a separate governance deployment and is not included in the resource-group Bicep template.

## Access and data flow

1. Authenticate automation with an Azure managed identity or workload identity federation; use Azure RBAC for least-privilege discovery and enrollment.
2. Discover eligible Azure VMs with Resource Graph and preserve each full resource ID.
3. Ansible enables the VM's system-assigned identity, installs AMA, and associates the Windows or Linux DCR.
4. AMA sends disk free-space percentage and free-megabyte counters directly to Azure Monitor.
5. KQL evaluates warning, critical, and stale-telemetry conditions; the Action Group routes alerts and the Workbook provides the fleet view.

The Azure enrollment playbooks use the Azure CLI's authenticated context. `AZURE_SUBSCRIPTION_ID` identifies the subscription containing the workspace and DCRs; it is needed to run enrollment, not to review or submit the assignment.

## Scalability and scope

Resource Graph discovery follows continuation tokens instead of stopping at the first 1,000 VMs. Telemetry flows directly from agents to Azure Monitor, avoiding an Ansible-controller polling bottleneck. Management-group Policy is the recommended steady-state control for new and existing Azure VMs.

The assignment asks for one provider, so **Azure is the implemented solution**. AWS EC2 and Google Compute Engine are described as future-state Azure Arc extensions. The Arc playbook is a bootstrap pattern, not a complete AWS/GCP inventory and identity integration.

## Deliverables

- `docs/final-submission.docx` — design, security model, operations, cost assumptions, and validation plan
- `diagrams/` — architecture diagrams in SVG and PNG
- `infra/` — Bicep for the workspace, DCRs, scheduled alerts, Action Group, and Workbook
- `ansible/` — Azure discovery and AMA/DCR enrollment playbooks, plus the Arc extension pattern
- `kql/` and `workbooks/` — fleet health, alert queries, and Workbook definition
- `docs/` — architecture, access, scaling, cost, operations, and validation documentation
- `scripts/` and `tests/` — discovery helper, cost model, and focused tests
- `.github/workflows/validate.yml` — automated repository, Ansible syntax, and Bicep build checks

## Validation status

No live Azure deployment or pilot was performed because no Azure subscription was available. The GitHub Actions workflow runs repository tests and syntax/build checks without deploying resources. Tenant-specific RBAC, network egress, Linux counter availability, alert delivery, and ingestion cost still require a live pilot.
