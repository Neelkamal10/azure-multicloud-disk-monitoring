#!/usr/bin/env python3
import argparse, csv

PRICE_PER_GB = 2.30
FREE_GB = 5.0
BYTES_PER_RECORD = 500
DAYS = 30
COUNTERS = 2


def estimate(vms, disks=4, interval=300):
    samples_per_day = 86400 // interval
    records = vms * disks * COUNTERS * samples_per_day * DAYS
    gb = records * BYTES_PER_RECORD / 1_000_000_000
    charge = max(0.0, gb - FREE_GB) * PRICE_PER_GB
    return {'vms': vms, 'records': records, 'gb': round(gb, 3), 'usd': round(charge, 2)}


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--csv')
    p.add_argument('--interval', type=int, default=300)
    args = p.parse_args()
    rows = [estimate(v, interval=args.interval) for v in (100, 150, 200)]
    for r in rows:
        print(f"{r['vms']:>3} VMs  {r['records']:>10,} records  {r['gb']:>6.3f} GB  ${r['usd']:.2f}")
    if args.csv:
        with open(args.csv, 'w', newline='') as f:
            w = csv.DictWriter(f, fieldnames=rows[0].keys())
            w.writeheader(); w.writerows(rows)

if __name__ == '__main__':
    main()
