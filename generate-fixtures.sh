#!/bin/bash
set -euo pipefail

fixture_dir="$1"
: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE must be set}"

exec python3 "$GITHUB_WORKSPACE/.hs3suite/tools/build_manifest_and_expected.py" -e -f "$fixture_dir"