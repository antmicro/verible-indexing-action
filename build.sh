#!/bin/bash
# Copyright (c) 2023 Antmicro <https://www.antmicro.com>

SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"

. $SELF_DIR/common.inc.sh

STATIC_DIR=$(readlink -f "$SELF_DIR/static")
KYTHE_DIR="$(readlink -f kythe-bin)"
VERIBLE_DIR="$(readlink -f verible-bin)"
VERIBLE_VERILOG_KYTHE_EXTRACTOR="$VERIBLE_DIR/bin/verible-verilog-kythe-extractor"

#─────────────────────────────────────────────────────────────────────────────
# Scan and index core sources

function log_indexer_warnings() {
	if [[ -n "${GITHUB_WORKFLOW:-}" ]]; then
		local _lines=""
		while read -r line; do
			if [[ -n "$line" ]]; then
				_lines="${_lines}%0A${line}"
			fi
		done
		if [[ -n "$_lines" ]]; then
			printf '::warning file=%s,line=%d::verible-verilog-kythe-extractor:%s\n' \
					"${BASH_SOURCE[1]}" "${BASH_LINENO[0]}" "$_lines" >&2
		fi
	else
		cat >&2
	fi
}

function get_file_size() { du -bs "$1" | cut -f1; }

begin_command_group 'Index source code'
	pushd $CORE
	file_args=$($SELF_DIR/index_filelist_gen.py --path_core $BUILD_DIR/$CORE/)

	log_cmd $VERIBLE_VERILOG_KYTHE_EXTRACTOR \
			--print_kythe_facts json \
			$file_args \
			> "$OUT_DIR/entries" \
			2> >(log_indexer_warnings)
	log_cmd ls -l "$OUT_DIR/entries"

	popd > /dev/null
end_command_group

#─────────────────────────────────────────────────────────────────────────────
# Create tables

begin_command_group 'Create graphstore'
	$KYTHE_DIR/tools/entrystream \
			--read_format=json \
			< "$OUT_DIR/entries" \
		| $KYTHE_DIR/tools/write_entries \
			-graphstore "$OUT_DIR/graphstore"
	log_cmd ls -l "$OUT_DIR/graphstore/"
end_command_group

begin_command_group 'Create tables'
	$KYTHE_DIR/tools/write_tables \
			-graphstore "$OUT_DIR/graphstore" \
			-out "$ARTIFACTS_DIR/tables"
	log_cmd ls -l "$ARTIFACTS_DIR/tables"
end_command_group

#─────────────────────────────────────────────────────────────────────────────
# Use static http_server from binaries

begin_command_group 'Extract http_server from the binary release '
	mkdir -p $ARTIFACTS_DIR/bin
	cp $KYTHE_DIR/tools/http_server $ARTIFACTS_DIR/bin/
end_command_group

#─────────────────────────────────────────────────────────────────────────────
# Copy static files to artifacts directory

begin_command_group 'Copy static files'
	cp -R $STATIC_DIR/* $ARTIFACTS_DIR/
end_command_group
