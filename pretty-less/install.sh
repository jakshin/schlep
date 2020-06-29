#!/usr/bin/env bash
# Installs a script which adds syntax highlighting to files viewed with "less",
# and the dependencies it needs to run (THESE ARE INSTALLED GLOBALLY).

# We assume CentOS 7 x86-64 below
if [[ "$(uname -m)" != "x86_64" || ! -e /etc/centos-release ]] || ! grep -Fq " 7" /etc/centos-release; then
	echo "Not installing pretty-less: currently only supported on on CentOS 7 x86-64"
	exit
fi

# Must be running as root
if [[ "$(whoami)" != "root" ]]; then
	echo "Not installing pretty-less: ya gotta install as root (RPMs are installed system-wide)"
	exit
fi

# Abort on any unexpected error
set -e

# Run from this script's directory
cd -- "$(dirname -- "$0")"

# Install source-highlight and its dependencies
# NOTE THAT THIS IS A GLOBAL INSTALLATION, I.E. IT MAKES DEVICE-WIDE CHANGES
if ! command -v source-highlight > /dev/null; then
	# Note which of the relevant packages was already installed
	echo -n > preinstalled-packages

	for package in source-highlight ctags boost-regex libicu; do
		if rpm --query "$package" > /dev/null; then
			echo -n "[$package] " >> preinstalled-packages
		fi
	done

	# Install source-highlight and its dependencies
	yum --disablerepo="C7-*" -q -y install source-highlight
fi

# Symlink the script
if [[ ! -L ~/.schlep/bin/pretty-less.sh ]]; then
	mkdir -p ~/.schlep/bin
	ln -s "$PWD/pretty-less.sh" ~/.schlep/bin/pretty-less.sh
fi
