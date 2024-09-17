#!/usr/bin/env python
from pydantic import BaseModel, Field
from typing import Optional, Union, List
import os
from uuid import uuid4
import argparse
import logging
import glob

# TODO: This is just printing /data/.../*

__author__ = "Andrew VonHandorf"
__version__ = "0.1.0"

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)

log = logging.getLogger(__name__)


def create_track_hash(length: int = 12) -> str:
    label = str(uuid4().hex)
    if not label[0].isalpha():
        label = "a" + label[1:]
    return label[:length]


def pad_string_with_char(original_string, total_length, pad_char="#"):
    original_string = f" {original_string} "
    original_length = len(original_string)
    padding_needed = max(total_length - original_length, 0)
    # Calculate padding for each side
    left_padding = padding_needed // 2
    right_padding = padding_needed - left_padding
    # Create the padded string
    padded_string = (
        f"{pad_char * left_padding}{original_string}{pad_char * right_padding}"
    )
    return padded_string


class Track(BaseModel):
    track: str = Field(default_factory=create_track_hash)
    bigDataUrl: str
    visibility: str = "hide"
    shortLabel: Optional[str] = None
    longLabel: Optional[str] = None
    color: Optional[str] = None
    priority: Optional[float] = None
    altColor: Optional[str] = None
    parent: Optional[str] = None

    def __init__(self, **data):
        super().__init__(**data)
        file_name = os.path.basename(self.bigDataUrl)
        if self.shortLabel is None:
            self.shortLabel = file_name
        if self.longLabel is None:
            self.longLabel = file_name
        self.shortLabel = self.shortLabel[:17]

    def parse_track(self):
        log.info(
            f"parsing track: {self.track} || type: {self.__class__.__name__}"
        )
        track_strings = [
            f"track {self.track}",
            f"bigDataUrl {self.bigDataUrl}",
            f"shortLabel {self.shortLabel}",
            f"longLabel {self.longLabel}",
            f"visibility {self.visibility}",
        ]
        if self.parent:
            track_strings.insert(1, f"parent {self.parent}")
        for key, value in self.model_dump(
            exclude=[
                "track",
                "bigDataUrl",
                "visibility",
                "shortLabel",
                "longLabel",
                "parent",
            ]
        ).items():
            if value:
                track_strings.append(f"{key} {value}")
        if track_strings:
            track_strings[-1] = track_strings[-1] + "\n"
        return track_strings

    @property
    def text(self):
        return "\n".join(self.parse_track())


class BigBedTrack(Track):
    type: str = "bigBed 3 +"
    itemRgb: str = "on"

    def __init__(self, **data):
        super().__init__(**data)


class BigWigTrack(Track):
    type: str = "bigWig"
    autoScale: str = "on"
    maxHeightPixels: Optional[str] = "128:35:11"
    viewLimits: Optional[str] = None
    alwaysZero: str = "on"
    graphTypeDefault: str = "bar"
    smoothingWindow: Union[str, int] = "off"
    windowingFunction: str = "mean"

    def __init__(self, **data):
        super().__init__(**data)
        if isinstance(self.smoothingWindow, int) and not (
            1 <= self.smoothingWindow <= 16
        ):
            raise ValueError("smoothingWindow must be between 1 and 16")
        if isinstance(
            self.smoothingWindow, str
        ) and self.smoothingWindow not in ["off", "on"]:
            raise ValueError(
                """smoothingWindow must be one of 'off', 'on',
                or int between 1-16"""
            )


class SuperTrack(BaseModel):
    track: str = Field(default_factory=create_track_hash)
    superTrack: str = "on show"
    shortLabel: Optional[str] = None
    longLabel: Optional[str] = None
    tracks: List[Union[Track, BigWigTrack]] = []

    def __init__(self, **data):
        super().__init__(**data)
        if self.shortLabel is None:
            self.shortLabel = self.track
        if self.longLabel is None:
            self.longLabel = self.shortLabel
        self.shortLabel = self.shortLabel[:17]

    def add_track(self, track: Track):
        track.parent = self.track
        self.tracks.append(track)

    def add_tracks_w_pattern(self, pattern: str, track_type: Track, **kwargs):
        for file in glob.iglob(pattern):
            log.info(f"adding track: {file}")
            self.add_track(track_type(bigDataUrl=file, **kwargs))

    def parse_track(self):
        track_strings = []
        for key, value in self.model_dump(
            include=["track", "superTrack", "shortLabel", "longLabel"]
        ).items():
            if value:
                track_strings.append(f"{key} {value}")
        if track_strings:
            track_strings[-1] = track_strings[-1] + "\n"
        for track in self.tracks:
            track_strings.extend(track.parse_track())
        if track_strings:
            comment_header = (
                pad_string_with_char(
                    original_string=self.track, total_length=72, pad_char="#"
                )
                + "\n"
            )
            track_strings.insert(0, comment_header)
            track_strings.append(f"{'#' * 72}\n")
        return track_strings

    @property
    def text(self):
        return "\n".join(self.parse_track())


