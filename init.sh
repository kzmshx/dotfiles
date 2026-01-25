#!/bin/zsh
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
MAPPING_FILE="$SCRIPT_DIR/mapping.json"

for mapping in $(jq -rc '.[]' <"$MAPPING_FILE"); do
	FROM="$SCRIPT_DIR/$(jq -r '.from' <<<$mapping)"
	TO=$(eval echo "$(jq -r '.to' <<<$mapping)")

	# Create parent directory if needed
	mkdir -p "$(dirname "$TO")"

	# Create symlink (overwrite if exists)
	ln -sf "$FROM" "$TO"
	echo "Linked: $FROM -> $TO"
done
