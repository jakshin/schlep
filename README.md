# schlep

Schlep some handy settings onto bare-bones servers (SSH or docker containers).

Often servers, and services' docker containers, are only lightly configured for interactive shell use,
which makes them a little unfriendly to use when you need to SSH or "docker exec" into one,
like to adjust some configuration manually, or debug a problem.

This repo tries to make life a little nicer in those scenarios,
by installing some settings and tools before launching an interactive shell.

It's currently geared toward connecting to a GNU/Linux device from macOS, 
because that's the case in nearly every situation for me.
But I don't think it'd be too hard to make it more cross-platform.

Run `schlep --help` for usage info -- hopefully the rest is fairly self-explanatory.
