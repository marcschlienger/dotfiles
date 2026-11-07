#!/bin/zsh
# Turn clipped pages in the notes inbox into Denote-named Org notes.
#
# A share-sheet shortcut saves a page as HTML into Notes/inbox/ under whatever
# name it manages to compose.  clip2org.py reads the title, address and
# identifier out of the file itself and names the note, so this only has to
# decide when a clipping is complete enough to convert.  The clipping is
# removed when its note has been written.
set -u

: ${NOTES:="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Notes"}
: ${INBOX:="$NOTES/inbox"}
convert=${0:A:h}/clip2org.py
log() { print -r -- "clip2org: $*" >&2 }

command -v pandoc >/dev/null || { log "pandoc not found in PATH"; exit 1 }
[[ -d $INBOX ]] || { log "no inbox at $INBOX"; exit 1 }
[[ -r $convert ]] || { log "no converter at $convert"; exit 1 }

# A clipping arrives over sync, so the file may still be growing when the
# trigger fires -- and Pandoc exits 0 on a truncated document, which would
# produce a short note and then delete the HTML it came from.  So wait until
# the size stops changing before touching a file.  Waiting rather than
# skipping matters: launchd's WatchPaths fires when the directory changes, not
# while a file inside it grows, so a skipped file could sit here until the
# next clipping arrived.
settled() {
  local f=$1 previous=-1 current tries=0
  while (( tries < SETTLE_TRIES )); do
    current=$(stat -f %z "$f" 2>/dev/null) || return 1
    (( current > 0 && current == previous )) && return 0
    previous=$current
    sleep "$SETTLE_INTERVAL"
    (( tries++ ))
  done
  return 1
}

# Two equal readings a second apart count as settled; a file that never
# settles within half a minute is left for the next run.
: ${SETTLE_INTERVAL:=1}
: ${SETTLE_TRIES:=30}

setopt null_glob
# .txt as well as .html: a shortcut that hands text to its save action gets a
# text file regardless of the extension in the name it asked for.
for f in "$INBOX"/*.html "$INBOX"/*.txt; do
  if ! settled "$f"; then
    log "skipping ${f:t}: still being written"
    continue
  fi
  if note=$(python3 "$convert" "$f" "$NOTES"); then
    rm -f "$f"
    log "${f:t} -> ${note:t}"
  else
    log "conversion failed for ${f:t}"
  fi
done
