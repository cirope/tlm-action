#!/usr/bin/env bash
# Runs tlm upload with the action's inputs. Inputs come in as environment
# variables, never pasted into the script, so none can inject commands.
set -euo pipefail

if [ -n "$INPUT_UPLOAD_TOKEN" ]; then
	export TLM_UPLOAD_TOKEN="$INPUT_UPLOAD_TOKEN"
fi
if [ -n "$INPUT_DSN" ]; then
	export TLM_DSN="$INPUT_DSN"
fi

args=(upload "$DIR" --release "$RELEASE" --url-prefix "$URL_PREFIX")
for flag in sources delete dry-run; do
	var=$(echo "$flag" | tr a-z- A-Z_)
	case "${!var}" in
	true) args+=("--$flag") ;;
	false) ;;
	*) echo "::error::$flag must be true or false, not ${!var}" && exit 1 ;;
	esac
done

export TLM_NO_UPDATE_NOTIFIER=1
tlm "${args[@]}"
