#!/usr/bin/env bash

# lint-all.sh lints all ports recursively, starting from the current working directory

# Fail on the first error
set -e

function lint-port {
	local port="$1"
	[[ -z "${port}" ]] && return 1

	port lint --nitpick "${port}" || true # Don't fail because of a lint error
}

function find-port-dirs {
	local found_files=()
	mapfile -t found_files < <(find . -type f -name 'Portfile')

	for found_file in "${found_files[@]}"; do
		printf '%s\n' "$(dirname "${found_file}")"
	done
	unset found_file found_files

	return 0
}

function main {
	local found_with_error=0
	local found_total=0
	while read -r port_dir; do
		local output
		output="$(lint-port "${port_dir}" 2>&1)"

		if ! grep '0 errors and 0 warnings found' <<<"${output}" >/dev/null; then
			# There was a linting error
			echo "${output}" >&2
			found_with_error+=1
		fi

		found_total+=1
	done < <(find-port-dirs)

	if [[ $found_total -le 0 ]]; then
		printf 'No Portfiles were found recursively within this directory.\n' >&2
	elif [[ $found_with_error -le 0 ]]; then
		printf 'No ports reported any linting errors.\n'
	fi
}

main "$@"
