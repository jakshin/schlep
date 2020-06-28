#!/usr/bin/env bash
# Installs vim settings for syntax coloring, if possible.

if [[ ! -e ~/.vim ]] && vi --version | grep -Fq "+syntax"; then
	ln -s ~/.schlep/vim-settings/dotvim ~/.vim
fi

# If view doesn't exist, or is a symlink to vi (not vim), and vim exists, 
# make a new view symlink to vim in ~/.schlep/bin (could also `alias view='vim -R'`)
view_path="$(command -v view)"
vim_path="$(command -v vim)"

if [[ (-z $view_path || "$(readlink "$view_path")" == *"vi") && -n $vim_path ]]; then
	ln -s "$vim_path" ~/.schlep/bin/view
fi
