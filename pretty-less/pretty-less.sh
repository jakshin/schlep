#!/bin/bash -e
# Applies syntax coloring to text files viewed in Less, based loosely on the Nord theme.
# This isn't meant to be called directly, but rather to be called automatically by Less.
# To use it: export LESSOPEN='|pretty-less.bash "%s"'
# Copyright (c) 2020 Jason Jackson. MIT license.

# Bail if Less gives us a dash as the input file name (source-highlight can't handle stdin)
input="$1"
[ "$input" != "-" ]

# Bail if the input file doesn't exist, is empty, isn't readable, or isn't a regular file
[ -s "$input" ]
[ -r "$input" ]
[ -f "$input" ]  # Symlinks to regular files will pass this test, as -f reads through symlinks

# Bail if source-highlight isn't installed
command -v source-highlight > /dev/null

# Resolve symlinks so we can check the target file's name
while [[ -L $input ]]; do
	input="$(readlink "$input")"
done

# Extract some simple compressed formats to a temp file,
# so we can view them in Less without manually decompressing
temp_dir=""

if [[ ($input == *.gz && $input != *.tar.gz && $input != '.gz') ||
	($input == *.bz2 && $input != *.tar.bz2 && $input != '.gbz2') ]]
then
	[[ $OSTYPE == "darwin"* ]] && stat_args="-f %Uz" || stat_args="-c %s"
	input_size="$(stat $stat_args "$input")"
	[ "$input_size" -le 10000000 ]  # Bail if it's bigger than 10 MB

	[[ $input == *.gz ]] && suffix='.gz' || suffix='.bz2'
	uncompressed_name="$(basename "$input" "$suffix")"
	temp_dir="$(mktemp -d)"
	temp_file="$temp_dir/$uncompressed_name"

	[[ $input == *.gz ]] && decompressor=gunzip || decompressor=bunzip2
	$decompressor -ck "$input" >> "$temp_file"
	input="$temp_file"
fi

# Bail if the input file doesn't appear to be text;
# Less will prompt that it "may be a binary file", if it wants to
mime_type="$(file -b --mime-type "$input")"
if [[ $mime_type != text/* ]]; then
	[[ -z $temp_dir ]] || rm -rf "$temp_dir"
	false
fi

# Handle the input language
case $input in
	*ChangeLog|*changelog)
		lang_arg="--lang-def=/dev/null" ;;  # Was changelog.lang
	*Makefile|*makefile)
		lang_arg="--lang-def=makefile.lang" ;;
	*.jsx|*.ts)
		lang_arg="--src-lang=js" ;;
	*.zsh-theme)
		lang_arg="--src-lang=zsh" ;;
	*)
		lang_arg="--infer-lang" ;;
esac

# Handle the output language/style
self="$(perl -MCwd -e 'print Cwd::abs_path shift' "$0" 2> /dev/null || true)"
if [[ -z $self ]]; then
	self="${BASH_SOURCE[0]}"
	while [[ -L $self ]]; do
		self="$(readlink "$self")"
	done
fi

self_dir="$(dirname "$self")"

if [[ -e "$self_dir/pretty-less.style" ]]; then
	outlang_arg="--outlang-def=$self_dir/pretty-less.outlang"
	style_arg="--style-file=$self_dir/pretty-less.style"
else
	outlang_arg="--outlang-def=esc256.outlang"
	style_arg="--style-file=esc256.style"
fi

# Do the things
# Add `-n` below to have source-highlight number each line
source-highlight --failsafe $lang_arg "$outlang_arg" "$style_arg" -i "$input" || true
[[ -z $temp_dir ]] || rm -rf "$temp_dir"
