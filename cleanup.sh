#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
  echo "Usage: bash cleanup.sh" >&2
  exit 2
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
targets=()

for directory in MyOrg-RootCA myserver; do
  target="${SCRIPT_DIR}/${directory}"
  if [[ -L "$target" || ( -e "$target" && ! -d "$target" ) ]]; then
    echo "[ERROR] Refusing to remove unexpected file or symbolic link: ${target}" >&2
    exit 1
  fi
  if [[ -d "$target" ]]; then
    targets+=("$target")
  fi
done

if [[ ${#targets[@]} -eq 0 ]]; then
  echo "[INFO] No generated directories found. Nothing to remove."
  exit 0
fi

echo "[WARNING] This deletes these directories and ALL their contents, including private keys and certificates:"
printf '  %s\n' "${targets[@]}"
echo "[WARNING] Installed trust store copies are NOT removed."

if ! read -r -p "Type DELETE to confirm: " confirmation || [[ "$confirmation" != DELETE ]]; then
  echo "[INFO] Cancelled. Nothing was removed."
  exit 1
fi

rm -rf -- "${targets[@]}"
echo "[INFO] Generated directories removed."
