#!/usr/bin/env bash
# Installs the micro editor, under the user's home directory.

# We assume Linux x86-64 below (https://getmic.ro has cross-platform logic)
if [[ "$(uname -s)" != "Linux" || "$(uname -m)" != "x86_64" ]]; then
	echo "Not installing micro: currently only supported on on GNU/Linux x86-64"
	exit
fi

# Abort on any unexpected error
set -e

# Run from this script's directory
cd -- "$(dirname -- "$0")"

# Download the latest release's tarball
if [[ "$(echo micro*.tar.gz)" == "micro*.tar.gz" ]]; then
	latest_url="$(curl "https://github.com/zyedidia/micro/releases/latest" -s -L -I -o /dev/null -w '%{url_effective}')"
	version="${latest_url//*\/v/}"
	curl -sS -LO "https://github.com/zyedidia/micro/releases/download/v${version}/micro-${version}-linux64.tar.gz"
fi

# Explode the tarball
if [[ -z $version ]]; then
	latest_tarball="$(ls -1r micro*.tar.gz | head -n 1)"
	version="${latest_tarball#micro-}"
	version="${version//-*/}"
fi

dir_name="micro-${version}"
[[ -d $dir_name ]] || tar -xzf micro*.tar.gz

# Symlink the binary
if [[ ! -L ~/.schlep/bin/micro ]]; then
	mkdir -p ~/.schlep/bin
	ln -s "$PWD/$dir_name/micro" ~/.schlep/bin/micro
fi

# Symlink settings files
[[ -n $MICRO_CONFIG_HOME ]] && cfg_dir="$MICRO_CONFIG_HOME" || cfg_dir="${XDG_CONFIG_DIR:-$HOME/.config}/micro"

if [[ ! -d "$cfg_dir" ]]; then
	mkdir -p "$cfg_dir"
	touch "$cfg_dir/.created-by-schlep"
fi

[[ -e "$cfg_dir/bindings.json" ]] || ln -s ~/.schlep/micro/bindings.json "$cfg_dir/bindings.json"
[[ -e "$cfg_dir/settings.json" ]] || ln -s ~/.schlep/micro/settings.json "$cfg_dir/settings.json"
