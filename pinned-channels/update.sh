#!/usr/bin/env bash
set -e

# nix-prefetch-github generates a json "lock" file.
# We use jq to add a 'ref' attribute to remember the branch we are tracking.

cd "$(dirname "$0")"

for lockfile in *.json ; do
  owner=$(jq -r .owner "$lockfile")
  repo=$(jq -r .repo "$lockfile")
  ref=$(jq -r .ref "$lockfile")

  echo -n "$owner/$repo ($ref) "

  nix-shell -p nix-prefetch-github --run \
    "nix-prefetch-github $owner $repo --rev $ref" \
      | jq --arg ref "$ref" '.ref = $ref' \
      | jq 'del(.fetchSubmodules)' \
      | jq --sort-keys \
      > "$lockfile"

  git diff --exit-code "$lockfile" > /dev/null && echo "✅" || echo "⬆"
done