#!/usr/bin/env python3
"""Compare test/image/actual/*.png against test/image/baseline/*.png,
pixel-by-pixel, and write red-highlighted diffs to test/image/diff/.

Usage:
  python3 test/image/compare_pixels.py                 # compare every test/image/actual/*.png that exists
  python3 test/image/compare_pixels.py test_houses ...  # compare specific ones only (name without .txt)
  python3 test/image/compare_pixels.py --threshold 1.0  # allow up to 1% of pixels to differ (default 0.5)
  python3 test/image/compare_pixels.py --allow-missing-baseline  # warn instead of fail when a baseline
                                                                  # doesn't exist yet (handy for local, first-time runs)

Requires: Pillow, numpy.
"""
import argparse
import glob
import os
import sys

from PIL import Image, ImageChops
import numpy as np

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
IMAGE_TEST_DIR = os.path.join(REPO_ROOT, "test", "image")
ACTUAL_DIR = os.path.join(IMAGE_TEST_DIR, "actual")
BASELINE_DIR = os.path.join(IMAGE_TEST_DIR, "baseline")
DIFF_DIR = os.path.join(IMAGE_TEST_DIR, "diff")


def discover_names():
    paths = sorted(glob.glob(os.path.join(ACTUAL_DIR, "*.png")))
    return [os.path.splitext(os.path.basename(p))[0] for p in paths]


def compare_one(name, threshold, pixel_tolerance, allow_missing_baseline):
    actual_path = os.path.join(ACTUAL_DIR, name + ".png")
    baseline_path = os.path.join(BASELINE_DIR, name + ".png")
    diff_path = os.path.join(DIFF_DIR, name + ".png")

    if not os.path.isfile(actual_path):
        print(f"  SKIP: no actual image at {actual_path} (make_baseline.py did not produce one)")
        return "skipped"

    if not os.path.isfile(baseline_path):
        msg = f"no baseline at {baseline_path} (run make_baseline.py --baseline once it looks right, review it, then commit it)"
        if allow_missing_baseline:
            print(f"  WARN: {msg}")
            return "skipped"
        print(f"  FAIL: {msg}")
        return "failed"

    try:
        baseline = Image.open(baseline_path).convert("RGB")
        actual = Image.open(actual_path).convert("RGB")
    except Exception as exc:
        print(f"  FAIL: could not open image(s): {exc}")
        return "failed"

    if baseline.size != actual.size:
        print(f"  FAIL: size mismatch baseline={baseline.size} actual={actual.size}")
        ImageChops.difference(baseline, actual.resize(baseline.size)).save(diff_path)
        return "failed"

    b = np.asarray(baseline, dtype=np.int16)
    a = np.asarray(actual, dtype=np.int16)
    per_pixel_diff = np.abs(b - a).max(axis=2)  # worst channel per pixel
    differing = per_pixel_diff > pixel_tolerance
    pct_diff = 100.0 * differing.sum() / differing.size

    if pct_diff > threshold:
        diff_img = np.array(baseline).copy()
        diff_img[differing] = [255, 0, 0]
        Image.fromarray(diff_img).save(diff_path)
        print(f"  FAIL: {pct_diff:.3f}% of pixels differ (threshold {threshold}%, tolerance {pixel_tolerance}/channel) -> {diff_path}")
        return "failed"

    print(f"  PASS: {pct_diff:.3f}% of pixels differ (threshold {threshold}%, tolerance {pixel_tolerance}/channel)")
    return "passed"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("names", nargs="*", help="test names to compare (default: every test/image/actual/*.png)")
    parser.add_argument("--threshold", type=float, default=float(os.environ.get("IMAGE_DIFF_THRESHOLD", 0.5)),
                         help="max percent of differing pixels allowed (default: 0.5)")
    parser.add_argument("--pixel-tolerance", type=int, default=12,
                         help="per-channel value difference (0-255) below which a pixel still counts as "
                              "matching, to absorb minor antialiasing/compression noise (default: 12)")
    parser.add_argument("--allow-missing-baseline", action="store_true",
                         help="warn instead of fail when a baseline doesn't exist yet")
    args = parser.parse_args()

    os.makedirs(DIFF_DIR, exist_ok=True)

    names = args.names if args.names else discover_names()
    if not names:
        print("No images to compare (run make_baseline.py first).", file=sys.stderr)
        sys.exit(1)

    failed = []
    skipped = []
    for name in names:
        print(f"== {name} ==")
        result = compare_one(name, args.threshold, args.pixel_tolerance, args.allow_missing_baseline)
        if result == "failed":
            failed.append(name)
        elif result == "skipped":
            skipped.append(name)

    print()
    print(f"{len(names) - len(failed) - len(skipped)}/{len(names)} passed")
    if failed:
        print("Failed:", ", ".join(failed))
    if skipped:
        print("Skipped:", ", ".join(skipped))
    if failed or skipped:
        sys.exit(1)


if __name__ == "__main__":
    main()
