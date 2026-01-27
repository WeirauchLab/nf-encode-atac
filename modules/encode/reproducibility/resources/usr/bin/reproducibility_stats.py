#!/usr/bin/env python

import argparse
import csv
import json
from pathlib import Path
import shutil


def parse_args():
    parser = argparse.ArgumentParser(
        description="Calculate reproducibility statistics for ENCODE peaks"
    )
    parser.add_argument(
        "--Nt", default="nt", help="folder containing the Nt category"
    )
    parser.add_argument(
        "--Np", default="np", help="folder containing in the Np category"
    )
    parser.add_argument(
        "--peaks",
        default="peaks",
        help="peaks in the self-consistency category",
    )
    parser.add_argument(
        "--sample", default="sample", help="sample / condition name"
    )
    parser.add_argument(
        "--mode", default="general", help="reproducibility mode"
    )
    return parser.parse_args()


def peaks_to_list(x: Path | str) -> list:
    x = Path(x)
    return [p for p in x.glob("*") if p.is_file()]


def count_lines(file: Path | str) -> int:
    file = Path(file)
    with open(file, "r") as f:
        return sum(1 for _ in f)


def calculate_consistency_ratio(x: list[int]) -> float | None:
    if not x:
        return None
    min_count = min(x)
    if min_count <= 0:
        return None
    return max(x) / min_count


def calculate_rescue_ratio(nt: int, np: int) -> float | None:
    if not nt or not np:
        return None
    return max(nt, np) / min(nt, np)


def score_reproducibility(
    rescue_ratio: float, consistency_ratio: float
) -> str | None:
    if not rescue_ratio or not consistency_ratio:
        return None
    elif rescue_ratio > 2.0 and consistency_ratio > 2.0:
        return "fail"
    elif rescue_ratio > 2.0 or consistency_ratio > 2.0:
        return "borderline"
    else:
        return "pass"


def copy_peak_file(peak_path: Path | str, output_path: Path | str) -> bool:
    if not peak_path:
        return False
    peak_path = Path(peak_path)
    output_path = Path(output_path)
    if not peak_path.exists():
        return False
    shutil.copy(peak_path, output_path)
    return True


def main():
    args = parse_args()
    prefix = f"{args.sample}_{args.mode}"
    output_stats_csv = Path(f"{prefix}_reproducibility_stats.csv")
    output_multiqc_json = Path(f"{prefix}_reproducibility_stats.json")
    output_peak_counts_csv = Path(f"{prefix}_peak_counts.csv")
    output_conservative_peak = Path(f"{prefix}_conservative.narrowPeak")
    output_optimal_peak = Path(f"{prefix}_optimal.narrowPeak")

    stats = {
        "sample": args.sample,
        "mode": args.mode,
        "Nt": 0,
        "Np": 0,
        "Conservative Peaks": None,
        "Optimal Peaks": None,
        "Rescue Ratio": None,
        "Consistency Ratio": None,
        "Reproducibility": None,
    }
    nt_peaks = peaks_to_list(args.Nt)
    np_peaks = peaks_to_list(args.Np)
    rep_peaks = peaks_to_list(args.peaks)

    nt_peak_counts = {str(f): count_lines(f) for f in nt_peaks}
    np_peak_counts = {str(f): count_lines(f) for f in np_peaks}
    rep_peak_counts = {str(f): count_lines(f) for f in rep_peaks}

    stats["Nt"] = max(nt_peak_counts.values()) if nt_peak_counts else 0
    stats["Conservative Peaks"] = (
        max(nt_peak_counts, key=nt_peak_counts.get) if nt_peak_counts else None
    )

    stats["Np"] = max(np_peak_counts.values()) if np_peak_counts else 0

    np_merged = {**nt_peak_counts, **np_peak_counts}
    if np_merged:
        stats["Optimal Peaks"] = max(np_merged, key=np_merged.get)

    stats["Consistency Ratio"] = calculate_consistency_ratio(
        list(rep_peak_counts.values())
    )
    stats["Rescue Ratio"] = calculate_rescue_ratio(stats["Nt"], stats["Np"])

    stats["Reproducibility"] = score_reproducibility(
        stats["Rescue Ratio"], stats["Consistency Ratio"]
    )

    # ------- Copy conservative and optimal peak sets

    if stats["Conservative Peaks"]:
        copy_peak_file(stats["Conservative Peaks"], output_conservative_peak)

    if stats["Optimal Peaks"]:
        copy_peak_file(stats["Optimal Peaks"], output_optimal_peak)

    # ------- Export Stats

    with open(output_stats_csv, "w") as out_csv:
        writer = csv.DictWriter(out_csv, fieldnames=stats.keys())
        writer.writeheader()
        writer.writerow(stats)

    with open(output_multiqc_json, "w") as out_json:
        json.dump(stats, out_json)

    # ------- Export Peak Counts
    rows = []
    for group, counts in [
        ("Nt", nt_peak_counts),
        ("Np", np_peak_counts),
        ("rep", rep_peak_counts),
    ]:
        for peak, count in counts.items():
            rows.append(
                {
                    "sample": args.sample,
                    "mode": args.mode,
                    "peak_group": group,
                    "peak_file": peak,
                    "peak_count": count,
                }
            )
    with open(output_peak_counts_csv, "w") as out_csv:
        writer = csv.DictWriter(
            out_csv,
            fieldnames=[
                "sample",
                "mode",
                "peak_group",
                "peak_file",
                "peak_count",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    main()
