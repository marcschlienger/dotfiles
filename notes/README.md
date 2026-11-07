# notes

Converts clipped articles into Org notes for the Denote directory.

`bin/clip2org.sh` processes every `.html` and `.txt` file in `Notes/inbox/`.
For each one, `bin/clip2org.py` reads the title from the first `<h1>` (falling
back to `<title>`), the address from the first link beside it, and the
identifier from the file name when it already carries one, otherwise from the
file's creation time. It then writes
`<identifier>--<slug>__<keywords>.org` beside the other notes, with the Denote
front matter and a `Source:` link, and the clipping is removed once its note
exists. An existing note of the same name is never overwritten, and an
identifier another note already uses is advanced by a second until it is free.
Running it by hand is fine; it processes whatever is in the inbox and does
nothing when the inbox is empty.

Nothing depends on the name the clipping arrives under. That is deliberate: a
share-sheet shortcut composes that name out of variables that may hold several
items, so it can embed a newline or lose a field without any sign that it did.
The name supplies only the identifier and the keywords, and only when they are
there to be read — keywords come from the `__keyword_keyword` suffix, and
default to `clip`.

Titles are reduced to a slug the way Denote reduces them, except that `ä ö ü ß`
and friends are spelled out rather than stripped, so `Größe` becomes `groesse`
and not `groe`. A slug is cut at 80 characters; links resolve by identifier, so
the length of the name carries no meaning.

`stow notes` links both scripts into `~/bin`; the driver resolves its own path,
so it finds the converter through the symlink.

`NOTES` and `INBOX` can be set in the environment to point the scripts
somewhere else, which is how to try a change without touching the real notes.

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
and is not in this repository. It needs five actions and no text handling: get
the URL from the share sheet, take the first item of that list, get the article
with Safari Reader, make HTML from the article body, save the file into
`Notes/inbox/`. Prepending `<h1>title</h1>` and a paragraph holding the address
to the saved HTML is what gives the note its title and `Source:` link; without
them the page's own `<title>` is used and no source is recorded.
