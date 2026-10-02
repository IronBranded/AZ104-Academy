#!/usr/bin/env bash
# check-templates.sh - build and lint Bicep files, validate ARM JSON templates.
# Runs in CI (.github/workflows/bicep.yml) and locally: needs the Bicep CLI on PATH.
set -euo pipefail
shopt -s globstar nullglob
cd "$(dirname "$0")/.."

fail=0
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

for f in labs/**/*.bicep; do
  if bicep build "$f" --stdout > /dev/null && bicep lint "$f"; then echo "ok    bicep      $f"
  else echo "FAIL  bicep      $f"; fail=1; fi
done

for f in labs/**/*.bicepparam; do
  if bicep build-params "$f" --stdout > /dev/null; then echo "ok    bicepparam $f"
  else echo "FAIL  bicepparam $f"; fail=1; fi
done

for f in labs/**/templates/**/*.json; do
  if ! python3 -m json.tool "$f" > /dev/null; then echo "FAIL  json       $f"; fail=1; continue; fi
  case "$f" in
    *.parameters.json) echo "ok    params     $f" ;;
    *)
      # Decompiling proves the file is a well-formed ARM template. Copy it first:
      # decompile writes a .bicep next to its input.
      name="$(echo "$f" | tr '/' '_')"
      cp "$f" "$work/$name"
      if bicep decompile "$work/$name" > /dev/null 2>&1; then echo "ok    arm        $f"
      else echo "FAIL  arm        $f"; fail=1; fi ;;
  esac
done

exit "$fail"
