# Scaling and onboarding

## Azure

Use the included Ansible playbooks for pilot enrollment and repair. For production scale-out, assign a reviewed monitoring initiative at the management-group level; the initiative should install AMA, create the OS-correct DCR association, and remediate existing resources. That governance assignment is intentionally separate from the resource-group Bicep template in this repository. New subscriptions inherit it once they enter the governed hierarchy. The discovery helper follows Resource Graph continuation tokens, and the coverage process must compare eligible inventory with machines reporting to `Perf`.

## AWS and Google Cloud

The central workspace does not discover or manage these machines by itself. The bootstrap sequence is:

1. Query EC2 or Compute Engine inventory using a least-privilege cloud identity.
2. Select supported Windows and Linux machines and check the exception tag.
3. Install and register the Azure Connected Machine agent into the approved Arc landing subscription/resource group.
4. Apply Azure tags that preserve source cloud, account/project, region, and service ownership.
5. Use Policy or automation to install AMA and associate the OS-specific DCR.
6. Verify reporting before declaring onboarding complete.

The Azure pilot enrollment is sequential and safe to rerun. The Arc playbook processes hosts in batches of ten; production cloud discovery/bootstrap still needs cloud-specific retry and backoff policies. Preserve the full Arc resource ID as the join key; hostname alone is not safe in an acquired, multicloud estate.

## Capacity model

At 200 machines, four monitored filesystems per machine, two counters, and a five-minute interval, the model produces 13.824 million records per 30-day month. The controller does not process those records; the agents send them directly to Azure Monitor. Scale concerns therefore move to data volume, query shape, alert dimensions, policy compliance, and operational ownership rather than Ansible polling throughput.
