#!/bin/bash
# Exports a self-contained, runnable solarchvision_bim application into
# dist/<variant>/ - bundling a full Java runtime via Processing's own
# --export (https://github.com/processing/processing4/wiki/Command-Line),
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
# Also trims --export's own output down some: just solarchvision_bim.java
# out of source/ (not the 140+ .pde files alongside it), a handful of
# library jars confirmed unused by anything this app's dependency graph
# actually references, and only the platform-native jars this variant
# itself needs rather than every platform jogl/gluegen support - see the
# loop below for the specifics and how each was actually verified safe.
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
#   NO_JAVA           - on (1) by default: skips bundling Java (--export's
#                       own --no-java), cutting the output from ~395MB to
#                       ~25MB per variant (input/ above is unaffected
#                       either way - it's not part of this). Set to 0 to
#                       bundle Java instead, for a larger, no-install-
#                       needed-at-all result. Whoever runs a NO_JAVA
#                       build needs their own Java 17+ already installed
#                       - and specifically NOT a "headless" JRE package
#                       (e.g. Debian/Ubuntu's openjdk-*-jre-headless,
#                       common on servers/minimal installs/CI images):
#                       confirmed directly, a headless build's java works
#                       fine for everything else but is missing
#                       libawt_xawt.so/libjawt.so, so it can't open a
#                       window at all, DISPLAY set or not, Xvfb or a real
#                       X session alike - "Cannot run sketch without a
#                       display" regardless. Most desktop installs of
#                       Windows and macOS have no Java at all by default
#                       either. On by default for exactly this reason -
#                       most people running this script want the small,
#                       fast result, same as this repo's own CI (see
#                       dist.yml's bundle_java, unticked by default)
#                       rather than bundling Java sight unseen.
set -euo pipefail
cd "$(dirname "$0")"   # repo root

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.5.2}"
SKETCH_DIR="app/src/solarchvision_bim"
DIST_DIR="${DIST_DIR:-dist}"

if [ "${NO_JAVA:-1}" = "1" ]; then
  echo "==> Building without a bundled Java runtime (the default - set NO_JAVA=0 to bundle one instead). See this script's own comment on what that requires of whoever runs the result."
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

# "processing-4.5.2-1435" -> "4.5.2", for version.json below - which
# exact Processing build a dist came from matters for reproducing an
# export, same reason the git commit does.
PROCESSING_VERSION_STRING="$("$PROCESSING_BIN" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
PROCESSING_VERSION_STRING="${PROCESSING_VERSION_STRING:-unknown}"

# Wiped clean here - once Processing itself is confirmed available, not
# any earlier - rather than just each variant's own $OUT right before
# exporting into it below. Otherwise a stale dist/windows-amd64/ (say)
# from an earlier run that built every variant would just sit there
# untouched by a later run that only asks for linux-amd64, left looking
# like part of this run's own output. Waiting until here specifically
# means a run that fails this early (Processing missing, say) leaves a
# previous good dist/ alone, rather than wiping it out for a build that
# was never going to happen anyway.
rm -rf "$DIST_DIR"

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

RELEASE_DATE="$(date -u +%Y-%m-%d)"
RELEASE_VERSION="$RELEASE_DATE-$GIT_COMMIT_SHORT"

