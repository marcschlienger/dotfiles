#!/bin/zsh
# Turn clipped HTML in the notes inbox into Denote-named Org notes.
#
# A share-sheet shortcut writes <identifier>--<slug>__clip.html into
# Notes/inbox/.  This converts each one with Pandoc, prepends the Denote front
# matter, and moves the result into the notes directory.  The HTML is removed
# only when the conversion succeeded.
set -u

NOTES="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Notes"
INBOX="$NOTES/inbox"
log() { print -r -- "clip2org: $*" >&2 }

command -v pandoc >/dev/null || { log "pandoc not found in PATH"; exit 1 }
[[ -d $INBOX ]] || { log "no inbox at $INBOX"; exit 1 }

setopt null_glob
for f in "$INBOX"/*.html; do
  base="${f:t:r}"
  id="${base%%--*}"
  # The identifier has to be a Denote one; anything else is not ours.
  [[ $id == <->T<-> ]] || { log "skipping $base: no identifier"; continue }
  # The shortcut writes the page title into an <h1>; take it from there and
  # turn HTML entities back into characters.
  title="$(sed -n 's/.*<h1>\([^<]*\)<\/h1>.*/\1/p' "$f" | head -1 |
           python3 -c 'import html,sys; print(html.unescape(sys.stdin.read().strip()))')"
  [[ -n $title ]] || title="${${base#*--}%%__*}"
  keywords="${base##*__}"
  [[ $keywords == $base ]] && keywords="clip"
  out="$NOTES/$base.org"
  if [[ -e $out ]]; then log "skipping $base: $out exists"; continue; fi
  {
    print -r -- "#+title:      $title"
    print -r -- "#+date:       [$(date '+%Y-%m-%d %a %H:%M')]"
    print -r -- "#+filetags:   :${keywords//_/:}:"
    print -r -- "#+identifier: $id"
    print -r --
    # The <h1> carries the title, which is already in #+title, so it is
    # dropped rather than repeated as a heading.  Without
    # -auto_identifiers every heading would also get a :CUSTOM_ID:.
    sed 's|<h1>[^<]*</h1>||' "$f" |
      pandoc -f html-auto_identifiers -t org --wrap=preserve \
             --shift-heading-level-by=-1
  } > "$out.part" && mv -f "$out.part" "$out" && rm -f "$f" \
    || { log "conversion failed for $base"; rm -f "$out.part" }
done
