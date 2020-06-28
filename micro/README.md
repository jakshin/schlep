The micro editor, and a small handful of settings tweaks for it.
See https://github.com/zyedidia/micro.

Installing this one only works on GNU/Linux 7 x86-64 (install.sh will abort otherwise),
but micro supports a variety of OSs, so expanding it wouldn't be hard.

Installing this adds a configuration directory for micro at one of these paths:
* `$MICRO_CONFIG_HOME`
* `$XDG_CONFIG_HOME/micro`
* `~/.config/micro`

Two symlinks are created in that directory, `bindings.json` and `settings.json`,
if those files don't already exist.
