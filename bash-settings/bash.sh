# Settings for bash. Source this file to use them.
# Copyright (c) 2020 Jason Jackson. MIT license.


# Don't do anything if we're not running interactively under bash
[[ $- =~ i ]] || return
[[ -n $BASH_VERSION ]] || return

# --- Aliases ---
unalias bell cp mv rm df du grep ls ll la which &> /dev/null || true

alias bell='tput bel'

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -I'

alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Ports}}"'
alias docker-rmi-all='docker rmi $(docker images -q)'
alias docker-rm-all='docker rm $(docker ps -a -q)'
alias docker-stop-all='docker stop $(docker ps -q)'

alias df='df -h'  # Human-readable figures
alias du='du -h'

alias grep='grep --color=auto'

alias ls='ls --color=auto --file-type -h'
alias ll='ls -l'   # Long list
alias la='ls -lA'  # All except . and ..

alias which='type -a'

# --- Command-line editing ---
shopt -s cdspell     # Ignore small typos, e.g. `cd /vr/lgo/apaache2` -> /var/log/apache2
set +H               # Disable history expansion, so the "!" character doesn't do weird things
shopt -s histappend  # Append rather than overwriting history on disk
shopt -s histverify  # Verify re-executed lines from history, rather than executing them immediately
export HISTCONTROL=ignoredups

# Make Alt+Left and Alt+Right move the cursor by word
bind '"\e[1;3C": forward-word'
bind '"\e[1;3D": backward-word'

# Make Alt+Up and Alt+Down search history for items which match what's already been entered,
# e.g. type `foo` and press Alt+Up to cycle through previous commands which began with "foo"
# (These bindings assume Terminal.app/iTerm, bind bind "\e[1;3A" and "\e[1;3B" elsewhere)
bind '"\e\e[A": history-search-backward'   # Alt-UpArrow
bind '"\e\e[B": history-search-forward'    # Alt-DownArrow

# Make Tab and Shift-Tab do completion like cmd.exe, where the possibilities are cycled through
bind '"\C-i": menu-complete'
bind '"\e[Z": menu-complete-backward'

# Completions (there are likely more completion scripts in /usr/share/bash-completion,
# but they're probably not interesting, so don't waste time loading them)
complete -A helptopic help      # Help topics
complete -A setopt set          # Options accepted by `set -o`
complete -A shopt shopt         # Options accepted by shopt
complete -a unalias             # Alias names
complete -b builtin             # Built-in command names
complete -c command type which  # Command names
complete -d cd pushd            # Directories
complete -v readonly unset      # Variable names

complete -A stopped -P '"%' -S '"' bg      # Stopped jobs
complete -j -P '"%' -S '"' fg jobs disown  # Jobs

if [[ -d /etc/bash_completion.d ]]; then
	for comp_scr in /etc/bash_completion.d/*; do
		[[ -e $comp_scr ]] && source "$comp_scr" &> /dev/null
		unset comp_scr
	done
fi

# --- Functions ---
function schlep_install() {
	local feature="$1"  # e.g. "micro"

	if [[ -e "$HOME/.schlep/$feature/install-fn.sh" ]]; then
		source "$HOME/.schlep/$feature/install-fn.sh"
	else
		"$HOME/.schlep/$feature/install.sh"
	fi
}

function schlep_uninstall() {
	local feature="$1"  # e.g. "micro"

	if [[ -e "$HOME/.schlep/$feature/uninstall-fn.sh" ]]; then
		source "$HOME/.schlep/$feature/uninstall-fn.sh"
	else
		"$HOME/.schlep/$feature/uninstall.sh"
	fi
}

function take() {
	mkdir -p "$1" && cd "$1" || return
}

# --- Programs ---
unset LS_COLORS  # di=0;34:ln=0;36:so=0;33:pi=0;33:ex=1;32:bd=1;31:cd=0;31:su=1;35:sg=1;35:ow=1;34:tw=1;34:mi=1;31
PATH="$HOME/.schlep/bin:$PATH"

if command -v micro > /dev/null; then
	export EDITOR=micro
	export VISUAL=micro
fi

if command -v less > /dev/null; then
	export PAGER=less
	export LESS=iMR        # Lowercase search patterns are case-insensitive, use long prompt, allow ANSI color codes
	export LESSHISTFILE=-  # Don't write history file of searches and shell commands

	if command -v pretty-less.sh > /dev/null; then
		export LESSOPEN='|pretty-less.sh "%s"'
	fi
fi

# --- Prompt ---
unset MAILCHECK

# By default, we'll show the host in the prompt (and the terminal emulator's tab or title bar);
# you can manually set $host to whatever you like, though (e.g. host="debugging-in-prod")
if [[ -n $INSTANCE_ID ]]; then
	host="${INSTANCE_ID//.*/}"
