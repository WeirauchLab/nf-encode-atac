from multiqc.base_module import BaseMultiqcModule
from multiqc.plots import table, linegraph
from multiqc import config
import logging
import glob
import json

log = logging.getLogger("multiqc")


class AtacSeqQC(BaseMultiqcModule):
    def __init__(self):
        self.data = {}
        super(AtacSeqQC, self).__init__(
            name="ATACseqQC",
            target="atacseqqc",
            anchor="atacseqqc",
            href="https://www.bioconductor.org/packages/release/bioc/html/ATACseqQC.html",
            info="",
            doi="10.1186/s12864-018-4559-3",
        )
        config_sp = getattr(config.sp, "atacseqqc/tsse", {})
        file_pattern = config_sp.get("fn", "data/tss_enrichment/*.json")

        self.data = self.parse_files(file_pattern)

        if self.data["score"]:
            self.write_data_file(
                self.data["score"], "multiqc_tss_enrichment_score"
            )
            self.general_stats_addcols(
                self.data["score"],
                headers={
                    "score": {
                        "title": "TSSE Score",
                        "format": "{:.4f}",
                        "scale": "Blues",
                        "description": "TSS enrichment score.  Calculated using values from the supplied GTF file.",
                    }
                },
            )
            tsse_table = table.plot(
                data=self.data["score"],
                pconfig={
                    "id": "atacseqqc-tsse-table",
                    "title": "TSS Enrichment Scores",
                },
                headers={
                    "score": {
                        "title": "Score",
                        "hidden": False,
                        "format": "{:.4f}",
                    },
                    "prefix": {"title": "Sample ID", "hidden": True},
                    "bam": {"title": "Bam", "hidden": True},
                    "downstream": {"title": "Downstream", "hidden": True},
                    "upstream": {"title": "Upstream", "hidden": True},
                    "feature": {"title": "Feature", "hidden": True},
                    "gtf": {"title": "GTF", "hidden": True},
                    "pseudocount": {"title": "Pseudocount", "hidden": True},
                    "step": {"title": "Step", "hidden": True},
                    "width": {"title": "Width", "hidden": True},
                },
            )
            self.add_section(
                name="TSS Enrichment Scores",
                plot=tsse_table,
                anchor="atacseqqc-tsse-scores",
                description="""
                The TSS enrichment score is a measure of the enrichment of reads around transcription start sites (TSS).
                A higher score indicates a higher enrichment of reads at the TSS.
                ATACseqQC calculates the TSS enrichment score using [ENCODE's method](https://www.encodeproject.org/data-standards/terms/#enrichment).
                """,
                helptext="""
                """,
            )
        if self.data["signal"]:
            self.write_data_file(
                self.data["signal"], "multiqc_tss_enrichment_signal"
            )
            tsse_plot = linegraph.plot(
                data=self.data["signal"],
                pconfig={
                    "id": "atacseqqc-tsse-signal",
                    "title": "TSS Enrichment Signal",
                    "xlab": "Distance from TSS",
                    "ylab": "Score",
                },
            )
            self.add_section(
                name="TSS Enrichment Signal",
                plot=tsse_plot,
                anchor="atacseqqc-tsse-signal",
                description="""""",
                helptext="""""",
            )

    def parse_files(self, file_pattern):
        data = {"signal": {}, "score": {}}
        found_files = [f for f in glob.iglob(file_pattern, recursive=True)]
        for f in found_files:
            with open(f) as fh:
                contents = json.load(fh)
            sample_id = contents["params"]["prefix"]
            data["signal"][sample_id] = {
                float(x): float(y) for x, y in contents["signal"].items()
            }
            data["score"][sample_id] = {
                "score": contents["score"],
                **contents["params"],
            }
        log.info(
            "Found {} reports for {}".format(len(found_files), file_pattern)
        )
        return data
