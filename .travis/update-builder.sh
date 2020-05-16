#!/usr/bin/env bash

git_root=$(git rev-parse --show-toplevel)

for i in $(find "$git_root/secrets" -type f) ; do
  file="${i/$git_root\//}"
  echo "mkdir -p '/configuration/$(dirname "$file")'"
  echo "touch '/configuration/$file'"
done

echo 'cat - <<EOF > /configuration/secrets.nix'
sed 's/=.*/= "secret";/g' "$git_root/secrets.nix"
echo EOF
