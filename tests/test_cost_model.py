import importlib.util
from pathlib import Path

spec = importlib.util.spec_from_file_location('cost_model', Path(__file__).parents[1] / 'scripts' / 'cost_model.py')
mod = importlib.util.module_from_spec(spec); spec.loader.exec_module(mod)

def test_baseline():
    assert mod.estimate(100) == {'vms': 100, 'records': 6912000, 'gb': 3.456, 'usd': 0.0}
    assert mod.estimate(200) == {'vms': 200, 'records': 13824000, 'gb': 6.912, 'usd': 4.4}
