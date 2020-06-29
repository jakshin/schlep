#!/usr/bin/env bash
# Uninstalls the script which adds syntax highlighting to files viewed with "less",
# and its dependencies if you're running as root.

# Abort on any unexpected error
set -e

# Run from this script's directory
cd -- "$(dirname -- "$0")"

# Remove the script's symlink, if it exists
rm -f ~/.schlep/bin/pretty-less.sh

# Uninstall the script's dependencies
if [[ -s installed-packages ]]; then
	read -r -d '' -a installed_packages < installed-packages || true
fi

for package in "${installed_packages[@]}"; do
	package="${package//[<>]/}"
	if rpm --query "$package" > /dev/null; then
		uninstall_packages+=("$package")
	fi
done

if [[ "${#uninstall_packages[@]}" != 0 ]]; then
	if [[ "$(whoami)" != "root" ]]; then
		echo "Sorry, ya gotta run this script as root to uninstall pretty-less.sh's dependencies"
		false
	else
		yum_opts=('--disablerepo=C7-*' '--enablerepo=base' '--enablerepo=updates' '--enablerepo=extras')
		yum "${yum_opts[@]}" -q -y erase "${uninstall_packages[@]}"
	fi
fi

# Undo any changes we made in /etc/yum.repos.d
if [[ "$(echo /etc/yum.repos.d/schlep*)" != "/etc/yum.repos.d/schlep*" ]]; then
	rm -f /etc/yum.repos.d/schlep*
	yum clean all
fi
