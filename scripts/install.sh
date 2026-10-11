#!/usr/bin/env bash
# Installs the homework workflow skills into ~/.cursor/skills.
# Usage:
#   bash scripts/install.sh
#   bash scripts/install.sh --uninstall
set -euo pipefail

names=(homework-shared hw-plan hw-assign hw-hint hw-progress hw-review hw-archive)
source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/skills"
target_dir="$HOME/.cursor/skills"

if [[ "${1:-}" == "--uninstall" ]]; then
  for name in "${names[@]}"; do
    if [[ -e "$target_dir/$name" ]]; then
      rm -rf "${target_dir:?}/$name"
      echo "Removed $target_dir/$name"
    fi
  done
  echo "Uninstall complete."
  exit 0
fi

for name in "${names[@]}"; do
  if [[ ! -d "$source_dir/$name" ]]; then
    echo "Missing source directory: $source_dir/$name" >&2
    exit 1
  fi
done

mkdir -p "$target_dir"

for name in "${names[@]}"; do
  rm -rf "${target_dir:?}/$name"
  cp -R "$source_dir/$name" "$target_dir/$name"
  echo "Installed $name"
done

echo "Done: ${#names[@]} directories installed to $target_dir"
