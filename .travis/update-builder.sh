#!/usr/bin/env bash

git_root=$(git rev-parse --show-toplevel)

echo "mkdir -p '/configuration/secrets'"
for i in $(find "$git_root/secrets" -type f | sort) ; do
  file="${i/$git_root\//}"
  echo "touch '/configuration/$file'"
done

echo 'cat - <<EOF > /configuration/secrets.nix'
sed 's/=.*/= "secret";/g' "$git_root/secrets.nix" | sed 's/.*hosts.*/  hosts = {};/g'
echo EOF
