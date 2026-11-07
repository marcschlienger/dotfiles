#!/usr/bin/env python3
"""Promote one saved article from Margin into a Denote note.

Articles stay on the server and are read there; only the ones worth keeping
become notes, and that is a decision taken at Emacs.  So nothing syncs: this
fetches one item by its stem, writes its Org body as a note with Denote front
matter, and files the PDF beside it as an attachment with an identifier of its
own, linked from the note.

The identifier is the moment of promotion, not the moment the article was
saved.  A Denote identifier marks when the note came into being, and the
article's own dates belong in its body.

Usage:
  margin2org.py [-k clip,physics] [--no-pdf] [--archive] <stem|url> [notes-dir]

MARGIN_URL must be set (the instance's base address); MARGIN_TOKEN is sent as
a bearer header when set.  The notes directory comes from the argument, else
from NOTES, else the default below.
"""

import argparse
import os
import re
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import denotefile as dn

DEFAULT_NOTES = Path.home() / ("Library/Mobile Documents/"
                               "com~apple~CloudDocs/Notes")
SERVED = (".org", ".md", ".tex", ".pdf")
TIMEOUT = 30


def die(message):
    sys.exit(f"margin2org: {message}")


def stem_of(argument):
    """The item's stem, given a stem, a file name or any Margin URL for it."""
    text = argument.strip()
    if "://" in text:
        text = urllib.parse.urlsplit(text).path
    text = urllib.parse.unquote(text).rstrip("/").rsplit("/", 1)[-1]
    for suffix in SERVED:
        if text.lower().endswith(suffix):
            return text[: -len(suffix)]
    return text


def fetch(base, name, token):
    """One served file, or None when Margin does not have it.

    The token goes in a header rather than the query string: a URL is logged
    by proxies and kept in history, and this one is a credential.
    """
    url = f"{base}/files/{urllib.parse.quote(name)}"
    request = urllib.request.Request(url)
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            return response.read()
    except urllib.error.HTTPError as error:
        if error.code in (403, 404):
            return None
        die(f"{url} answered {error.code} {error.reason}")
    except urllib.error.URLError as error:
        die(f"cannot reach {base}: {error.reason}")


def archive(base, stem, token):
    """Move the item into Margin's archive/ now that it is a note."""
    data = urllib.parse.urlencode({"stem": stem, "action": "archive"}).encode()
    request = urllib.request.Request(f"{base}/archive", data=data)
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            return response.status
    except urllib.error.HTTPError as error:
        die(f"archiving {stem} answered {error.code} {error.reason}")


def markdown_fields(text):
    """title / source_url / date_saved out of Margin's YAML front matter.

    Pandoc's Org output keeps the title and drops the rest, so the fields are
    read from the Markdown even when the .org is what gets converted.
    """
    fields = {}
    if not text.startswith("---"):
        return fields
    _, _, rest = text.partition("\n")
    body, _, _ = rest.partition("\n---")
    for line in body.splitlines():
        key, sep, value = line.partition(":")
        if sep:
            fields[key.strip()] = value.strip().strip('"').strip("'")
    return fields


def strip_pandoc_front_matter(text):
    """Drop the #+title/#+date/#+author lines Pandoc writes.

    Our own front matter replaces them, and Denote reads the first occurrence.
    """
    lines = text.splitlines()
    while lines and re.match(r"(?i)^#\+(title|date|author|subtitle):", lines[0]):
        lines.pop(0)
    while lines and not lines[0].strip():
        lines.pop(0)
    return "\n".join(lines)


def org_from_markdown(markdown):
    """Convert Margin's Markdown, which is the format it writes by default.

    Done here rather than taken from Margin's own .org for two reasons: org
    is not in Margin's default formats, so the file is usually absent; and
    -gfm_auto_identifiers suppresses the :CUSTOM_ID: drawer Pandoc would hang on
    every heading, which a note does not want.
    """
    result = subprocess.run(
        ["pandoc", "-f", "gfm+yaml_metadata_block-gfm_auto_identifiers",
         "-t", "org", "--wrap=preserve"],
        input=markdown, capture_output=True, text=True)
    if result.returncode != 0:
        die(f"pandoc failed: {result.stderr.strip()}")
    return result.stdout


def drop_custom_ids(text):
    """Remove :CUSTOM_ID: lines, and any drawer they leave empty.

    Only reached for a .org taken from Margin, which converts without
    -gfm_auto_identifiers.
    """
    text = re.sub(r"^:CUSTOM_ID:.*\n", "", text, flags=re.M)
    return re.sub(r"^:PROPERTIES:\n:END:\n", "", text, flags=re.M)


