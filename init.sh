#!/bin/zsh
set -euo pipefail

MAPPING_FILE=mapping.json
for mapping in $(jq -rc '.[]' <$MAPPING_FILE); do
	FROM=$(eval echo "$(jq -r '.from' <<<$mapping)")
	TO=$(eval echo "$(jq -r '.to' <<<$mapping)")
	sudo cp $FROM $TO
done
