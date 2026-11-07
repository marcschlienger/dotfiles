# notes

Converts clipped articles into Org notes for the Denote directory.

`bin/clip2org.sh` reads `<identifier>--<slug>__<keywords>.html` files out of
`Notes/inbox/`, converts them with Pandoc, prepends the Denote front matter
and writes `<identifier>--<slug>__<keywords>.org` beside the other notes. The
HTML is deleted only after a successful conversion, and an existing note of
the same name is never overwritten. Running it by hand is fine; it processes
whatever is in the inbox and does nothing when the inbox is empty.

`stow notes` links `bin/clip2org.sh` into `~/bin`.

The LaunchAgent is a template, not a stowed file: `WatchPaths` requires
literal absolute paths, and launchd expands neither `~` nor `$HOME` there.
Install it with

```sh
sed "s|__HOME__|$HOME|" notes/Library/LaunchAgents/local.clip2org.plist.in \
  > ~/Library/LaunchAgents/local.clip2org.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/local.clip2org.plist
```

and remove it with `launchctl bootout gui/$(id -u)/local.clip2org`. Errors go
to `/tmp/clip2org.log`.

The share-sheet shortcut that produces the HTML is built in the Shortcuts app
and is not in this repository.