elif [[ -n $HOSTNAME ]]; then
	host="$HOSTNAME"
else
	host="$(hostname)"
fi

function theme() {
	local theme_name="$1"
	local bright_input="$2"

	if [[ $theme_name == "blue" ]]; then
		PS1='\n\[\e[0;38;5;31m\]\u@$host \[\e[38;5;74m\]\w \[\e[38;5;229m${?##0}\] \[\e[0m\]\n\$ '  # Blue
	elif [[ $theme_name == "charcoal" ]]; then
		PS1='\n\[\e[0;38;5;238m\]\u@$host \[\e[38;5;95m\]\w \[\e[38;5;130m${?##0}\] \[\e[0m\]\n\$ ' # Charcoal
	elif [[ $theme_name == "mint" ]]; then
		PS1='\n\[\e[0;38;5;23m\]\u@$host \[\e[38;5;28m\]\w \[\e[38;5;193m${?##0}\] \[\e[0m\]\n\$ '  # Mint
	elif [[ $theme_name == "safari" ]]; then
		PS1='\n\[\e[0;38;5;66m\]\u@$host \[\e[38;5;230m\]\w \[\e[38;5;222m${?##0}\] \[\e[0m\]\n\$ ' # Safari
	else
		echo "That's not a valid prompt theme name"
		return 1
	fi

	if [[ $bright_input == true || $bright_input == "bright" ]]; then
		PS1+='\[\e[1m\]'
		trap 'printf \\e[0m' DEBUG
	else
		trap DEBUG  # FIXME does this work on recent bash? it doesn't on macOS's 3.2
	fi
}

[[ -n $INSTANCE_ID ]] && theme blue || theme safari
PROMPT_COMMAND=""

# --- Terminal integration ---
export COLUMNS LINES
shopt -s checkwinsize  # Make bash check its window size after a process completes

function detect_terminal() {
	local tty_settings=""

	if [[ -t 0 ]]; then
		tty_settings="$(stty -g)"  # Save TTY settings
		stty -echo                 # Turn echo to TTY off
	fi

	local info
	echo -en "\033[>c" > /dev/tty    # Request secondary device attributes
	read -rs -d ">" info < /dev/tty  # Read and discard the prefix
	read -rs -d "c" info < /dev/tty  # Read the rest of the response

	[[ -z $tty_settings ]] || stty "$tty_settings"  # Restore TTY settings

	if [[ $info == "1;95;0" ]]; then
		export TERM_PROGRAM="Apple_Terminal"
	elif [[ $info == "0;95;0" ]]; then
		# Might also be tmux? https://github.com/mintty/mintty/issues/776#issuecomment-475720406
		export TERM_PROGRAM="iTerm.app"
	fi
}

detect_terminal
export TERM=xterm-256color

if [[ $TERM_PROGRAM == "Apple_Terminal" ]]; then
	PROMPT_COMMAND='apple_terminal_integration'

	function apple_terminal_integration() {
		local ch enc hex i LC_CTYPE=C LC_ALL=""

		for (( i=0; i < ${#PWD}; i++ )); do
			ch="${PWD:i:1}"
			if [[ "$ch" =~ [/._~A-Za-z0-9-] ]]; then
				enc+="$ch"
			else
				printf -v hex "%02X" "'$ch"
				enc+="%${hex: -2:2}"
			fi
		done

		echo -en "\033]7;file://${host}${enc}\a"
	}
elif [[ $TERM_PROGRAM == "iTerm.app" ]]; then
	export COLORTERM=truecolor
	PROMPT_COMMAND='echo -en "\033]1;${PWD/$HOME/~}\a"' # FIXME use $host
else
	# This works on Windows in ConEmu, Mintty, Terminus, and Windows Console; and on Linux
	# in Konsole, GNOME Terminal, LXTerminal, MATE Terminal, QTerminal, Terminology, Xfce Terminal, and XTerm
	PROMPT_COMMAND='echo -en "\033]0;${PWD/$HOME/\~}\a"' # FIXME use $host
fi
