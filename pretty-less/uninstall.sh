#!/usr/bin/env bash
# Uninstalls the script which adds syntax highlighting to files viewed with "less",
# and its dependencies if you're running as root.

# Run from this script's directory
cd -- "$(dirname -- "$0")"

# Remove the script's symlink, if it exists
rm -f ~/.schlep/bin/pretty-less.sh

# Uninstall the script's dependencies
preinstalled_packages="$(cat preinstalled-packages 2> /dev/null || true)"
declare -a uninstall_packages

for package in source-highlight ctags boost-regex libicu; do
	if [[ $preinstalled_packages != *"[$package]"* ]] && rpm --query "$package" > /dev/null; then
		uninstall_packages+=("$package")
	fi
done

if [[ "${#uninstall_packages[@]}" != 0 ]]; then
	if [[ "$(whoami)" != "root" ]]; then
		echo "Sorry, ya gotta run this script as root to uninstall pretty-less.sh's dependencies"
		exit
	else
		yum --disablerepo="C7-*" -q -y erase "${uninstall_packages[@]}"
	fi
fi
