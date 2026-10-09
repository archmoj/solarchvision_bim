#!/bin/bash
# Run after build-dist.sh, against its output: copies each variant's own
# executable up to dist/ itself, renamed by platform -
# solarchvision_bim_<variant> - and merges every variant's lib/ jars and
# data/ (data/font/selawk.ttf, required - without it anywhere nearby
# the app throws "A null PFont was passed to textFont()" on startup,
# confirmed directly by actually running a relocated executable before
# data/ was added here too) into one shared dist/lib/ and dist/data/,
# rather than leaving each variant with its own separate copy of
# mostly the same files.
#
# .exe (Windows) and .app (macOS) keep that extension on the renamed
# copy - dropping it would stop the OS recognizing either as something
# it can run at all, not just a cosmetic rename. The macOS .app bundles
# are copied whole, jars and all (they're self-contained - see
# build-dist.sh's own comment on where Contents/Java/ sits), so neither
# depends on dist/lib/ to run; only linux-amd64's and windows-amd64's
# single-file executables do.
#
# Merging works because of two things confirmed directly before relying
# on them, not assumed: the launcher that --export produces (plain
# shell script on Linux, equivalent on Windows) resolves its own lib/
# relative to wherever *it* actually sits, not a path baked in at
# export time - so moving the executable up a level and giving it a
# dist/lib/ sibling instead of dist/<variant>/lib/ still works. And the
# jars that would otherwise just be duplicated four times over -
# core-4.5.2.jar, commons-compress-1.28.0.jar, this app's own
# solarchvision_bim.jar, etc. - are the exact same bytes in every
# variant (diffed the fully extracted contents of two variants'
# solarchvision_bim.jar against each other to be sure - identical,
# despite the outer jar's own checksum differing slightly, which just
# turned out to be zip packaging noise - entry timestamps, not content).
# Only each platform's own native jars (jogl/gluegen) are genuinely
# different per variant, and those are already uniquely named per
# platform (e.g. jogl-all-2.6.0-natives-windows-amd64.jar), so they
# simply coexist in the shared folder rather than colliding - every
# variant's launcher already lists every platform's native jar by name
# on its own classpath regardless (Java silently skips a classpath
# entry that isn't there), so having all four platforms' worth
# available in dist/lib/ doesn't change which one actually loads.
#
# data/'s own single font file is identical across every variant too
# (md5sum-confirmed, the same reasoning as the jars above), so merging
# it the same way is just as safe.
#
# Doesn't remove the dist/<variant>/ folders this reads from - purely
# additive on top of whatever build-dist.sh already produced there.
#
# Usage:
#   ./build-dist.sh && ./flatten-dist.sh        # every variant
#   ./build-dist.sh linux-amd64 && ./flatten-dist.sh linux-amd64
#   (same variant list both times, or omit on both for every variant)
set -euo pipefail
cd "$(dirname "$0")"   # repo root

DIST_DIR="${DIST_DIR:-dist}"

if [ "$#" -ge 1 ]; then
  VARIANTS=("$@")
else
  VARIANTS=(linux-amd64 windows-amd64 macos-x86_64 macos-aarch64)
fi

mkdir -p "$DIST_DIR/lib" "$DIST_DIR/data"

for VARIANT in "${VARIANTS[@]}"; do
  SRC="$DIST_DIR/$VARIANT"
  if [ ! -d "$SRC" ]; then
    echo "error: $SRC not found - run build-dist.sh $VARIANT first" >&2
    exit 1
  fi

  case "$VARIANT" in
    windows-amd64)
      EXE="$SRC/solarchvision_bim.exe"
      DEST="$DIST_DIR/solarchvision_bim_$VARIANT.exe"
      JAR_DIR="$SRC/lib"
      DATA_DIR="$SRC/data"
      ;;
    macos-*)
      EXE="$SRC/solarchvision_bim.app"
      DEST="$DIST_DIR/solarchvision_bim_$VARIANT.app"
      JAR_DIR="$SRC/solarchvision_bim.app/Contents/Java"
      DATA_DIR="$JAR_DIR/data"
      ;;
    *)
      EXE="$SRC/solarchvision_bim"
      DEST="$DIST_DIR/solarchvision_bim_$VARIANT"
      JAR_DIR="$SRC/lib"
      DATA_DIR="$SRC/data"
      ;;
  esac

  if [ ! -e "$EXE" ]; then
    echo "error: $EXE not found - run build-dist.sh $VARIANT first" >&2
    exit 1
  fi

  echo "==> Copying $EXE to $DEST"
  rm -rf "$DEST"
  cp -r "$EXE" "$DEST"

  echo "==> Merging $JAR_DIR/*.jar into $DIST_DIR/lib/"
  cp "$JAR_DIR"/*.jar "$DIST_DIR/lib/"

  echo "==> Merging $DATA_DIR/* into $DIST_DIR/data/"
  cp -r "$DATA_DIR"/. "$DIST_DIR/data/"
done

echo "==> Done: $DIST_DIR/solarchvision_bim_<variant>[.exe|.app], $DIST_DIR/lib/, $DIST_DIR/data/"
