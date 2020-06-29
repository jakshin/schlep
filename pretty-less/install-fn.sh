# Installs syntax highlighting in "less" after you've schlepped in to the remote host.
# Source this file to use it.

function install_pretty_less() {
	~/.schlep/pretty-less/install.sh

	if command -v less > /dev/null && command -v pretty-less.sh > /dev/null; then
		export PAGER=less
		export LESS=iMR
		export LESSHISTFILE=-
		export LESSOPEN='|pretty-less.sh "%s"'
	fi
}

install_pretty_less
unset -f install_pretty_less
