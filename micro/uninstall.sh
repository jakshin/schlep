#!/usr/bin/env bash
# Uninstalls the micro editor.

# Remove the symlink to the micro binary, if it exists
# (We don't bother to remove the tarball or the directory it expands into)
rm -f ~/.schlep/bin/micro

# Remove symlinks to settings files
[[ -n $MICRO_CONFIG_HOME ]] && cfg_dir="$MICRO_CONFIG_HOME" || cfg_dir="${XDG_CONFIG_DIR:-$HOME/.config}/micro"
bindings="$cfg_dir/bindings.json"
settings="$cfg_dir/settings.json"

if [[ -L "$bindings" && "$(readlink "$bindings")" == *"schlep"* ]]; then
	rm -f "$bindings"
fi

if [[ -L "$settings" && "$(readlink "$settings")" == *"schlep"* ]]; then
	rm -f "$settings"
fi

if [[ -e "$cfg_dir/.created-by-schlep" ]]; then
	rm -rf "$cfg_dir"

	cfg_dir="$(dirname "$cfg_dir")"
	if [[ "$(echo "$cfg_dir"/*)" == "$cfg_dir/*" ]]; then
		rmdir "$cfg_dir"
	fi
fi
