#!/usr/bin/env python3
"""Turn one clipped HTML page into a Denote-named Org note.

Everything the note needs is read out of the file: the title from its first
<h1> (or <title>), the address from the first link beside it, the creation
time from the filesystem when the name does not already carry an identifier.
The name the clipping arrives under is therefore only a fallback, which is
deliberate -- a share-sheet shortcut composes that name out of list-valued
variables and can embed newlines or lose a field without any sign that it
did.  Deriving the name here instead means a malformed one costs nothing.

Usage: clip2org.py <clipping> <notes-directory>
Prints the path of the note it wrote.
"""

import html
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import denotefile as dn


def strip_tags(fragment):
    return html.unescape(re.sub(r"<[^>]+>", "", fragment))


def split_preamble(raw):
    """Separate the lines the shortcut prepended from the page itself."""
    match = re.search(r"<!DOCTYPE|<html\b", raw, re.I)
    if match:
        return raw[: match.start()], raw[match.start():]
    return "", raw


def parse(raw):
    """Return (title, url, html-to-convert)."""
    preamble, body = split_preamble(raw)
    heading = re.compile(r"<h1[^>]*>(.*?)</h1>", re.I | re.S)

    title = ""
    match = heading.search(preamble)
    if match:
        title = dn.first_line(strip_tags(match.group(1)))
    else:
        # No preamble: take the title from the page and drop that heading, so
        # it does not appear both as #+title and as the first headline.
        match = heading.search(body)
        if match:
            title = dn.first_line(strip_tags(match.group(1)))
            body = body[: match.start()] + body[match.end():]

    if not title:
        match = re.search(r"<title[^>]*>(.*?)</title>", raw, re.I | re.S)
        if match:
            title = dn.first_line(strip_tags(match.group(1)))

    url = ""
    match = re.search(r'href=["\']([^"\']*)["\']', preamble, re.I)
    if match:
        url = dn.first_line(html.unescape(match.group(1)))

    return title, url, body


def stamp_for(path, notes):
    """The clipping's own identifier when it has one, else its creation time."""
    stamp = dn.stamp_from_name(path.name)
    if stamp is None:
        info = path.stat()
        stamp = datetime.fromtimestamp(
            getattr(info, "st_birthtime", info.st_mtime))
    return dn.free_identifier(notes, stamp)


def keywords_for(path):
    stem = path.stem
    return dn.keywords_from(stem.split("__", 1)[1] if "__" in stem else "")


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: clip2org.py <clipping> <notes-directory>")
    source, notes = Path(sys.argv[1]), Path(sys.argv[2])

    raw = source.read_text(encoding="utf-8", errors="replace")
    title, url, body = parse(raw)
    stamp = stamp_for(source, notes)
    keywords = keywords_for(source)
    slug = dn.slugify(title) or "clipping"

    target = notes / dn.note_name(stamp, slug, keywords)
    if target.exists():
        sys.exit(f"{target.name} exists")

    # Without -auto_identifiers every heading would also carry a :CUSTOM_ID:.
    # The body's headings sit under the page title, so they come up one level.
    converted = subprocess.run(
        ["pandoc", "-f", "html-auto_identifiers", "-t", "org",
         "--wrap=preserve", "--shift-heading-level-by=-1"],
        input=body, capture_output=True, text=True, check=True).stdout

    # Pages wrap captions and icons in anchors holding no text, which convert
    # faithfully into links with an empty description: clickable, zero-width,
    # and invisible in the note.  The address they point at is already in the
    # image link beside them, so drop them.
    converted = re.sub(r"\[\[[^]\[]*\]\[\]\]", "", converted)

    lines = dn.front_matter(title or slug, stamp, keywords)
    if url:
        lines += [f"Source: [[{url}]]", ""]

    dn.write_atomically(target, "\n".join(lines) + converted)
    print(target)


if __name__ == "__main__":
    main()
