# Notes about micro

https://github.com/zyedidia/micro#documentation-and-help
https://github.com/zyedidia/micro/blob/master/runtime/help/keybindings.md

## Color schemes

My favorites of micro's built-in color schemes:
* darcula
* one-dark
* twilight
* zenburn

## Copy-paste and mouse support

Mouse support needs to be disabled to copy from a remotely-running micro instance,
e.g. over SSH, into the local clipboard.

Use `show mouse` to see the setting's current state (I leave mouse support enabled by default).

To select text in micro with the mouse (Terminal/iTerm won't know it's selected), 
and use `Ctrl+C` to copy it to the clipboard where micro is running: `setlocal mouse true`

To select text in Terminal/iTerm with the mouse (micro won't know it's selected),
and use `Cmd+C` to copy it to the clipboard where Terminal/iTerm is running: `setlocal mouse false`

## Paragraphs

Navigate to the previous/next paragraph with `Alt+{` and `Alt+}`,
i.e. `Alt+Shift+[` and `Alt+Shift+]`.

## Selecting text

When mouse support is enabled, the mouse can be used to select text.

To select text with the keyboard:
* Press Shift while using any arrow key to select characters
* Press Shift+Alt while using the left/right arrow keys to select words
* Press Shift+Ctrl while using the left/right arrow keys to select the line;
  in iTerm, Shift+Home and Shift+End also work
  (Can also just press Ctrl+C with nothing highlighted to copy the line the cursor's on)

## Shell mode

`Ctrl+B` allows you to run a shell command. Just run "bash" to work in the shell for a while,
as though micro was suspended by the shell.

## Tabs

Open a new tab with `Ctrl+T`. Close a tab with `Ctrl+Q` (micro exits if it's the last open tab).
Switch between tabs with `Alt+,` and `Alt+.`, or by clicking on them with the mouse.

# Undo

`Ctrl+Z` is undo, `Ctrl+Y` is redo.
