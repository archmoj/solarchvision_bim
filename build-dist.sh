#!/bin/bash
# Exports a self-contained, runnable solarchvision_bim application into
# dist/<variant>/ - bundling a full Java runtime via Processing's own
# --export (https://github.com/processing/processing4/wiki/Command-Line),
# so the result runs with no Processing, and no separate Java, install
# needed - plus the input/ (a selected subset - see the loop below),
# command/, projects/, import/ folders solarchvision_bim resolves
# relative to its own install directory at runtime (BaseFolder =
# sketchPath() - see update_folders.pde), which --export alone doesn't
# know to include, since they live at the repo root rather than inside
# the sketch's own data/ folder (only data/, here just data/font/, gets
# bundled automatically). Confirmed by actually running an export before
# this script existed: it starts, but throws immediately trying to load
# input/images/sun/Sun.jpg without this.
#
# Same idea as run-with-latest-processing.sh's own input/command/projects
# symlinks for a live dev run from this repo - except these are real
# copies (cp, not ln), since a dist build is meant to be moved/zipped/
# handed to someone else entirely, not left pointing back at this
# checkout.
#
# Also writes a version.json at the root of each variant - which repo
# state (commit, branch, whether the working tree was clean) it was
# built from, since nothing else in the dist folder says that once it's
# been unzipped somewhere on its own - and copies LICENSE.md,
# package.json, README.md and CITATION.cff there too (the last with
# version/date-released filled in, since the committed one deliberately
# leaves those out - see the loop below).
#
# Usage:
#   ./build-dist.sh                       # every variant below
#   ./build-dist.sh linux-amd64           # just one (or a few)
#
# Variants (Processing's own --variant names - see `Processing cli --help`):
#   linux-amd64, windows-amd64, macos-x86_64, macos-aarch64
#
# The two macOS variants need --no-java specifically (always applied for
# them below, regardless of the NO_JAVA setting otherwise in effect) -
# embedding Java into a macOS export hits a known bug in Processing
# itself (java.util.NoSuchElementException in JavaBuild.exportApplication,
# reported even for a *native* macOS export with some Processing
# versions - https://github.com/processing/processing4/issues/1193),
# confirmed directly here too: --variant=macos-aarch64 --export (java
# embedded) throws partway through and leaves a broken, incomplete
# solarchvision_bim.app; the exact same command plus --no-java instead
# produces a complete, correctly structured one (valid Info.plist, a
# real Mach-O launcher) - cross-exported from this Linux host, which
# Processing's own wiki otherwise says needs an actual Mac
# (https://github.com/processing/processing4/wiki/Exporting-Applications
# - true for a *signed* export, apparently not for this unsigned,
# Java-less one). Unsigned means Gatekeeper will still flag it on
# first launch - right-click -> Open (not a double-click) the first
# time sidesteps that without needing to actually sign it.
#
# Requires Processing 4.5.x+ (the --export flag doesn't exist in the
# legacy <=4.4.x processing-java CLI - see test/README.md's "Setup:
# Processing 4.5.x" for the two generations' differences).
#
# Environment:
#   PROCESSING_HOME   - defaults to ~/processing/4.5.2, same as
#                       run-with-latest-processing.sh and test/run_tests.sh.
#   DIST_DIR          - defaults to dist/
#   NO_JAVA           - set to 1 to skip bundling Java (--export's own
#                       --no-java), cutting the output from ~395MB to
#                       ~25MB per variant (input/ above is unaffected
#                       either way - it's not part of this). Whoever runs
#                       the result then needs their own Java 17+ already
#                       installed - and specifically NOT a "headless" JRE
#                       package (e.g. Debian/Ubuntu's openjdk-*-jre-headless,
#                       common on servers/minimal installs/CI images):
#                       confirmed directly, a headless build's java works
#                       fine for everything else but is missing
#                       libawt_xawt.so/libjawt.so, so it can't open a
#                       window at all, DISPLAY set or not, Xvfb or a real
#                       X session alike - "Cannot run sketch without a
#                       display" regardless. Most desktop installs of
#                       Windows and macOS have no Java at all by default
#                       either. Off by default for exactly this reason -
#                       most people downloading a dist build want it to
#                       just work, not to debug which JRE variant they
#                       happen to have.
set -euo pipefail
cd "$(dirname "$0")"   # repo root

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.5.2}"
SKETCH_DIR="app/src/solarchvision_bim"
DIST_DIR="${DIST_DIR:-dist}"

