# Installs micro after you've schlepped in to the remote host.
# Source this file to use it.

function install_micro() {
	~/.schlep/micro/install.sh

	if command -v micro > /dev/null; then
		export EDITOR=micro
		export VISUAL=micro
	fi
}

install_micro
unset -f install_micro
