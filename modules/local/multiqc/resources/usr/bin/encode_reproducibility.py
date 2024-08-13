from multiqc.base_module import BaseMultiqcModule
import logging
import glob
from multiqc.plots import table
import json

log = logging.getLogger("multiqc")


class EncodeReproducibility(BaseMultiqcModule):
    def __init__(self):
        self.data = {}
        super(EncodeReproducibility, self).__init__(
            name="ENCODE Reproducibility",
            target="encode_reproducibility",
            anchor="encode_reproducibility",
            href="",
            info="",
        )

        self.data["idr"] = self.parse_files(
            "data/encode_reproducibility_stats/idr/*.json"
        )
        self.data["overlap"] = self.parse_files(
            "data/encode_reproducibility_stats/overlap/*.json"
        )

        if self.data["idr"]:
            self.write_data_file(
                self.data["idr"], "multiqc_encode_idr_reproducibility"
            )
            idr_plot = table.plot(
                data=self.data["idr"],
                pconfig={
                    "id": "encode_reproducibility_stats_idr",
                    "title": "Reproducibility Statistics (IDR)",
                },
                headers={
                    "Nt": {"title": "Nt"},
                    "Np": {"title": "Np"},
                    "Conservative Peaks": {"title": "Conservative Peaks"},
                    "Optimal Peaks": {"title": "Optimal Peaks"},
                    "Rescue Ratio": {
                        "title": "Rescue Ratio",
                        "format": "{:,.3f}",
                    },
                    "Consistency Ratio": {
                        "title": "Consistency Ratio",
                        "format": "{:,.3f}",
                    },
                    "Reproducibility": {"title": "Reproducibility"},
                },
            )
            self.add_section(
                name="IDR Statistics",
                plot=idr_plot,
                anchor="encode_reproducibility_stats_idr_section",
                description="""
                            **Nt** = Best no. of peaks passing
                            IDR threshold by comparing true replicates\n
                            **Np** = Best no. of peaks passing
                            IDR threshold by comparing pseudoreplicates\n
                            **Conservative** = file containing the best
                            peak number when comparing true replicate pairs\n
                            **Optimal** = peak file with the most
                            peaks when comparing Nt and Np\n
                            **Rescue Ratio** = max(Nt, Np) / min(Nt, Np)\n
                            **Consistency Ratio** = max(Peaks) / min(Peaks)
                            """,
                helptext="""Nt is established by comparing pairs of true
                    replicates against
                    each other and transferring the results to the pooled peak
                    set. If you have 2 replicates, it would just be\n
                    - 'rep1 vs rep2'\n
                    if you have 3 or more, it would be:\n
                    - 'rep1 vs rep2'\n
                    - 'rep1 vs rep3'\n
                    - 'rep2 vs rep3'\n
                    and so on. The comparison the best number of peaks is then
                    selected as Nt. Np is established the same way, but it
                    will only ever have 2 pseudoreps. The rescue ratio is the
                    ratio of these two peak sets and tries to represent how
                    well the pseudoreplicates can recapitulate the
                    true replicates. Consistency ratio estimates how consistent
                    the peak sets are across the replicates. If one replicate
                    has a lot more peaks than the other, this will
                    ratio will increase, which could be indicative of a
                    failed replicate.
                    """,
            )
        if self.data["overlap"]:
            self.write_data_file(
                self.data["overlap"], "multiqc_encode_overlap_reproducibility"
            )
            overlap_plot = table.plot(
                data=self.data["overlap"],
                pconfig={
                    "id": "encode_reproducibility_stats_overlap",
                    "title": "Reproducibility Statistics (Overlap)",
                },
                headers={
                    "Nt": {"title": "Nt"},
                    "Np": {"title": "Np"},
                    "Conservative Peaks": {"title": "Conservative Peaks"},
                    "Optimal Peaks": {"title": "Optimal Peaks"},
                    "Rescue Ratio": {
                        "title": "Rescue Ratio",
                        "format": "{:,.3f}",
                    },
                    "Consistency Ratio": {
                        "title": "Consistency Ratio",
                        "format": "{:,.3f}",
                    },
                    "Reproducibility": {"title": "Reproducibility"},
                },
            )
            self.add_section(
                name="Overlap Statistics",
                plot=overlap_plot,
                anchor="encode_reproducibility_stats_overlap_section",
                description="""
                            **Nt** = Best no. of peaks overlaps
                            by comparing true replicates\n
                            **Np** = Best no. of peaks overlaps
                            by comparing pseudoreplicates\n
                            **Conservative** = file containing the best
                            peak number when comparing true replicate pairs\n
                            **Optimal** = peak file with the most
                            peaks when comparing Nt and Np\n
                            **Rescue Ratio** = max(Nt, Np) / min(Nt, Np)\n
                            **Consistency Ratio** = max(Peaks) / min(Peaks)
                            """,
                helptext="""Nt is established by comparing pairs of true
                    replicates against
                    each other and transferring the results to the pooled peak
                    set. If you have 2 replicates, it would just be\n
                    - 'rep1 vs rep2'\n
                    if you have 3 or more, it would be:\n
                    - 'rep1 vs rep2'\n
                    - 'rep1 vs rep3'\n
                    - 'rep2 vs rep3'\n
                    and so on. The comparison the best number of peaks is then
                    selected as Nt. Np is established the same way, but it
                    will only ever have 2 pseudoreps. The rescue ratio is the
                    ratio of these two peak sets and tries to represent how
                    well the pseudoreplicates can recapitulate the
                    true replicates. Consistency ratio estimates how consistent
                    the peak sets are across the replicates. If one replicate
                    has a lot more peaks than the other, this will
                    ratio will increase, which could be indicative of a
                    failed replicate.
                    """,
            )

    def parse_files(self, file_pattern):
        data = {}
        found_files = [f for f in glob.iglob(file_pattern, recursive=True)]
        for f in found_files:
            with open(f) as fh:
                contents = json.load(fh)
            sample_id = contents["sample"]
            del contents["sample"]
            data[sample_id] = contents
        log.info("Found {} reports for {}".format(len(self.data), file_pattern))

        return data
