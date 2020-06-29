#!/usr/bin/env bash
# Installs a script which adds syntax highlighting to files viewed with "less",
# and the dependencies it needs to run (THESE ARE INSTALLED GLOBALLY).

# Abort on any unexpected error
set -e

# Run from this script's directory
cd -- "$(dirname -- "$0")"

# Utilities
function add_yum_repo() {
	check_root
	check_yum
	cp -f "$1" /etc/yum.repos.d
}

function check_root() {
	if [[ "$(whoami)" != "root" ]]; then
		echo "Not installing pretty-less: ya gotta install as root (dependencies are installed system-wide)"
		exit
	fi
}

function check_yum() {
	if ! command -v yum > /dev/null || ! command -v rpm > /dev/null; then
		echo "Not installing pretty-less: yum and rpm are needed to install dependencies"
		exit
	fi
}

# Install "less", source-highlight, and their dependencies (if we need to)
declare -a install_packages
declare -a check_packages

if ! command -v less > /dev/null; then
	install_packages+=("less")
	check_packages+=("less" "groff-base" "ncurses-libs")
fi

if ! command -v source-highlight > /dev/null; then
	install_packages+=("source-highlight")
	check_packages+=("source-highlight" "ctags" "boost-regex" "libicu")
fi

if [[ ${#install_packages[@]} != 0 ]]; then
	# Try to ensure that yum's default repos are available, so we can actually install things;
	# we only do this on CentOS 7, elsewhere we just gotta hope yum's configured well
	if [[ -e /etc/centos-release ]] && grep -Fq " 7" /etc/centos-release; then
		yum_cfgs='/etc/yum.conf'
		[[ "$(echo /etc/yum.repos.d/*)" == "/etc/yum.repos.d/*" ]] || yum_cfgs+=" /etc/yum.repos.d/*"

		grep -E "^\[base\]\s*$" $yum_cfgs &> /dev/null || add_yum_repo "schlep-centos7-base.repo"
		grep -E "^\[updates\]\s*$" $yum_cfgs &> /dev/null || add_yum_repo "schlep-centos7-updates.repo"
		grep -E "^\[extras\]\s*$" $yum_cfgs &> /dev/null || add_yum_repo "schlep-centos7-extras.repo"

		if [[ "$(echo /etc/yum.repos.d/schlep*)" != "/etc/yum.repos.d/schlep*" ]]; then
			yum clean all
		fi
	fi

	# Keep track of which packages we'll install
	echo -n > installed-packages

	for package in "${check_packages[@]}"; do
		if ! rpm --query "$package" > /dev/null; then
			echo "<$package>" >> installed-packages
		fi
	done

	# Install, with dependencies
	yum_opts=('--disablerepo=C7-*' '--enablerepo=base' '--enablerepo=updates' '--enablerepo=extras')
	yum "${yum_opts[@]}" -q -y install "${install_packages[@]}"
fi

# Symlink the script
if [[ ! -L ~/.schlep/bin/pretty-less.sh ]]; then
	mkdir -p ~/.schlep/bin
	ln -s "$PWD/pretty-less.sh" ~/.schlep/bin/pretty-less.sh
fi
