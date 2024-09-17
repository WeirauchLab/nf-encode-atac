#!/usr/bin/env python
import argparse
import multiqc
from homer_custom import Homer
from encode_reproducibility import EncodeReproducibility
from spp_xcorr import SppXCorr
from encode_libqc import EncodeLibQC
from encode_peakstats import EncodePeakStats

parser = argparse.ArgumentParser()
parser.add_argument("--config", type=str)
args = parser.parse_args()

# Parse known logs
multiqc.parse_logs("data")

# ----------------- Custom MultiQC modules -----------------

# ENCODE lib complexity
multiqc.report.modules.append(EncodeLibQC())

# ENCODE xcorr
multiqc.report.modules.append(SppXCorr())

# ENCODE IDR statistics
multiqc.report.modules.append(EncodeReproducibility())

# ENCODE peak statistics
multiqc.report.modules.append(EncodePeakStats())

# Custom HOMER module
multiqc.report.modules.append(Homer())


# Write the report
multiqc.write_report(filename="multiqc_report.html", force=True)
