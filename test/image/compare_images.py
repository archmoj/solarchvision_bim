#!/usr/bin/env python3
"""Compare two images pixel-by-pixel and write a red-highlighted diff image.

Usage:
  compare_images.py <baseline> <actual> <diff_out> [--threshold PCT] [--pixel-tolerance N]

Exits 0 if the percentage of differing pixels is <= --threshold (default
0.5%), and non-zero otherwise. A diff image is always written to <diff_out>
(baseline with differing pixels painted red) so a failure is easy to eyeball,
even when comparison passes.

Requires: Pillow, numpy.
"""
import argparse
import sys

from PIL import Image, ImageChops
import numpy as np


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline")
    parser.add_argument("actual")
    parser.add_argument("diff_out")
    parser.add_argument(
        "--threshold", type=float, default=0.5,
        help="max percent of differing pixels allowed (default: 0.5)")
    parser.add_argument(
        "--pixel-tolerance", type=int, default=12,
        help="per-channel value difference (0-255) below which a pixel still "
             "counts as matching, to absorb minor antialiasing/compression "
             "noise (default: 12)")
    args = parser.parse_args()

    try:
        baseline = Image.open(args.baseline).convert("RGB")
        actual = Image.open(args.actual).convert("RGB")
    except Exception as exc:
        print(f"  FAIL: could not open image(s): {exc}")
        sys.exit(1)

    if baseline.size != actual.size:
        print(f"  FAIL: size mismatch baseline={baseline.size} actual={actual.size}")
        # Best-effort diff so there's still something to look at.
        diff = ImageChops.difference(baseline, actual.resize(baseline.size))
        diff.save(args.diff_out)
        sys.exit(1)

    b = np.asarray(baseline, dtype=np.int16)
    a = np.asarray(actual, dtype=np.int16)

    per_pixel_diff = np.abs(b - a).max(axis=2)  # worst channel per pixel
    differing = per_pixel_diff > args.pixel_tolerance
    pct_diff = 100.0 * differing.sum() / differing.size

    diff_img = np.array(baseline).copy()
    diff_img[differing] = [255, 0, 0]
    Image.fromarray(diff_img).save(args.diff_out)

    passed = pct_diff <= args.threshold
    status = "PASS" if passed else "FAIL"
    print(
        f"  {status}: {pct_diff:.3f}% of pixels differ "
        f"(threshold {args.threshold}%, tolerance {args.pixel_tolerance}/channel) "
        f"-> diff written to {args.diff_out}"
    )

    sys.exit(0 if passed else 1)


if __name__ == "__main__":
    main()
