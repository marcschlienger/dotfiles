# notes

Brings outside material into the Denote directory: saved articles from Margin,
and pages clipped by a share-sheet shortcut. `bin/denotefile.py` holds the
rules both paths share — the slug, the front matter, and an identifier no
other file in the directory has taken.

## Promoting a saved article

`bin/margin2org.py` turns one item from a Margin instance into a note:

```sh
margin2org.py [-k clip,physics] [--no-pdf] [--archive] <stem|url> [notes-dir]
```

The item can be named by its stem, by any of its file names, or by any Margin
URL for it. `MARGIN_URL` must be set to the instance's base address, and
`MARGIN_TOKEN` is sent as a bearer header when set — in a header rather than
the query string, because a URL is logged by proxies and kept in history.
The notes directory comes from the argument, else from `NOTES`, else the
iCloud default.

It writes the note, and files the PDF into `attachments/` under an identifier
of its own, linked from the note with `denote:`. `--archive` moves the item
into Margin's `archive/` afterwards, which is opt-in: promoting and filing are
separate decisions.

The body is converted here from Margin's Markdown rather than taken from its
`.org`, for two reasons: org is not among Margin's default formats, so that
file is usually absent; and `-gfm_auto_identifiers` suppresses the
`:CUSTOM_ID:` drawer Pandoc otherwise hangs on every heading. A leading
headline that merely repeats the title is dropped, and what was under it comes
up a level — unless a headline remains at the top level, where promoting would
leave one with no stars.

The identifier is the moment of promotion, not the moment the article was
saved. A Denote identifier marks when the note came into being; the article's
own dates go in its body, where Margin's `source_url` and `date_saved` are
recorded as `Source:` and `Saved:` lines.

Articles are read in Margin itself, so only the ones worth keeping become
notes. Nothing syncs, and the promotion is a deliberate step rather than a
watcher.

## Clipping a page

`bin/clip2org.sh` processes every `.html` and `.txt` file in `Notes/inbox/`.
For each one, `bin/clip2org.py` reads the title from the first `<h1>` (falling
back to `<title>`), the address from the first link beside it, and the
identifier from the file name when it already carries one, otherwise from the
file's creation time. It then writes the note beside the others, with the
Denote front matter and a `Source:` link, and the clipping is removed once its
note exists. An existing note of the same name is never overwritten. Running
it by hand is fine; it does nothing when the inbox is empty.

Nothing depends on the name the clipping arrives under. That is deliberate: a
share-sheet shortcut composes that name out of variables that may hold several
items, so it can embed a newline or lose a field without any sign that it did.
The name supplies only the identifier and the keywords, and only when they are
there to be read — keywords come from the `__keyword_keyword` suffix, and
default to `clip`.

Pages wrap captions and icons in anchors holding no text, which convert into
Org links with an empty description: clickable, zero-width and invisible. They
are dropped, since the address is already in the image link beside them.

## Conventions

Titles are reduced to a slug the way Denote reduces them, except that `ä ö ü ß`
and friends are spelled out rather than stripped, so `Größe` becomes `groesse`
and not `groe`. A slug is cut at 80 characters; links resolve by identifier, so
the length of the name carries no meaning.

`stow notes` links the scripts into `~/bin`; each resolves its own path, so the
shared module and the converter are found through the symlink.

`NOTES` and `INBOX` can be set in the environment to point the scripts
somewhere else, which is how to try a change without touching the real notes.

## The clipping watcher

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

A Mac shortcut needs no watcher at all: a Run Shell Script action can write
the page into the inbox and call `clip2org.sh` in the same step. The watcher
earns its place when clippings arrive from elsewhere.

The share-sheet shortcut that produces the HTML is built in the Shortcuts app
and is not in this repository. It needs no text handling: get the URL from the
share sheet, take the first item of that list, get the article with Safari
Reader, make HTML from the article body, and save it into `Notes/inbox/`.
Prepending `<h1>title</h1>` and a paragraph holding the address is what gives
the note its title and `Source:` link; without them the page's own `<title>`
is used and no source is recorded.
