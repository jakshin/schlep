#!/usr/bin/env bash
# Uninstalls vim settings for syntax coloring.

if [[ -L ~/.vim && "$(readlink ~/.vim)" == *"schlep"* ]]; then
	rm -f ~/.vim
fi

rm -f ~/.schlep/bin/view
