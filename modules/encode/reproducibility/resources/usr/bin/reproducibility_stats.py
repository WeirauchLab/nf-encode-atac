#!/usr/bin/env python

import argparse
import os
from dataclasses import dataclass, field
import shutil
import csv
import json

parser = argparse.ArgumentParser(
    description="Calculate reproducibility statistics for ENCODE peaks"
)
parser.add_argument(
    "--Nt", nargs="+", default=None, help="peaks in the Nt category"
)
parser.add_argument(
    "--Np", nargs="+", default=None, help="peaks in the Np category"
)
parser.add_argument(
    "--peaks",
    nargs="+",
    default=None,
    help="Sample self-consistency peaks category",
)
parser.add_argument(
    "--sample",
    required=True,
)
parser.add_argument("--mode", default="general")


@dataclass
class ReproducibilityStats:
    sample: str
    mode: str = "general"
    nt_peaks: list = field(default_factory=list)
    np_peaks: list = field(default_factory=list)
    peaks: list = field(default_factory=list)
    nt_counts: list = field(init=False, default_factory=list)
    np_counts: list = field(init=False, default_factory=list)
    rep_counts: list = field(init=False, default_factory=list)
    Nt: int = field(init=False, default=None)
    Np: int = field(init=False, default=None)
    rescue_ratio: float = field(init=False, default=None)
    consistency_ratio: float = field(init=False, default=None)
    conservative: str = field(init=False, default=None)
    optimal: str = field(init=False, default=None)
    reproducibility: str = field(init=False, default="NA")
    prefix: str = field(init=False, default=None)

    def __post_init__(self):
        self.prefix = f"{self.sample}_{self.mode}"
        if self.nt_peaks:
            for peak in self.nt_peaks:
                count = 0
                with open(peak, "r") as f:
                    for _ in f:
                        count += 1
                self.nt_counts.append(count)
            self.Nt = max(self.nt_counts)
            self.conservative = self.nt_peaks[self.nt_counts.index(self.Nt)]

        if self.np_peaks:
            for peak in self.np_peaks:
                count = 0
                with open(peak, "r") as f:
                    for _ in f:
                        count += 1
                self.np_counts.append(count)
            self.Np = max(self.np_counts)
            self.optimal = self.np_peaks[self.np_counts.index(self.Np)]

        if self.peaks:
            for peak in self.peaks:
                count = 0
                with open(peak, "r") as f:
                    for _ in f:
                        count += 1
                self.rep_counts.append(count)
            self.consistency_ratio = float(max(self.rep_counts)) / float(
                min(self.rep_counts)
            )

        if self.Nt is not None and self.Np is not None:
            if self.Nt > self.Np:
                self.optimal = self.conservative
            self.rescue_ratio = float(max(self.Nt, self.Np)) / float(
                min(self.Nt, self.Np)
            )
        if self.rescue_ratio is not None and self.consistency_ratio is not None:
            if self.rescue_ratio > 2.0 and self.consistency_ratio > 2.0:
                self.reproducibility = "fail"
            elif self.rescue_ratio > 2.0 or self.consistency_ratio > 2.0:
                self.reproducibility = "borderline"
            else:
                self.reproducibility = "pass"

    def export_peakset(self, peakset):
        peak_file = getattr(self, peakset)
        output_file = f"{self.prefix}_{peakset}.narrowPeak"
        if peak_file is None:
            print(f"No peak set found! Skipping export of: {peakset}")
            return
        peak_file = os.path.realpath(peak_file)
        print(f"Exporting {peakset} peak set to: {output_file}")
        shutil.copy(peak_file, output_file)

    def export_stats(self):
        output_file = f"{self.prefix}_reproducibility_stats.csv"
        output_contents = {
            "Nt": self.Nt,
            "Np": self.Np,
            "Conservative Peaks": self.conservative,
            "Optimal Peaks": self.optimal,
            "Rescue Ratio": self.rescue_ratio,
            "Consistency Ratio": self.consistency_ratio,
            "Reproducibility": self.reproducibility,
        }
        fieldnames = output_contents.keys()
        print(f"Exporting reproducibility statistics to: {output_file}")
        with open(output_file, "w") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows([output_contents])

    def export_stats_multiqc(self):
        output_file = f"{self.prefix}_reproducibility_stats.json"
        output_contents = {
            "sample": self.sample,
            "mode": self.mode,
            "Nt": self.Nt,
            "Np": self.Np,
            "Conservative Peaks": self.conservative,
            "Optimal Peaks": self.optimal,
            "Rescue Ratio": self.rescue_ratio,
            "Consistency Ratio": self.consistency_ratio,
            "Reproducibility": self.reproducibility,
        }
        print(
            f"Exporting reproducibility statistics (multiqc) to: {output_file}"
        )
        with open(output_file, "w") as f:
            json.dump(output_contents, f)

    def export_peak_counts(self):
        output_file = f"{self.prefix}_peak_counts.csv"
        rows = []
        if self.nt_peaks is not None:
            for peak, count in zip(self.nt_peaks, self.nt_counts):
                rows.append(
                    {
                        "sample": self.sample,
                        "mode": self.mode,
                        "peak_group": "Nt",
                        "peak_file": peak,
                        "peak_count": count,
                    }
                )
        if self.np_peaks is not None:
            for peak, count in zip(self.np_peaks, self.np_counts):
                rows.append(
                    {
                        "sample": self.sample,
                        "mode": self.mode,
                        "peak_group": "Np",
                        "peak_file": peak,
                        "peak_count": count,
                    }
                )
        if self.peaks is not None:
            for peak, count in zip(self.peaks, self.rep_counts):
                rows.append(
                    {
                        "sample": self.sample,
                        "mode": self.mode,
                        "peak_group": "rep",
                        "peak_file": peak,
                        "peak_count": count,
                    }
                )
            with open(output_file, "w") as f:
                writer = csv.DictWriter(
                    f,
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
    opt = parser.parse_args()
    rep_stats = ReproducibilityStats(
        nt_peaks=opt.Nt,
        np_peaks=opt.Np,
        peaks=opt.peaks,
        mode=opt.mode,
        sample=opt.sample,
    )
    rep_stats.export_peakset("conservative")
    rep_stats.export_peakset("optimal")
    rep_stats.export_stats()
    rep_stats.export_stats_multiqc()
    rep_stats.export_peak_counts()
