#!/bin/bash
# Icinga 2 Docker image | (c) 2020 Icinga GmbH | GPLv2+
set -exo pipefail

I2SRC="$1"
ACTION="$2"
TAG="${3:-test}"

if [ -z "$I2SRC" ]; then
	cat <<EOF >&2
Usage: ${0} /icinga2/source/dir
EOF

	false
fi

if ! docker version; then
	echo 'Docker not found' >&2
	false
fi

if ! docker buildx version; then
	echo '"docker buildx" not found (see https://docs.docker.com/buildx/working-with-buildx/ )' >&2
	false
fi

OUR_DIR="$(realpath "$(dirname "$0")")"
COMMON_ARGS=(-t "icinga/icinga2:$TAG" --build-context "icinga2-git=$(realpath "$I2SRC")/.git" "$OUR_DIR")
BUILDX=(docker buildx build --platform "$(cat "${OUR_DIR}/platforms.txt")")

case "$ACTION" in
	all)
		"${BUILDX[@]}" "${COMMON_ARGS[@]}"
		;;
	push)
		"${BUILDX[@]}" --push "${COMMON_ARGS[@]}"
		;;
	*)
		docker buildx build --load "${COMMON_ARGS[@]}"
		;;
esac
