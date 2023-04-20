#!/bin/bash
# Copyright (c) 2023 Antmicro <https://www.antmicro.com>

SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"

. $SELF_DIR/common.inc.sh

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Get Kythe binaries

KYTHE_VERSION='v0.0.48'
KYTHE_URL="https://github.com/kythe/kythe/releases/download/$KYTHE_VERSION/kythe-$KYTHE_VERSION.tar.gz"

begin_command_group 'Get Kythe binary'
	wget --no-verbose -O kythe.tar.gz "$KYTHE_URL"
	rm -rf kythe-bin
	mkdir kythe-bin
	tar -xzf kythe.tar.gz --strip-components=1 -C kythe-bin
end_command_group

#─────────────────────────────────────────────────────────────────────────────
# Get Verible binaries

VERIBLE_URL="https://github.com/chipsalliance/verible/releases/download/v0.0-3195-gd05930a0/verible-v0.0-3195-gd05930a0-Ubuntu-22.04-jammy-x86_64.tar.gz"

begin_command_group 'Get Verible binary'
	wget --no-verbose -O verible-bin.tar.gz $VERIBLE_URL
	mkdir -p verible-bin
	tar -xzf verible-bin.tar.gz --strip-components=1 -C verible-bin
end_command_group

#─────────────────────────────────────────────────────────────────────────────
# Get core sources

begin_command_group 'Get core sources'
	read url branch <<< "${DEPENDENCIES[$CORE]}"
	printf "::info CORE   = %q\n" $CORE >&2
	printf "::info URL    = %q\n" $url >&2
	printf "::info BRANCH = %q\n" $branch >&2
	printf "::info REV    = %q\n" $REV >&2
	git clone -n -b "$branch" "$url" $BUILD_DIR/$CORE
	pushd $CORE
	if [[ -n "$REV" ]]; then
		git checkout "$REV"
	fi
	popd
end_command_group
