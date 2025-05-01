#!/usr/bin/env python

import argparse
import random
import string
import os
import hashlib
import base64


class CommonSettings:
    def __init__(self, bigDataUrl, visibility="hide", color=None):
        file_name = os.path.basename(bigDataUrl)
        file_id = os.path.splitext(file_name)[0]
        self.entries = [
            f"track {self.path_to_alphanum_hash(bigDataUrl, 12)}",
            f"bigDataUrl {bigDataUrl}",
            f"shortLabel {file_id[:17]}",
            f"longLabel {file_id}",
            f"visibility {visibility}",
        ]
        if color:
            self.entries.append(f"color {color}")

    def path_to_alphanum_hash(self, file_path, length=12):
        # Create a SHA256 hash of the file path
        hash_object = hashlib.sha256(file_path.encode())
        hash_digest = hash_object.digest()

        # Use base64 encoding to convert to alphanumeric
        b64_encoded = base64.b64encode(hash_digest).decode()

        # Remove any non-alphanumeric characters
        alphanum_hash = "".join(c for c in b64_encoded if c.isalnum())

        # Ensure the hash starts with a letter
        if not alphanum_hash[0].isalpha():
            alphanum_hash = "a" + alphanum_hash[1:]

        # Truncate or pad to desired length
        return alphanum_hash[:length].ljust(length, "a")

    def parse_track(self):
        return "\n".join(self.entries)


class BigWig(CommonSettings):
    def __init__(
        self,
        bigDataUrl,
        track_type="bigWig",
        visibility="hide",
        autoscale="on",
        maxHeightPixels=None,
        viewLimits=None,
        alwaysZero="on",
        graphTypeDefault="bar",
        smoothingWindow="off",
        windowingFunction="mean",
        **kwargs,
    ):
        super().__init__(bigDataUrl, visibility)
        self.entries.append(f"type {track_type}")
        self.entries.append(f"autoScale {autoscale}")
        self.entries.append(f"smoothingWindow {smoothingWindow}")
        self.entries.append(f"windowingFunction {windowingFunction}")
        self.entries.append(f"alwaysZero {alwaysZero}")
        self.entries.append(f"graphTypeDefault {graphTypeDefault}")
        if maxHeightPixels:
            self.entries.append(f"maxHeightPixels {maxHeightPixels}")
        if viewLimits:
            self.entries.append(f"viewLimits {viewLimits}")


if __name__ == "__main__":
    bw = BigWig(bigDataUrl="data/abc.bw", visibility="full", color="255,0,0")
    print(bw.parse_track())
