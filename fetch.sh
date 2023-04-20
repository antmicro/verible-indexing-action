#!/bin/bash
# Copyright (c) 2023 Antmicro <https://www.antmicro.com>

SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"

. $SELF_DIR/common.inc.sh

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Get Kythe binaries

KYTHE_VERSION='v0.0.48'
KYTHE_URL="https://github.com/kythe/kythe/releases/download/$KYTHE_VERSION/kythe-$KYTHE_VERSION.tar.gz"

begin_command_group 'Get Kythe'
	wget --no-verbose -O kythe.tar.gz "$KYTHE_URL"
	rm -rf kythe-bin
	mkdir kythe-bin
	tar -xzf kythe.tar.gz --strip-components=1 -C kythe-bin
end_command_group

#─────────────────────────────────────────────────────────────────────────────
# Get Kythe sources.

KYTHE_SRC_URL="https://github.com/kythe/kythe/archive/$KYTHE_VERSION.zip"

begin_command_group 'Get Kythe sources'
	wget --no-verbose -O kythe-src.zip "$KYTHE_SRC_URL"
	rm -rf kythe-src
	mkdir kythe-src
	unzip -q kythe-src.zip -d ./kythe-src
end_command_group

#─────────────────────────────────────────────────────────────────────────────
# Get Verible sources

begin_command_group 'Get Verible sources'
	git clone https://github.com/chipsalliance/verible.git
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

