#!/bin/bash
# Downloads this build's input/ assets (left out by default to keep the
# download small - see build-dist.sh's own INCLUDE_INPUT) from this
# exact build's own commit, read from version.json shipped alongside
# this script, rather than whatever the repository's main branch
# currently is - so what gets installed always matches what this
# particular build was actually tested against.
#
# Needs git: a shallow, blob-filtered, sparse-checkout clone is the only
# practical way to fetch just the ~184MB subset actually used (without
# it, the only alternative is downloading the whole repository - 500MB+
# at this writing - to throw away two thirds of it afterward). Nothing
# else is needed.
set -euo pipefail
cd "$(dirname "$0")"   # this build's own root

if [ -d input ]; then
  echo "input/ is already here - nothing to do (delete it first to re-download)." >&2
  exit 0
fi

if ! command -v git > /dev/null 2>&1; then
  echo "error: git is required to download these assets." >&2
  echo "       install it (https://git-scm.com/downloads), then re-run this script." >&2
  exit 1
fi

if [ ! -f version.json ]; then
  echo "error: version.json is missing - can't tell which commit's assets to fetch." >&2
  exit 1
fi

json_field () {
  grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" version.json \
    | sed -E "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"([^\"]*)\".*/\1/"
}

COMMIT="$(json_field commit)"
REPO_URL="$(json_field repository)"

if [ -z "$COMMIT" ]; then
  echo "error: couldn't read \"commit\" out of version.json." >&2
  exit 1
fi
if [ -z "$REPO_URL" ]; then
  echo "error: couldn't read \"repository\" out of version.json." >&2
  exit 1
fi

echo "==> Fetching input/ from $REPO_URL at $COMMIT"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

git clone --no-checkout --filter=blob:none --quiet "$REPO_URL.git" "$TMP_DIR"
(
  cd "$TMP_DIR"
  git fetch --quiet --depth 1 origin "$COMMIT"
  git sparse-checkout init --cone
  git sparse-checkout set \
    input/coordinates \
    input/images/worldmap \
    input/images/earth \
    input/images/moon \
    input/images/sun \
    input/images/people \
    input/images/trees
  git checkout --quiet FETCH_HEAD
)

# Same selection, same empty-climate-folders convention, as
# build-dist.sh's own INCLUDE_INPUT=1 path - see its comment on why
# those four specifically are left empty rather than fetched too, rather
# than guessing at something different here.
mkdir -p input/climate/CWEEDS input/climate/CLMREC input/climate/TMYEPW input/climate/NAEFS
cp -r "$TMP_DIR/input/coordinates" input/coordinates
mkdir -p input/images
for IMG_FOLDER in worldmap earth moon sun people trees; do
  cp -r "$TMP_DIR/input/images/$IMG_FOLDER" "input/images/$IMG_FOLDER"
done

echo "==> Done - input/ is ready."
