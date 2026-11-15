#!/bin/zsh
# init.sh: symlink every entry in mapping.json. Safe to re-run.
# A real file or directory already at the destination is moved aside to <dest>.backup-<timestamp> first.
set -euo pipefail

SCRIPT_DIR=${0:A:h}
MAPPING_FILE="$SCRIPT_DIR/mapping.json"
STAMP=$(date +%Y%m%d%H%M%S)

command -v jq &>/dev/null || { echo "init.sh needs jq (run bootstrap.sh, or: brew install jq)" >&2; exit 1 }

jq -r '.[] | [.from, .to] | @tsv' "$MAPPING_FILE" | while IFS=$'\t' read -r from to; do
    FROM="$SCRIPT_DIR/$from"
    TO=${to/#\$\{HOME\}/$HOME}

    if [[ -L $TO && $(readlink "$TO") == "$FROM" ]]; then
        echo "Already linked: $TO"
        continue
    fi
    if [[ -e $TO && ! -L $TO ]]; then
        mv "$TO" "$TO.backup-$STAMP"
        echo "Moved aside: $TO -> $TO.backup-$STAMP"
    fi

    mkdir -p "${TO:h}"
    # -n: replace a link to a directory instead of creating a link inside it
    ln -sfn "$FROM" "$TO"
    echo "Linked: $TO -> $FROM"
done
