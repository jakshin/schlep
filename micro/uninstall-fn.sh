# Installs micro after you've schlepped in to the remote host.
# Source this file to use it.

function uninstall_micro() {
	export EDITOR=""
	export VISUAL=""

	~/.schlep/micro/uninstall.sh
}

uninstall_micro
unset -f uninstall_micro
