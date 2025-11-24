#!/bin/zsh
set -euo pipefail

MAPPING_FILE=mapping.json
for mapping in $(jq -rc '.[]' <$MAPPING_FILE); do
	TO=$(jq -r '.to' <<<$mapping)
	sudo rm $TO
done
