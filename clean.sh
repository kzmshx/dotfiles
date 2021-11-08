#!/bin/zsh

MAP=mapping.json

for mapping in $(jq -rc '.[]' <$MAP); do
	TO=$(jq -r '.to' <<<$mapping)
	sudo rm $TO
done