if [ "${NO_JAVA:-0}" = "1" ]; then
  echo "==> NO_JAVA=1: building without a bundled Java runtime - see this script's own comment on what that requires of whoever runs the result."
fi

# Windows' portable build lays out one directory level shallower than
# Linux/macOS's (Processing.exe directly at the install root, no bin/
# wrapper) - see run-with-latest-processing.bat's own comment on this
# same difference.
if [ -x "$PROCESSING_HOME/bin/Processing" ]; then
  PROCESSING_BIN="$PROCESSING_HOME/bin/Processing"
elif [ -x "$PROCESSING_HOME/Processing.exe" ]; then
  PROCESSING_BIN="$PROCESSING_HOME/Processing.exe"
else
  echo "error: no bin/Processing or Processing.exe found under $PROCESSING_HOME" >&2
  echo "       --export needs Processing 4.5.x+ - set PROCESSING_HOME to that install." >&2
  exit 1
fi

if [ "$#" -ge 1 ]; then
  VARIANTS=("$@")
else
  VARIANTS=(linux-amd64 windows-amd64 macos-x86_64 macos-aarch64)
fi

# What repo state each dist build came from - written as version.json
# at the root of every variant below (not package.json: nothing here
# reads it as an npm manifest, and that name would suggest otherwise).
GIT_COMMIT="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
GIT_COMMIT_SHORT="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
GIT_DIRTY=false
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
  GIT_DIRTY=true
fi

# git@host:owner/repo.git and https://host/owner/repo.git both normalize
# to a plain, browsable https URL. The host:path -> host/path swap has
# to happen before https:// is prepended, not after - otherwise it's the
# colon in that https:// itself that ends up replaced, not the intended
# one between host and path (caught by testing this against a real
# git@... remote, not just this repo's own https:// one).
REPO_URL="$(git remote get-url origin 2>/dev/null || echo "")"
REPO_URL="${REPO_URL%.git}"
if [[ "$REPO_URL" == git@*:* ]]; then
  HOST_AND_PATH="${REPO_URL#git@}"
  HOST_AND_PATH="${HOST_AND_PATH/:/\/}"
  REPO_URL="https://$HOST_AND_PATH"
fi

COMMIT_URL=""
if [ -n "$REPO_URL" ] && [ "$GIT_COMMIT" != "unknown" ]; then
  COMMIT_URL="$REPO_URL/commit/$GIT_COMMIT"
fi

BUILT_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
RELEASE_DATE="$(date -u +%Y-%m-%d)"
RELEASE_VERSION="$RELEASE_DATE-$GIT_COMMIT_SHORT"

