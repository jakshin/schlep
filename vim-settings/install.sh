#!/usr/bin/env bash
# Installs vim settings for syntax coloring, if possible.

if type -P vim > /dev/null; then
	cmd="vim"
elif type -P vi > /dev/null; then
	cmd="vi"
else
	echo "Not installing vim settings: neither vi nor vim are installed"
	exit
fi

if ! $cmd --version | grep -Fq "+syntax"; then
	echo "Not installing vim settings: vi/vim wasn't compiled with syntax support"
elif [[ -e ~/.vim && ! -L ~/.vim ]]; then
	echo "Not installing vim settings: existing vim settings are present"
elif [[ ! -L ~/.vim ]]; then
	ln -s ~/.schlep/vim-settings/dotvim ~/.vim
fi

# If view doesn't exist, or is a symlink to vi (not vim), and vim exists, 
# make a new view symlink to vim in ~/.schlep/bin (could also `alias view='vim -R'`)
view_path="$(command -v view)"
vim_path="$(command -v vim)"

if [[ (-z $view_path || "$(readlink "$view_path")" == *"vi") && -n $vim_path ]]; then
	mkdir -p ~/.schlep/bin
	ln -s "$vim_path" ~/.schlep/bin/view
fi
