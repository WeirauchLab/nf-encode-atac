from multiqc.base_module import BaseMultiqcModule
from multiqc import config
import logging
import glob
from multiqc.plots import table
import csv
import os

log = logging.getLogger("multiqc")


class EncodeLibQC(BaseMultiqcModule):
    def __init__(self):
        super(EncodeLibQC, self).__init__(
            name="ENCODE Library Complexity",
            target="encode_lib_qc",
            anchor="encode_lib_qc",
            href="",
            info="",
        )
        self.data = self.parse_files()
        if self.data:
            self.tbl_lib_qc()

    def parse_files(self):
        config_sp = getattr(config.sp, "encode/lib_qc", {})
        file_pattern = config_sp.get("fn", "data/lib_qc/*.lib_qc.tsv")
        clean_str = config_sp.get("clean_str", ".lib_qc.tsv")
        files = [f for f in glob.iglob(file_pattern, recursive=True)]
        log.info("Found {} encode/lib_qc reports".format(len(files)))
        output = {}
        for file in files:
            log.debug(f"Reading {file}")
            sample_id = os.path.basename(file).replace(clean_str, "")
            with open(file, "r") as f:
                reader = csv.DictReader(f, delimiter="\t")
                output[sample_id] = next(reader)
        return output

    def tbl_lib_qc(self):
        self.write_data_file(self.data, "multiqc_encode_lib_qc")
        self.general_stats_addcols(self.data)
        tbl = table.plot(
            data=self.data,
            pconfig={
                "id": "encode_lib_qc_tbl",
                "title": "Library Complexity (ENCODE)",
            },
            headers={
                "total_fragments": {"title": "Total Fragments"},
                "distinct_fragments": {"title": "Distinct Fragments"},
                "positions_with_one_read": {"title": "Positions with 1 Read"},
                "positions_with_two_reads": {"title": "Positions with 2 Reads"},
                "nrf": {"title": "NRF"},
                "pbc1": {"title": "PBC1"},
                "pbc2": {"title": "PBC2"},
            },
        )
        self.add_section(
            name="Library Complexity",
            plot=tbl,
            anchor="encode_lib_qc_section",
            description="""
                **NRF** = Non-Redundant Fraction\n
                **PBC1** = PCR Bottlenecking Coefficient 1\n
                **PBC2** = PCR Bottlenecking Coefficient 2\n
                \n
                NRF should be greater than 0.8\n
                PBC1 is considered to be the primary measure
                according to ENCODE.\n
                They set out the following thresholds:\n
                - 0-0.5: severe bottlenecking\n
                - 0.5-0.8: moderate bottlenecking\n
                - 0.8-0.9: mild bottlenecking\n
                - 0.9-1.0: no bottlenecking\n
                \n
                The PBC2 is the ratio of genomic locations with
                EXACTLY one read pair over the genomic locations with
                EXACTLY two read pairs.\n
                The PBC2 should be significantly greater than 1.
                """,
            helptext="""
            The coefficients are calculated as follows:\n
            - Total Fragments = total number of reads used\n
            - Distinct Fragments = Number of distinct fragments detected\n
            - NRF = number of distinct reads / total number of reads\n
            - PBC1 = number of genomic positions with only one read
            / number of distinct genomic positions\n
            - PBC2 = number of genomic positions with exactly one read /
            number of genomic positions with exactly two reads\n
            """,
        )
