import json
from types import SimpleNamespace

import pytest

from scripts.discover_azure_vms import discover_vms


def test_discovery_follows_resource_graph_continuation_tokens():
    pages = [
        {
            "data": [{"id": "/subscriptions/a/vm/one"}],
            "skipToken": "next-page",
            "resultTruncated": True,
        },
        {
            "data": [{"id": "/subscriptions/a/vm/two"}],
            "resultTruncated": False,
        },
    ]
    commands = []

    def fake_run(command, **kwargs):
        commands.append(command)
        return SimpleNamespace(stdout=json.dumps(pages[len(commands) - 1]))

    assert discover_vms(fake_run) == [
        {"id": "/subscriptions/a/vm/one"},
        {"id": "/subscriptions/a/vm/two"},
    ]
    assert commands[1][commands[1].index("--skip-token") + 1] == "next-page"


def test_discovery_fails_instead_of_silently_truncating():
    def fake_run(command, **kwargs):
        return SimpleNamespace(stdout=json.dumps({"data": [], "resultTruncated": True}))

    with pytest.raises(RuntimeError, match="without a continuation token"):
        discover_vms(fake_run)


def test_discovery_rejects_repeated_continuation_tokens():
    def fake_run(command, **kwargs):
        return SimpleNamespace(stdout=json.dumps({"data": [], "skipToken": "same"}))

    with pytest.raises(RuntimeError, match="repeated continuation token"):
        discover_vms(fake_run)
