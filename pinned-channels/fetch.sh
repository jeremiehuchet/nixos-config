#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

nix_prefetch_github="$(nix-shell -p nix-prefetch-github --run "command -v nix-prefetch-github" 2> /dev/null)"

for lockfile in *.json ; do
  owner=$(jq -r .owner "$lockfile")
  repo=$(jq -r .repo "$lockfile")
  rev=$(jq -r .rev "$lockfile")
  ref=$(jq -r .ref "$lockfile")

  echo -n "$owner/$repo ($ref@$rev) "
  $nix_prefetch_github $owner $repo --rev $rev > /dev/null
  echo "✅"
done
