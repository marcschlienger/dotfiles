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
import os
import re
import subprocess
import sys
import unicodedata
from datetime import datetime, timedelta
from pathlib import Path

# Transliterations worth spelling out, because dropping the diacritic alone
# turns "für" into "fr" and "Größe" into "Groe".
TRANSLITERATE = {
    "ä": "ae", "ö": "oe", "ü": "ue", "ß": "ss",
    "Ä": "ae", "Ö": "oe", "Ü": "ue",
    "æ": "ae", "ø": "oe", "å": "aa", "œ": "oe", "þ": "th", "ð": "d",
}

IDENTIFIER = re.compile(r"\d{8}T\d{6}")


def slugify(text):
    """Reduce text to the lowercase hyphenated form Denote uses in file names."""
    for char, replacement in TRANSLITERATE.items():
        text = text.replace(char, replacement)
    text = unicodedata.normalize("NFKD", text.lower())
    text = "".join(c for c in text if not unicodedata.combining(c))
    return re.sub(r"[^a-z0-9]+", "-", text).strip("-")


def first_line(text):
    """The first non-empty line, whitespace collapsed.

    A share-sheet variable holding several items interpolates as one line per
    item, so a doubled title or address arrives as a multi-line string.  The
    first line is the one that was wanted.
    """
    for line in text.strip().splitlines():
        line = re.sub(r"\s+", " ", line).strip()
        if line:
            return line
    return ""


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
        title = first_line(strip_tags(match.group(1)))
    else:
        # No preamble: take the title from the page and drop that heading, so
        # it does not appear both as #+title and as the first headline.
        match = heading.search(body)
        if match:
            title = first_line(strip_tags(match.group(1)))
            body = body[: match.start()] + body[match.end():]

    if not title:
        match = re.search(r"<title[^>]*>(.*?)</title>", raw, re.I | re.S)
        if match:
            title = first_line(strip_tags(match.group(1)))

    url = ""
    match = re.search(r'href=["\']([^"\']*)["\']', preamble, re.I)
    if match:
        url = first_line(html.unescape(match.group(1)))

    return title, url, body


def identifier_for(path, notes):
    """A Denote identifier that no note in the directory is using yet."""
    match = IDENTIFIER.search(path.name)
    if match:
        stamp = datetime.strptime(match.group(0), "%Y%m%dT%H%M%S")
    else:
        info = path.stat()
        stamp = datetime.fromtimestamp(getattr(info, "st_birthtime", info.st_mtime))
    taken = {name[:15] for name in os.listdir(notes)}
    while stamp.strftime("%Y%m%dT%H%M%S") in taken:
        stamp += timedelta(seconds=1)
    return stamp


def keywords_for(path):
    stem = path.stem
    if "__" in stem:
        found = [slugify(k) for k in stem.split("__", 1)[1].split("_")]
        found = [k for k in found if k]
        if found:
            return found
    return ["clip"]


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: clip2org.py <clipping> <notes-directory>")
    source, notes = Path(sys.argv[1]), Path(sys.argv[2])

    raw = source.read_text(encoding="utf-8", errors="replace")
    title, url, body = parse(raw)
    stamp = identifier_for(source, notes)
    identifier = stamp.strftime("%Y%m%dT%H%M%S")
    keywords = keywords_for(source)

    slug = slugify(title) or "clipping"
    # Long titles make unwieldy file names; the identifier is what links use.
    slug = slug[:80].rstrip("-")
    target = notes / f"{identifier}--{slug}__{'_'.join(keywords)}.org"
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

    front = [
        f"#+title:      {title or slug}",
        f"#+date:       [{stamp.strftime('%Y-%m-%d %a %H:%M')}]",
        f"#+filetags:   :{':'.join(keywords)}:",
        f"#+identifier: {identifier}",
        "",
    ]
    if url:
        front += [f"Source: [[{url}]]", ""]

    partial = target.with_suffix(".org.part")
    partial.write_text("\n".join(front) + converted, encoding="utf-8")
    partial.replace(target)
    print(target)


if __name__ == "__main__":
    main()
