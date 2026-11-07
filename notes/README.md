# notes

Brings saved articles into the Denote directory. Articles live on the Margin
instance and are read there; only the ones worth keeping become notes, which
is a decision taken at Emacs. So nothing syncs and nothing watches a folder:
promotion is a deliberate step.

## Promoting a saved article

```sh
margin2org.py [-k clip,physics] [--no-pdf] [--archive] <stem|url> [notes-dir]
```

The item can be named by its stem, by any of its file names, or by any Margin
URL for it. `MARGIN_URL` must be set to the instance's base address, and
`MARGIN_TOKEN` is sent as a bearer header when set — in a header rather than
the query string, because a URL is logged by proxies and kept in history. The
notes directory comes from the argument, else from `NOTES`, else the iCloud
default. Both variables are set outside this repository — in `~/.zprofile` on
a Mac — because an instance's address and its token have no business in a
public one.

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

## Conventions

`.local/bin/denotefile.py` holds the rules for a file Denote will recognise —
the slug, the front matter, and an identifier no file in the directory or in
`attachments/` has taken.

Titles are reduced to a slug the way Denote reduces them, except that `ä ö ü ß`
and friends are spelled out rather than stripped, so `Größe` becomes `groesse`
and not `groe`. A slug is cut at 80 characters; links resolve by identifier, so
the length of the name carries no meaning.

`stow notes` links the scripts into `~/.local/bin`, which is on PATH; the
command resolves its own path, so the shared module is found through the
symlink.

`NOTES` can be set in the environment to point somewhere else, which is how to
try a change without touching the real notes.

## Requirements

Pandoc, for the Markdown conversion, and a reachable Margin instance.