for VARIANT in "${VARIANTS[@]}"; do
  OUT="$DIST_DIR/$VARIANT"

  EXPORT_EXTRA_FLAGS=()
  if [ "${NO_JAVA:-1}" = "1" ]; then
    EXPORT_EXTRA_FLAGS+=(--no-java)
  fi
  case "$VARIANT" in
    macos-*)
      if [ "${NO_JAVA:-1}" != "1" ]; then
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

  # Same macOS exception as data/ above: a lib/ subfolder for
  # linux-amd64/windows-amd64 (confirmed present either way, Java
  # bundled or not - see run below), but no such subfolder for macOS -
  # its jars sit directly under Contents/Java/ instead.
  case "$VARIANT" in
    macos-*) JAR_DIR="$ASSET_ROOT" ;;
    *)       JAR_DIR="$ASSET_ROOT/lib" ;;
  esac

  # Only solarchvision_bim.java (the preprocessed source --export already
  # compiles from) - not the 140+ individual .pde files alongside it,
  # which add nothing a person running this build needs.
  find "$OUT" -path "*/source/*.pde" -delete

  # Same org.apache.commons.(io|compress).*.*; wildcard imports as the
  # rm -f block below removes whole jars for, trimmed here from the
  # shipped solarchvision_bim.java text itself too - cosmetic only
  # (solarchvision_bim.jar is already compiled by this point, so this
  # can't change what runs, only what reading this file afterward looks
  # like), but the same 50+ wildcard lines importing entire unrelated
  # library trees for a single class actually used are exactly as much
  # noise here as in the jar list below. The narrower, explicit import
  # of that one class (BZip2CompressorInputStream) doesn't end in a
  # literal "*;", so this leaves it (and everything else) untouched -
  # confirmed with a before/after diff, not just assumed.
  JAVA_FILE="$(find "$OUT" -name "solarchvision_bim.java")"
  sed -i -E '/^import org\.apache\.commons\.(io|compress)\.[A-Za-z0-9_.]*\*;$/d' "$JAVA_FILE"

  # Processing's own preprocessor injects a fixed, broad set of default
  # imports into every sketch's generated .java - org.apache.commons.
  # compress.* and org.apache.commons.io.* among them, covering dozens of
  # subpackages neither this sketch nor anything it depends on actually
  # uses (compare solarchvision_bim.pde's own, much narrower explicit
  # import list - just one commons-compress class, BZip2CompressorInputStream,
  # genuinely gets used, in download_ENSEMBLE_FORECAST.pde). --export's
  # dependency resolution follows those wildcard imports literally,
  # bundling entire unrelated libraries (plus, in commons-io/commons-
  # compress's case, fetching a redundant newer copy alongside an older
  # one already available locally) as a result.
  #
  # Confirmed directly before trusting this, both ways: scanned every
  # .class file actually shipped (this sketch's own jar, plus every
  # library jar being kept) for references to each package removed below
  # - zero hits anywhere in the dependency graph for batik or kotlin, and
  # the one commons-compress class genuinely used needs exactly one
  # commons-io class in turn (CloseShieldInputStream) - present in the
  # newer commons-io jar kept here, not the older, SVG-library-only one
  # removed. Then actually ran the result afterward: a generic script
  # and, specifically, a PDF export (the one feature most at risk, since
  # itext's own classes do reference bouncycastle - but only for
  # signing/timestamping, a code path this app never reaches) both
  # produced correct output.
  # Each its own full, self-contained line on purpose (not one rm -f
  # with a \-continuation per file) - copying just one line of a
  # continued command, or missing a \, silently runs something other
  # than what was intended; a plain rm -f line always does exactly what
  # it says, copied alone or all four together.
  rm -f "$JAR_DIR/batik-all-1.19.jar"
  rm -f "$JAR_DIR/commons-io-2.17.0.jar"
  rm -f "$JAR_DIR/kotlin-stdlib-2.3.21.jar"
  rm -f "$JAR_DIR/bcprov-jdk14-138.jar" # byte-identical to bcprov-jdk14-1.38.jar (md5sum confirmed) - that one's kept

  # jogl/gluegen's native-library jars are bundled for every platform
  # they support, every time, regardless of which one --variant is
  # actually targeting - only the one matching this variant's own native
  # suffix ("macosx-universal" covers both macOS variants, a single
  # universal binary) is needed here.
  case "$VARIANT" in
    linux-amd64)   NATIVES_SUFFIX=linux-amd64 ;;
    windows-amd64) NATIVES_SUFFIX=windows-amd64 ;;
    macos-*)       NATIVES_SUFFIX=macosx-universal ;;
    *)             NATIVES_SUFFIX="" ;;
  esac
  if [ -n "$NATIVES_SUFFIX" ]; then
    find "$JAR_DIR" -maxdepth 1 -name "*-natives-*.jar" ! -name "*-natives-$NATIVES_SUFFIX.jar" -delete
  fi

  # All four below land at $OUT itself (not $ASSET_ROOT) even for macOS,
  # so they sit right next to solarchvision_bim.app where someone
  # unzipping this would actually see them, rather than buried inside
  # the bundle.
  cat > "$OUT/version.json" << EOF
{
  "name": "solarchvision_bim",
  "version": "$RELEASE_VERSION",
  "processingVersion": "$PROCESSING_VERSION_STRING",
  "commit": "$GIT_COMMIT",
  "commitShort": "$GIT_COMMIT_SHORT",
  "branch": "$GIT_BRANCH",
  "dirty": $GIT_DIRTY,
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