def drop_repeated_title(text, title):
    """Drop a leading headline that only repeats the title.

    Margin extracts the body without metadata, so this is usually absent --
    but an article whose first heading is its own title would otherwise carry
    it twice, once as #+title and once as the first headline.
    """
    lines = text.lstrip("\n").splitlines()
    if not lines:
        return text
    heading = re.match(r"\*+\s+(.*)$", lines[0])
    if not heading or dn.slugify(heading.group(1)) != dn.slugify(title):
        return text
    lines.pop(0)
    if lines and lines[0].strip() == ":PROPERTIES:":
        while lines and lines.pop(0).strip() != ":END:":
            pass
    text = "\n".join(lines).lstrip("\n")

    # The dropped headline was the parent of everything below it, so the rest
    # comes up a level -- but only when nothing is left at the top level,
    # since promoting those would produce a headline with no stars.  A
    # headline needs the space after its stars, so Org bold at the start of a
    # line is not matched.
    levels = [len(m) for m in re.findall(r"^(\*+) \S", text, re.M)]
    if levels and min(levels) > 1:
        text = re.sub(r"^\*(\*+ )", r"\1", text, flags=re.M)
    return text


def main():
    parser = argparse.ArgumentParser(
        description="Promote a saved Margin article into a Denote note.")
    parser.add_argument("item", help="the item's stem, file name or URL")
    parser.add_argument("notes", nargs="?",
                        default=os.environ.get("NOTES") or str(DEFAULT_NOTES),
                        help="the notes directory")
    parser.add_argument("-k", "--keywords", default="clip",
                        help="Denote keywords, comma separated (default: clip)")
    parser.add_argument("--no-pdf", action="store_true",
                        help="do not fetch or attach the PDF")
    parser.add_argument("--archive", action="store_true",
                        help="move the item into Margin's archive afterwards")
    args = parser.parse_args()

    base = (os.environ.get("MARGIN_URL") or "").rstrip("/")
    if not base:
        die("MARGIN_URL is not set")
    token = os.environ.get("MARGIN_TOKEN") or ""
    notes = Path(args.notes)
    if not notes.is_dir():
        die(f"no notes directory at {notes}")

    stem = stem_of(args.item)
    if not stem:
        die(f"cannot read an item stem from {args.item!r}")

    raw_md = fetch(base, f"{stem}.md", token)
    fields = markdown_fields(raw_md.decode("utf-8", "replace")) if raw_md else {}

    if raw_md:
        body = org_from_markdown(raw_md.decode("utf-8", "replace"))
    else:
        raw_org = fetch(base, f"{stem}.org", token)
        if not raw_org:
            die(f"{stem}: Margin serves neither .md nor .org for it")
        body = drop_custom_ids(raw_org.decode("utf-8", "replace"))
    body = strip_pandoc_front_matter(body)

    title = dn.first_line(fields.get("title", "")) or stem
    keywords = dn.keywords_from(args.keywords)
    slug = dn.slugify(title) or "article"

    stamp = dn.free_identifier(notes)
    reserved = [stamp.strftime(dn.STAMP)]

    attachment = None
    if not args.no_pdf:
        pdf = fetch(base, f"{stem}.pdf", token)
        if pdf:
            attachments = notes / "attachments"
            attachments.mkdir(exist_ok=True)
            pdf_stamp = dn.free_identifier(notes, stamp, reserved)
            attachment = dn.write_atomically(
                attachments / dn.note_name(pdf_stamp, slug, keywords, ".pdf"),
                pdf)
            reserved.append(pdf_stamp.strftime(dn.STAMP))

    lines = dn.front_matter(title, stamp, keywords)
    if fields.get("source_url"):
        lines.append(f"Source: [[{fields['source_url']}]]")
    if fields.get("date_saved"):
        lines.append(f"Saved:  {fields['date_saved']}")
    if attachment:
        identifier = attachment.name[:15]
        lines.append(f"PDF:    [[denote:{identifier}][{title}]]")
    lines += ["", ""]

    target = notes / dn.note_name(stamp, slug, keywords)
    if target.exists():
        die(f"{target.name} exists")
    body = drop_repeated_title(body, title)
    dn.write_atomically(target, "\n".join(lines) + body.rstrip() + "\n")

    print(target)
    if attachment:
        print(attachment)
    if args.archive:
        archive(base, stem, token)
        print(f"archived {stem} in Margin")


if __name__ == "__main__":
    main()
