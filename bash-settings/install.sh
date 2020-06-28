#!/usr/bin/env bash
# Installs portable bash settings, by adding a "source" line to the end
# of both ~/.bashrc and ~/.bash_profile (or ~/.profile if that exists instead).

function install_bash_settings() {
	local file_path="$1"

	if ! grep -F "schlep/settings/bash" "$file_path" &> /dev/null; then
		echo '[[ ! -e ~/.schlep/settings/bash.sh ]] || source ~/.schlep/settings/bash.sh' >> "$file_path"
	fi
}

touch ~/.bashrc
install_bash_settings ~/.bashrc

if [[ -e ~/.bash_profile ]]; then
	install_bash_settings ~/.bash_profile
else
	touch ~/.profile
	install_bash_settings ~/.profile
fi
