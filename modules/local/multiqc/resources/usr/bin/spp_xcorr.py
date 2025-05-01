from multiqc.base_module import BaseMultiqcModule
import logging
import glob
from multiqc.plots import linegraph, table
from multiqc import config
import csv
import os

log = logging.getLogger("multiqc")


class SppXCorr(BaseMultiqcModule):
    def __init__(self):
        super(SppXCorr, self).__init__(
            name="Phantompeakqualtools",
            target="kundajelab/phantompeakqualtools",
            anchor="phantompeakqualtools",
            href="https://github.com/kundajelab/phantompeakqualtools",
            info="""Phantompeakqualtools is an R script that infers
            fragment length information from NGS data
            based on strand cross-correlation peaks.
            """,
            doi=["10.1101/gr.136184.111", "10.1038/nbt.1508"],
        )

        self.xcorr_data = self.parse_xcorr_files()
        self.spp_data = self.parse_spp_files()
        if self.xcorr_data:
            self.plot_xcorr()
        if self.spp_data:
            self.plot_spp()

    def plot_spp(self):
        self.write_data_file(self.spp_data, "multiqc_spp_data")
        self.add_section(
            name="SPP Quality Metrics",
            anchor="phantompeakqualtools_spp_metrics",
            description="""Quality metrics for each sample, represented
            as a table.
            Only the first estimated fragment length and
            its stats are reported.
            Original metrics can be found in the SPP output files.
            """,
            helptext="""The output of SPP provides a numberic quality tag,
            which has been mapped as follows:

            | Quality Tag | Description |
            |-------------|-------------|
            | 2           | Very High   |
            | 1           | High        |
            | 0           | Medium      |
            | -1          | Low         |
            | -2          | Very Low    |
            | Unknown     | Unknown     |
            """,
            plot=table.plot(
                data=self.spp_data,
                pconfig={"id": "spp_metrics_table", "title": "SPP Metrics"},
                headers={
                    "file": {"title": "File", "hidden": True},
                    "total_reads": {"title": "Total Reads", "hidden": True},
                    "est_frag_len": {"title": "Estimated Fragment Length"},
                    "corr_est_frag_len": {
                        "title": "Correlation",
                        "format": "{:,.4f}",
                    },
                    "phantom_peak": {"title": "Phantom Peak"},
                    "corr_phantom_peak": {
                        "title": "Phantom Peak Correlation",
                        "format": "{:,.4f}",
                    },
                    "argmin_corr": {
                        "title": "Min Correlation Shift",
                        "hidden": True,
                    },
                    "min_corr": {
                        "title": "Min Correlation",
                        "hidden": True,
                        "format": "{:,.4f}",
                    },
                    "NSC": {
                        "title": "NSC",
                        "format": "{:,.4f}",
                    },
                    "RSC": {
                        "title": "RSC",
                        "format": "{:,.4f}",
                    },
                    "quality_tag": {
                        "title": "Quality Tag Number",
                        "hidden": True,
                    },
                    "quality_tag_string": {
                        "title": "Quality Tag",
                        "cond_formatting_rules": {
                            "Very High": [{"s_eq": "Very High"}],
                            "High": [{"s_eq": "High"}],
                            "Medium": [{"s_eq": "Medium"}],
                            "Low": [{"s_eq": "Low"}],
                            "Very Low": [{"s_eq": "Very Low"}],
                            "Unknown": [{"s_eq": "Unknown"}],
                        },
                        "cond_formatting_colours": [
                            {"Very High": "#2ca02c"},
                            {"High": "#98df8a"},
                            {"Medium": "#c5e3bf"},
                            {"Low": "#ff7f0e"},
                            {"Very Low": "#d62728"},
                            {"Unknown": "#808080"},
                        ],
                    },
                },
            ),
        )

    def plot_xcorr(self):
        self.write_data_file(self.xcorr_data, "multiqc_spp_xcorr")
        self.add_section(
            name="Cross-Correlation Shifts",
            anchor="phantompeakqualtools_xcorr",
            description="""Cross-correlation shifts for each sample.
            Correlation is the Pearson correlation coefficient between the
            forward and reverse strands after shifting by X base pairs.
            The normalized tab represents the correlation coefficient after
            scaling each sample to a range between 0 and 1.0.
            """,
            plot=linegraph.plot(
                data=[
                    self.xcorr_data["normalized"],
                    self.xcorr_data["correlation"],
                ],
                pconfig={
                    "id": "spp_xcorr_plot",
                    "title": "Cross-Correlation Shift",
                    "data_labels": [
                        {
                            "name": "Normalized",
                            "xlab": "Shift",
                            "ylab": "Normalized Cross-Correlation",
                        },
                        {
                            "name": "Correlation",
                            "xlab": "Shift",
                            "ylab": "Cross-Correlation",
                        },
                    ],
                },
            ),
        )

    def parse_spp_files(self):
        output = {}
        config_sp = getattr(config.sp, "spp/spp", {})
        file_pattern = config_sp.get("fn", "data/spp/*.spp.out")
        clean_ext = config_sp.get("clean_ext", ".spp.out")
        files = [f for f in glob.iglob(file_pattern, recursive=True)]
        log.info("Found {len(files)} spp reports (custom module)")
        line_headers = [
            "file",
            "total_reads",
            "est_frag_len",
            "corr_est_frag_len",
            "phantom_peak",
            "corr_phantom_peak",
            "argmin_corr",
            "min_corr",
            "NSC",
            "RSC",
            "quality_tag",
            "quality_tag_string",
        ]
        quality_tags = {
            -2: "Very Low",
            -1: "Low",
            0: "Medium",
            1: "High",
            2: "Very High",
        }
        for file in files:
            log.debug(f"Reading {file}")
            sample_id = os.path.basename(file).replace(clean_ext, "")
            with open(file, "r") as f:
                entry = f.readline().strip("\n").split("\t")
                entry[2] = entry[2].split(",")[0]
                entry[3] = entry[3].split(",")[0]
                entry.append(quality_tags.get(int(entry[10]), "Unknown"))
                output[sample_id] = dict(zip(line_headers, entry))
        return output

    def parse_xcorr_files(self):
        output = {
            "correlation": {},
            "normalized": {},
        }
        config_sp = getattr(config.sp, "spp/xcorr", {})
        file_pattern = config_sp.get("fn", "data/spp_xcor/*.csv")
        files = [f for f in glob.iglob(file_pattern, recursive=True)]
        log.info("Found {} spp/xcorr reports".format(len(files)))
        for file in files:
            log.debug(f"Reading {file}")
            with open(file, "r") as f:
                reader = csv.DictReader(f)
                sample_id = None
                corr_dict = {}
                norm_dict = {}
                for row in reader:
                    if sample_id is None:
                        sample_id = row["sample_id"]
                    key = float(row["shift"])
                    corr_dict[key] = float(row["correlation"])
                    norm_dict[key] = float(row["normalized"])
                if corr_dict:
                    output["correlation"][sample_id] = corr_dict
                if norm_dict:
                    output["normalized"][sample_id] = norm_dict
        return output
