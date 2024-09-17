from multiqc.base_module import BaseMultiqcModule
from multiqc.plots import table
from multiqc import config
import logging
import glob
import json

log = logging.getLogger("multiqc")


class EncodePeakStats(BaseMultiqcModule):
    def __init__(self):
        self.data = {}
        super(EncodePeakStats, self).__init__(
            name="ENCODE Peak Statistics",
            target="encode_peakstats",
            anchor="encode_peakstats",
            href="",
            info="Peak files calculated within the ENCODE portion of the pipeline are summarized here.",
        )
        config_sp = getattr(config.sp, "encode/peakstats", {})
        file_pattern = config_sp.get("fn", "data/encode_peakstats/*.json")

        self.data = self.parse_files(file_pattern)

        if self.data:
            self.write_data_file(self.data, "multiqc_encode_peakstats")
            peakstats_plot = table.plot(
                data=self.data,
                pconfig={
                    "id": "encode_peakstats_table",
                    "title": "Peak Statistics",
                },
                headers={
                    "id": {"title": "Peak ID", "hidden": True},
                    "sample": {"title": "Sample ID", "hidden": True},
                    "group": {"title": "Group"},
                    "peak_file": {"title": "Peak File", "hidden": True},
                    "tagalign_file": {"title": "tagAlign", "hidden": True},
                    "total_peaks": {
                        "title": "Total Peaks",
                        "format": "{:,.0f}",
                    },
                    "total_reads": {
                        "title": "Total Reads",
                        "format": "{:,.0f}",
                        "hidden": True,
                    },
                    "reads_in_peaks": {
                        "title": "Reads in Peaks",
                        "format": "{:,.0f}",
                        "hidden": True,
                    },
                    "frip": {
                        "title": "FRiP",
                        "format": "{:.4f}",
                    },
                },
            )
            self.add_section(
                name="Peak Statistics",
                plot=peakstats_plot,
                anchor="encode_peakstats_section",
                description="""
                The following table shows the number of peaks, total reads,\n
                reads in peaks, and fraction of reads in peaks (FRiP)\n
                for each sample.\n
                Read intersections are calculated using the tagAlign file.\n
                """,
                helptext="""""",
            )

    def parse_files(self, file_pattern):
        data = {}
        found_files = [f for f in glob.iglob(file_pattern, recursive=True)]
        for f in found_files:
            with open(f) as fh:
                contents = json.load(fh)
            sample_id = contents["id"]
            data[sample_id] = contents
        log.info("Found {} reports for {}".format(len(self.data), file_pattern))

        return data
