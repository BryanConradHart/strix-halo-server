#!/usr/bin/env bash
set -euo pipefail

variant=${1:?Usage: prepare-variant-files.sh <variant>}
if [[ ! "$variant" =~ ^[a-z0-9][a-z0-9-]*$ || ! -f "variants/$variant/recipes/recipe.yml" ]]; then
  echo "Unknown image variant: $variant" >&2
  exit 2
fi

variant_files="variants/$variant/files"
mkdir -p "$variant_files"
install -m 0644 shared/files/strix-first-boot.sh "$variant_files/strix-first-boot.sh"
install -m 0644 shared/files/strix-first-boot.service "$variant_files/strix-first-boot.service"
