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
	# Download RPMs for CentOS 7
	# https://centos.pkgs.org/7/centos-x86_64/source-highlight-3.1.6-6.el7.x86_64.rpm.html
	# https://centos.pkgs.org/7/centos-x86_64/ctags-5.8-13.el7.x86_64.rpm.html
	# https://centos.pkgs.org/7/centos-x86_64/boost-regex-1.53.0-28.el7.x86_64.rpm.html
	# https://centos.pkgs.org/7/centos-updates-x86_64/libicu-50.2-4.el7_7.x86_64.rpm.html
	curl -sS -LO "http://mirror.centos.org/centos/7/os/x86_64/Packages/source-highlight-3.1.6-6.el7.x86_64.rpm"
	curl -sS -LO "http://mirror.centos.org/centos/7/os/x86_64/Packages/ctags-5.8-13.el7.x86_64.rpm"
	curl -sS -LO "http://mirror.centos.org/centos/7/os/x86_64/Packages/boost-regex-1.53.0-28.el7.x86_64.rpm"
	curl -sS -LO "http://mirror.centos.org/centos/7/updates/x86_64/Packages/libicu-50.2-4.el7_7.x86_64.rpm"

	# Install the RPMs
	rpm --install "source-highlight-3.1.6-6.el7.x86_64.rpm" "ctags-5.8-13.el7.x86_64.rpm" \
		"boost-regex-1.53.0-28.el7.x86_64.rpm" "libicu-50.2-4.el7_7.x86_64.rpm"
fi

# Symlink the script
if [[ ! -L ~/.schlep/bin/pretty-less.sh ]]; then
	mkdir -p ~/.schlep/bin
	ln -s "$PWD/pretty-less.sh" ~/.schlep/bin/pretty-less.sh
fi
