#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
from pathlib import Path


QUERY = """Resources
| where type =~ 'microsoft.compute/virtualmachines'
| where tostring(tags['disk-monitoring']) !~ 'disabled'
| extend osType=tostring(properties.storageProfile.osDisk.osType)
| where osType in~ ('Windows', 'Linux')
| project id, name, subscriptionId, resourceGroup, location, osType, tags
| order by id asc"""


def discover_vms(runner=None):
    run = runner or subprocess.run
    results = []
    skip_token = None
    seen_tokens = set()

    while True:
        command = [
            "az", "graph", "query",
            "--first", "1000",
            "--graph-query", QUERY,
            "--output", "json",
        ]
        if skip_token:
            command.extend(["--skip-token", skip_token])

        response = run(command, check=True, capture_output=True, text=True)
        page = json.loads(response.stdout)
        if not isinstance(page, dict) or not isinstance(page.get("data"), list):
            raise ValueError("Azure Resource Graph returned an unexpected response.")

        results.extend(page["data"])
        next_token = page.get("skipToken")
        if not next_token:
            if page.get("resultTruncated"):
                raise RuntimeError(
                    "Azure Resource Graph truncated results without a continuation token."
                )
            break
        if next_token in seen_tokens:
            raise RuntimeError("Azure Resource Graph returned a repeated continuation token.")
        seen_tokens.add(next_token)
        skip_token = next_token

    return results


def main():
    parser = argparse.ArgumentParser(description="Discover Azure VMs visible to Azure CLI.")
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    try:
        machines = discover_vms()
    except (subprocess.CalledProcessError, json.JSONDecodeError, ValueError, RuntimeError) as exc:
        print(f"Azure VM discovery failed: {exc}", file=sys.stderr)
        if isinstance(exc, subprocess.CalledProcessError) and exc.stderr:
            print(exc.stderr, file=sys.stderr, end="")
        return 1

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(machines, indent=2) + "\n", encoding="utf-8")
    print(f"Discovered {len(machines)} eligible Azure VMs.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
