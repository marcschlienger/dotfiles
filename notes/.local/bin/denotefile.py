"""Helpers for putting outside material into a Denote directory.

Denote finds a note by the identifier in its file name, so anything written
here has to carry one no other file is using, and front matter that matches
what Denote writes itself.  Both scripts that bring material in need the same
rules, and a second copy of them would drift.
"""

import os
import re
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
STAMP = "%Y%m%dT%H%M%S"

# Long titles make unwieldy file names, and links resolve by identifier, so
# the length of the slug carries no meaning.
SLUG_LIMIT = 80


def slugify(text, limit=SLUG_LIMIT):
    """Reduce text to the lowercase hyphenated form Denote uses in file names."""
    for char, replacement in TRANSLITERATE.items():
        text = text.replace(char, replacement)
    text = unicodedata.normalize("NFKD", text.lower())
    text = "".join(c for c in text if not unicodedata.combining(c))
    slug = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    return slug[:limit].rstrip("-")


def first_line(text):
    """The first non-empty line, whitespace collapsed.

    Material composed from list-valued variables arrives as one line per
    item, so a doubled title or address is a multi-line string.  The first
    line is the one that was wanted.
    """
    for line in text.strip().splitlines():
        line = re.sub(r"\s+", " ", line).strip()
        if line:
            return line
    return ""


def free_identifier(notes, stamp=None, reserved=()):
    """A timestamp whose identifier no file in the directory has taken.

    Denote resolves a link by identifier alone, so two files sharing one make
    a link ambiguous.  `reserved` covers identifiers handed out earlier in the
    same run but not yet written -- a note and its attachment are created in
    the same second.
    """
    stamp = stamp or datetime.now()
    taken = {name[:15] for name in os.listdir(notes)}
    taken |= set(reserved)
    attachments = Path(notes) / "attachments"
    if attachments.is_dir():
        taken |= {name[:15] for name in os.listdir(attachments)}
    while stamp.strftime(STAMP) in taken:
        stamp += timedelta(seconds=1)
    return stamp


def stamp_from_name(name):
    """The datetime a file name's identifier stands for, or None."""
    match = IDENTIFIER.search(name)
    return datetime.strptime(match.group(0), STAMP) if match else None


def keywords_from(spec, default=("clip",)):
    """Denote keywords from a comma- or underscore-separated string."""
    found = [slugify(k) for k in re.split(r"[,_\s]+", spec or "")]
    return [k for k in found if k] or list(default)


def front_matter(title, stamp, keywords):
    """The four Denote keywords, in the order Denote writes them."""
    return [
        f"#+title:      {title}",
        f"#+date:       [{stamp.strftime('%Y-%m-%d %a %H:%M')}]",
        f"#+filetags:   :{':'.join(keywords)}:",
        f"#+identifier: {stamp.strftime(STAMP)}",
        "",
    ]


def note_name(stamp, slug, keywords, suffix=".org"):
    return f"{stamp.strftime(STAMP)}--{slug}__{'_'.join(keywords)}{suffix}"


def write_atomically(target, data):
    """Write through a temporary name, so a reader never sees half a file."""
    partial = target.with_name(target.name + ".part")
    mode = "wb" if isinstance(data, bytes) else "w"
    with open(partial, mode, **({} if isinstance(data, bytes)
                                else {"encoding": "utf-8"})) as handle:
        handle.write(data)
    partial.replace(target)
    return target
