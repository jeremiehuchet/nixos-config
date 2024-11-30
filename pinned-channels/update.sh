#!/usr/bin/env bash
set -e

# nix-prefetch-github generates a json "lock" file.
# We use jq to add a 'ref' attribute to remember the branch we are tracking.

cd "$(dirname "$0")"

nix_prefetch_github="$(nix-shell -p nix-prefetch-github --run "command -v nix-prefetch-github" 2> /dev/null)"

function update_lockfile() {
  local lockfile=$1
  local owner=$(jq -r .owner "$lockfile")
  local repo=$(jq -r .repo "$lockfile")
  local ref=$(jq -r .ref "$lockfile")
  local rev=$(jq -r .rev "$lockfile")

  echo -n "$owner/$repo ($ref) "

  latest_rev=$(curl -L https://api.github.com/repos/$owner/$repo/commits/$ref 2> /dev/null | jq -r '.sha')
  if [ "_$rev" != "_$latest_rev" ] ; then
   new_lockfile_content=$(
     $nix_prefetch_github $owner $repo --rev $ref \
      | jq --arg ref "$ref" '.ref = $ref' \
      | jq 'del(.fetchSubmodules)' \
      | jq --sort-keys
    )
    echo "$new_lockfile_content" > "$lockfile"
    echo "⬆ ${latest_rev:0:7}"
  else
    echo "✅"
  fi
}

if [ $# -eq 1 ] && [ "_$1" == "_nur" ] ; then
  update_lockfile nur-packages.json
else
  for lockfile in *.json ; do
    update_lockfile "$lockfile"
  done
fi

