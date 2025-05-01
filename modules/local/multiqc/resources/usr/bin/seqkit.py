from multiqc.base_module import BaseMultiqcModule
from multiqc.plots import table
from multiqc import config
import logging
import glob
import json
import csv

log = logging.getLogger("multiqc")


class SeqKit(BaseMultiqcModule):
    def __init__(self):
        self.data = {}
        super(SeqKit, self).__init__(
            name="Seqkit",
            target="seqkit",
            anchor="seqkit",
            href="https://github.com/shenwei356/seqkit",
            info="Seqkit is used to manipulate FASTA/Q files.",
            doi=["10.1002/imt2.191", "10.1371/journal.pone.0163962"],
        )
        config_sp = getattr(config.sp, "seqkit", {})
        file_pattern = config_sp.get("fn", "data/seqkit/*.tsv")

        self.data = self.parse_files(file_pattern)

        if self.data:
            self.write_data_file(self.data, "multiqc_seqkit_sample")
            seqkit_sample_table = table.plot(
                data=self.data,
                pconfig={
                    "id": "seqkit-sample-table",
                    "title": "Subsampled Reads",
                },
                headers={
                    "total_reads": {
                        "title": "Total Reads",
                        "scale": "GnBu",
                    },
                    "subsampled_reads": {
                        "title": "Subsampled Reads",
                        "scale": "GnBu",
                    },
                },
            )
            self.add_section(
                name="Subsampled Reads",
                plot=seqkit_sample_table,
                anchor="seqkit-sample",
                description="""
                This table shows the number of raw reads and subsampled reads
                for samples that have been processed with Seqkit.
                """,
                helptext="""
                """,
            )

    def parse_files(self, file_pattern):
        data = {}
        found_files = [f for f in glob.iglob(file_pattern, recursive=True)]
        for f in found_files:
            with open(f) as fh:
                reader = csv.DictReader(fh, delimiter="\t")
                for line in reader:
                    file_id = line["file"].split(".")[0]
                    if file_id not in data:
                        data[file_id] = {}
                    if line["file"].endswith(".sub.fastq.gz"):
                        data[file_id]["subsampled_reads"] = int(
                            line["num_seqs"]
                        )
                    else:
                        data[file_id]["total_reads"] = int(line["num_seqs"])
        log.info(
            "Found {} reports for {}".format(len(found_files), file_pattern)
        )
        return data
