#!/usr/bin/env bash
set -euo pipefail

variant=${1:?Usage: prepare-variant-files.sh <variant>}
if [[ ! "$variant" =~ ^[a-z0-9][a-z0-9-]*$ || ! -f "variants/$variant/recipes/recipe.yml" ]]; then
  echo "Unknown image variant: $variant" >&2
  exit 2
fi

variant_files="variants/$variant/files"
mkdir -p "$variant_files"
cp -a shared/files/. "$variant_files/"
install -m 0644 cosign.pub "$variant_files/strix-halo-server-cosign.pub"
