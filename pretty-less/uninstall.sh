#!/usr/bin/env bash
# Uninstalls the script which adds syntax highlighting to files viewed with "less",
# and its dependencies if you're running as root.

# Remove the symlink, if it exists
rm -f ~/.schlep/bin/pretty-less.sh

# Uninstall the script's dependencies
declare -a installed_packages

for package in libuci boost-regex ctags source-highlight; do
	if rpm --query "$package" > /dev/null; then
		installed_packages+=("$package")
	fi
done

if [[ "${#installed_packages[@]}" != 0 ]]; then
	if [[ "$(whoami)" != "root" ]]; then
		echo "Sorry, ya gotta run this script as root to uninstall pretty-less.sh's dependencies"
	else
		rpm --erase "${installed_packages[@]}"
	fi
fi
