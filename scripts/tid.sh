#!/usr/bin/env bash
set -Eeuo pipefail

# Helper script to get the uuid of results in `tsh ls -v`

if [[ $# -ne 1 ]]; then
	echo "error: must pass a string to grep for" >&2
	exit 1
fi

set +Ee
TSH_OUTPUT="$(tsh17 ls -v | rg $1)"
set -Ee

if [ -z "${TSH_OUTPUT}" ]; then
	echo "no id found with that string" >&2
	exit 1
fi

echo "${TSH_OUTPUT}" | awk '{print $2}'
