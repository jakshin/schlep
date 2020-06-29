# Uninstalls syntax highlighting in "less" after you've schlepped in to the remote host.
# Source this file to use it.

function uninstall_pretty_less() {
	if [[ -x /usr/bin/lesspipe.sh ]]; then
		export LESSOPEN='||/usr/bin/lesspipe.sh %s'
	else
		unset LESSOPEN
	fi

	~/.schlep/pretty-less/uninstall.sh

	if ! command -v less > /dev/null && [[ $PAGER == "less" ]]; then
		unset PAGER
	fi
}

uninstall_pretty_less
unset -f uninstall_pretty_less