for VARIANT in "${VARIANTS[@]}"; do
  OUT="$DIST_DIR/$VARIANT"

  EXPORT_EXTRA_FLAGS=()
  if [ "${NO_JAVA:-0}" = "1" ]; then
    EXPORT_EXTRA_FLAGS+=(--no-java)
  fi
  case "$VARIANT" in
    macos-*)
      if [ "${NO_JAVA:-0}" != "1" ]; then
        echo "==> $VARIANT: forcing --no-java - embedding Java breaks macOS exports (see this script's own comment above)."
      fi
      EXPORT_EXTRA_FLAGS=(--no-java)
      ;;
  esac

  echo "==> Exporting $VARIANT to $OUT"
  rm -rf "$OUT"
  "$PROCESSING_BIN" cli --sketch="$SKETCH_DIR" --output="$OUT" --force --variant="$VARIANT" "${EXPORT_EXTRA_FLAGS[@]}" --export

  # Where BaseFolder = sketchPath() (see update_folders.pde) resolves to
  # - alongside data/ (the sketch's own bundled data, already present:
  # data/font/ on every variant) is the one part of this confirmed by
  # directly running the result, for linux-amd64/windows-amd64 (see
  # test/image/make_baseline.sh-style smoke test this script's own
  # history was verified with). For macOS the app bundle nests data/
  # under Contents/Java/ instead of the top level - inferred from that
  # same placement (not independently verified by actually running a
  # macOS build, which isn't possible from here), rather than guessed
  # from nothing.
  case "$VARIANT" in
    macos-*) ASSET_ROOT="$OUT/solarchvision_bim.app/Contents/Java" ;;
    *)       ASSET_ROOT="$OUT" ;;
  esac

  echo "==> Adding input/ (selected folders only), command/, projects/, import/ to $ASSET_ROOT"
  # Not all of input/ (345MB in full - this selection comes to ~184MB):
  # the climate datasets (the biggest single piece, CWEEDS alone is
  # 143MB) are created empty instead, since update_folders.pde only ever
  # points Folder_climate*
  # at these as plain paths - nothing reads from them until a person
  # explicitly loads a climate scenario that needs one, unlike
  # coordinates/ and the images/ subfolders below, which real everyday
  # use (a plain 3D scene with the sun/moon/people/trees in it) does
  # touch right away. input/images/earth_high_res and input/images/logo
  # are left out too, for the same "not needed for a basic run" reason.
  mkdir -p \
    "$ASSET_ROOT/input/climate/CWEEDS" \
    "$ASSET_ROOT/input/climate/CLMREC" \
    "$ASSET_ROOT/input/climate/TMYEPW" \
    "$ASSET_ROOT/input/climate/NAEFS"
  cp -r input/coordinates "$ASSET_ROOT/input/coordinates"
  mkdir -p "$ASSET_ROOT/input/images"
  for IMG_FOLDER in worldmap earth moon sun people trees; do
    cp -r "input/images/$IMG_FOLDER" "$ASSET_ROOT/input/images/$IMG_FOLDER"
  done

  cp -r command "$ASSET_ROOT/command"
  mkdir -p "$ASSET_ROOT/projects" "$ASSET_ROOT/import"

  # All four below land at $OUT itself (not $ASSET_ROOT) even for macOS,
  # so they sit right next to solarchvision_bim.app where someone
  # unzipping this would actually see them, rather than buried inside
  # the bundle.
  cat > "$OUT/version.json" << EOF
{
  "name": "solarchvision_bim",
  "version": "$RELEASE_VERSION",
  "variant": "$VARIANT",
  "commit": "$GIT_COMMIT",
  "commitShort": "$GIT_COMMIT_SHORT",
  "branch": "$GIT_BRANCH",
  "dirty": $GIT_DIRTY,
  "builtAt": "$BUILT_AT",
  "repository": "$REPO_URL",
  "commitUrl": "$COMMIT_URL"
}
EOF

  cp LICENSE.md "$OUT/LICENSE.md"
  cp package.json "$OUT/package.json"
  # The whole thing, not an extract - most of it (GUI usage, keyboard
  # shortcuts, the command line) is exactly what someone running a
  # downloaded build would want, and the rest (cloning, building from
  # source) is harmless extra context rather than something worth
  # maintaining a second, trimmed copy just to omit. package.json's own
  # "docs" field points at this and the other READMEs scattered through
  # the repo (command/README.md, etc.) for anyone who wants just one of
  # them.
  cp README.md "$OUT/README.md"

  # CITATION.cff is committed without version/date-released (cff-version
  # 1.2.0 doesn't require either - see
  # https://github.com/citation-file-format/citation-file-format/blob/1.2.0/schema-guide.md)
  # so a citation always names a precise release rather than "whatever
  # the repo's tip happened to be" - added here, append-only, since YAML
  # mappings don't care what order their keys come in.
  {
    cat CITATION.cff
    echo "version: \"$RELEASE_VERSION\""
    echo "date-released: $RELEASE_DATE"
  } > "$OUT/CITATION.cff"

  echo "==> Done: $OUT"
done
