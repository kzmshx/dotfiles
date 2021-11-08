#!/bin/zsh

MAP=mapping.json

for mapping in $(jq -rc '.[]' <$MAP); do
	FROM=$(eval echo "$(jq -r '.from' <<<$mapping)")
	TO=$(eval echo "$(jq -r '.to' <<<$mapping)")

	sudo cp $FROM $TO
done
