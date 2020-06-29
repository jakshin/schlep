#!/usr/bin/env bash
# Uninstalls portable bash settings, by removing any relevant "source" lines
# from both ~/.bashrc and ~/.bash_profile (or ~/.profile if that exists instead).

function uninstall_bash_settings() {
	local file_path="$1"

	if grep -F "schlep/bash-settings/bash" "$file_path" &> /dev/null; then
		while [[ -L $file_path ]]; do
			file_path="$(readlink "$file_path")"
		done

		grep -Fv "schlep/bash-settings/bash" "$file_path" > "$file_path.tmp"
		mv -f "$file_path.tmp" "$file_path"
	fi
}

uninstall_bash_settings ~/.bashrc
uninstall_bash_settings ~/.bash_profile
uninstall_bash_settings ~/.profile

if [[ "$*" != *"--remote"* ]]; then
	echo "The bash settings are still active in this session."
	echo "To start again without them: exec bash --login"
fi
