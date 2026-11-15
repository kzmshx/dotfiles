#!/bin/zsh
# clean.sh: remove the links init.sh created. Only links that point into this repo are removed.
set -euo pipefail

SCRIPT_DIR=${0:A:h}
MAPPING_FILE="$SCRIPT_DIR/mapping.json"

jq -r '.[] | [.from, .to] | @tsv' "$MAPPING_FILE" | while IFS=$'\t' read -r from to; do
    FROM="$SCRIPT_DIR/$from"
    TO=${to/#\$\{HOME\}/$HOME}

    if [[ -L $TO && $(readlink "$TO") == "$FROM" ]]; then
        rm "$TO"
        echo "Removed: $TO"
    elif [[ -e $TO || -L $TO ]]; then
        echo "Skipped (not a link to this repo): $TO"
    fi
done
