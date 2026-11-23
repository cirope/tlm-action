#!/usr/bin/env bash
# Installs tlm from its GitHub release: the archive for this runner,
# checked against the release's checksums and, unless turned off, its
# signed build provenance. Puts tlm on the job's PATH.
set -euo pipefail

repo=cirope/tlm-cli

fail() {
	echo "::error::$*"
	exit 1
}

case "$RUNNER_OS" in
Linux) os=linux ;;
macOS) os=darwin ;;
*) fail "tlm-action runs on Linux and macOS runners, not $RUNNER_OS" ;;
esac
case "$RUNNER_ARCH" in
X64) arch=amd64 ;;
ARM64) arch=arm64 ;;
*) fail "no tlm build for $RUNNER_ARCH" ;;
esac

if [ "$VERSION" = latest ]; then
	base="https://github.com/$repo/releases/latest/download"
elif [[ "$VERSION" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	base="https://github.com/$repo/releases/download/v${VERSION#v}"
else
	fail "version must be latest or x.y.z, not $VERSION"
fi

archive="tlm_${os}_${arch}.tar.gz"
dir="$RUNNER_TEMP/tlm"
mkdir -p "$dir"
curl -fsSL --retry 3 --proto '=https' -o "$dir/$archive" "$base/$archive"
curl -fsSL --retry 3 --proto '=https' -o "$dir/checksums.txt" "$base/checksums.txt"

want=$(awk -v f="$archive" '$2 == f { print $1 }' "$dir/checksums.txt")
[ -n "$want" ] || fail "$archive isn't in the release's checksums"
if command -v sha256sum >/dev/null; then
	got=$(sha256sum "$dir/$archive" | awk '{ print $1 }')
else
	got=$(shasum -a 256 "$dir/$archive" | awk '{ print $1 }')
fi
[ "$got" = "$want" ] || fail "$archive doesn't match the release's checksum"

if [ "$VERIFY_ATTESTATION" = true ]; then
	gh attestation verify "$dir/$archive" --repo "$repo" >/dev/null ||
		fail "$archive has no valid build provenance from $repo"
fi

tar -xzf "$dir/$archive" -C "$dir" tlm
echo "$dir" >>"$GITHUB_PATH"
installed=$("$dir/tlm" --version | awk '{ print $2 }')
echo "version=$installed" >>"$GITHUB_OUTPUT"
echo "Installed tlm $installed, checked against the release's checksums."