class TrackHub(BaseModel):
    hub: str
    shortLabel: str = None
    longLabel: str = None
    useOneFile: str = "on"
    email: str = "example@google.com"
    genome: str = "<FILL IN>"
    tracks: List[Union[Track, SuperTrack]] = []

    def __init__(self, **data):
        super().__init__(**data)
        if self.shortLabel is None:
            self.shortLabel = self.hub
        if self.longLabel is None:
            self.longLabel = self.shortLabel
        self.shortLabel = self.shortLabel[:17]

    def add_track(self, track: Union[Track, SuperTrack]):
        self.tracks.append(track)

    def parse_hub(self):
        hub_strings = [
            f"hub {self.hub}",
            f"shortLabel {self.shortLabel}",
            f"longLabel {self.longLabel}",
            f"useOneFile {self.useOneFile}",
            f"email {self.email}",
            f"\ngenome {self.genome}\n",
        ]
        for track in self.tracks:
            hub_strings.extend(track.parse_track())
        return hub_strings

    def write_hub_file(self, path: str = "hub.txt"):
        hub_contents = self.parse_hub()
        with open(path, "w") as f:
            log.info(f"writing hub file: {path}")
            f.write("\n".join(hub_contents))

    @property
    def text(self):
        return "\n".join(self.parse_hub())


def main(args):
    hub = TrackHub(
        hub=args.hub,
        genome=args.genome,
        email=args.email,
        shortLabel=args.shortLabel,
        longLabel=args.longLabel,
    )
    if args.dt_bigwig:
        supertrack = SuperTrack(
            track="deeptools_bigwig",
            shortLabel="DeepTools Signal",
            longLabel="Signal tracks generated by DeepTools",
        )
        supertrack.add_tracks_w_pattern(
            pattern=args.dt_bigwig,
            track_type=BigWigTrack,
            visibility="full",
            color="0,0,0",
        )
        hub.add_track(supertrack)

    if args.encode_bigwig:
        supertrack = SuperTrack(
            track="encode_bigwig",
            shortLabel="ENCODE Signal",
            longLabel="Signal tracks generated by ENCODE",
        )
        supertrack.add_tracks_w_pattern(
            pattern=args.encode_bigwig,
            track_type=BigWigTrack,
            visibility="full",
            color="0,0,0",
        )
        hub.add_track(supertrack)
    if args.idr_peaks:
        supertrack = SuperTrack(
            track="encode_idr",
            shortLabel="IDR Peaks",
            longLabel="IDR Peaks called by ENCODE",
        )
        supertrack.add_tracks_w_pattern(
            pattern=args.idr_peaks, track_type=BigBedTrack, visibility="dense"
        )
        hub.add_track(supertrack)
    if args.overlap_peaks:
        supertrack = SuperTrack(
            track="encode_overlap",
            shortLabel="Overlap Peaks",
            longLabel="Overlap Peaks called by ENCODE",
        )
        supertrack.add_tracks_w_pattern(
            pattern=args.overlap_peaks,
            track_type=BigBedTrack,
            visibility="dense",
        )
        hub.add_track(supertrack)
    hub.write_hub_file(path=args.output)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--hub", default="TrackHub")
    parser.add_argument("--genome", default="<FILL IN>")
    parser.add_argument("--email", default="example@google.com")
    parser.add_argument("--shortLabel", default="Track Hub")
    parser.add_argument("--longLabel", default="Track Hub")
    parser.add_argument("--output", default="hub.txt")
    parser.add_argument("--dt_bigwig", type=str, default=None)
    parser.add_argument("--encode_bigwig", type=str, default=None)
    parser.add_argument("--idr_peaks", type=str, default=None)
    parser.add_argument("--overlap_peaks", type=str, default=None)
    parser.add_argument(
        "-v", "--version", action="version", version=__version__
    )
    args = parser.parse_args()

    main(args)
