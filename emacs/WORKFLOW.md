# Emacs workflow

How I work with Emacs on the Mac, on Debian, and against remote hosts. The
configuration itself is `emacs-init.org`; this file describes the practice
around it: which process serves me, where tasks, documents and notes live, and
what to do at the edges.

## One server per machine

One long-lived server per machine, owned by a service manager: a launch agent
on macOS, a systemd user service on Debian. It starts at login and returns
after an unexpected exit. The commands for starting, stopping and inspecting it
are in the Emacs README.

Every entry point reaches that one process. I do not open the ordinary Emacs
application: it is a second editor that shares no buffers, kill ring or package
state with the server.

The entry points are:

- `ec` — `emacsclient -c -n -a ""`, a graphical frame that returns immediately.
- `ect` — `emacsclient -t -a ""`, a terminal frame in the current shell.
- Emacs Client.app for Finder **Open With**, the Dock, Spotlight and
  `org-protocol://`. It is used exactly as the cask delivers it, because the
  cask rewrites its launcher on every install.
- Yazi, which calls the client directly for its edit opener.

`-n` means do not wait, which is what Finder, Yazi and shell commands want. A
program that must wait for me to finish — Git, for instance — needs a
blocking client instead: `emacsclient -t -a ""`, ended with `C-x #`. `EDITOR`
stays Neovim: an independent fallback that does not weaken any of this.

All the clients pass `-a ""`, so they start a server when none answers. A
server started that way is not the one the service owns, and while it holds the
socket the service cannot start. The README describes how that looks and how to
get out of it.

## Tasks, documents and notes

**Apple Reminders owns tasks.** Siri, the Share Sheet, widgets, the Watch,
sharing, location and notifications matter more to me than Org Agenda's
programmability, and they work on the devices I actually have with me. Nothing
mirrors those tasks into Org: a second inbox would have to preserve completion,
dates, recurrence, list membership, subtasks and edits on both sides, and
anything less leaves it ambiguous which copy is current. The Org GTD agenda and
capture configuration stays in working order and pointed at the notes
directory, ready for the day I change my mind.

**Org owns notes as well as documents that execute** — the literate
configuration, Babel notebooks and reproducible calculations, structured
outlines, tables, export and teaching material. Babel security still matters,
because literate configuration and notebooks run code. The languages loaded are
C, Python, R and shell, with `python3` as the Python command, and PDF export
runs through latexmk so LaTeX is re-run as often as the references need.
`C-c C-x C-l` previews LaTeX fragments in the buffer as vector images, which
needs `dvisvgm` from the TeX distribution. In a LaTeX buffer `<f6>` is
AUCTeX's preview prefix, so `<f6> C-p` previews at point.

**Denote names the notes.** It is a convention, not an application: the
identifier, slug and keywords live in the file name, so a note is a plain Org
file that any editor can open and the identifier survives a retitling. One note
per file, which is what makes a link stable and a conflict small.

- `C-c n n` new note, `C-c n l` link, `C-c n b` backlinks, `C-c n r` rename,
  `C-c n d` sorted Dired.
- `C-c n f` and `C-c n g` find and grep, restricted to the notes, with
  Consult's preview.
- Keywords are both declared and inferred, so a keyword used once is offered
  the next time.
- `M-x denote-template` starts a note from a skeleton: `exercise`, with the
  solution under a heading tagged `:solution:`, or `worksheet`, with the
  export header that leaves such headings out.
- `M-x denote-org-extract-org-subtree` turns the heading at point into a note
  of its own, taking the title, tags and date from the heading. That is how an
  entry leaves `inbox.org`.
- `M-x org-web-tools-read-url-as-org` shows a page as Org in a buffer, through
  Pandoc, without saving anything.

`org-directory` is the notes directory, but `org-agenda-files` names the three
task files inside it rather than the directory itself: a directory entry would
expand to every note, and the notes are not agenda material. Capture has a
fourth target, `lab.org`, a datetree for the lab notebook that the agenda does
not read. `C-c c` reaches all four.

The lab notebook is the habit worth keeping: one line when something worked,
when I decided something, or when a search took longer than it should have.

**Saved articles are two jobs, not one.** The queue — anything from the
browser or a feed reader, read once and mostly discarded — belongs to a
read-later app on the device, which parses and stores locally and so works
with no network and no server. Promotion out of it is deliberate and manual:
copy the article as Markdown, `C-c n t`, yank. No pipeline, no inbox folder,
nothing to watch. Every failure I had building one came from the intermediate
file, and this has none.

Archiving a page verbatim is the other job, and only maths-heavy pages need
it. A self-hosted service renders the page in a real browser engine and waits
for the typesetting to finish before capturing it, which is what mainstream
read-later services get wrong. For those, `margin2org.py` from the `notes`
package writes the note, records the source, and files the PDF as an
attachment with an identifier of its own.

That division is the point: capture is cheap everywhere, and a note earns its
identifier only when I decide to keep it.

## Reading and capture away from the Mac

Notes are read and edited on the phone and the iPad in
[Orgro](https://orgro.org/), which renders LaTeX, follows `denote:` links, and
captures into a file I pick. It needs directory permission granted once before
links between files resolve, and only some storage providers can grant it —
iCloud Drive, local storage and a git client's folder among them. It has no
folder browser and no search across files, so a note is reached by link or
through its recent files.

The reading queue is local to its app, so it works on a plane. The archive
service is reached in its own interface, which can be added to the home
screen, and offline reading *there* needs HTTPS: on a plain `http://` address
that is not `localhost` the browser withholds service workers entirely, so
nothing is cached and it is unavailable without a signal.

Denote naming happens only on the Mac. Neither the read-later service nor
Orgro knows the convention, which is deliberate — it keeps capture free of
rules that are easy to get wrong on a phone.

Sync is not backup. A synchronised folder propagates a deletion and a mangled
save to every device, so the notes need history kept independently of it;
`tmutil destinationinfo` says whether a Time Machine destination exists, and
Orgro's own documentation recommends keeping backups because it rewrites a file
from its in-memory representation and may not preserve non-semantic whitespace.

## Persistence and recovery

- Lockfiles are off. Stale locks cost me more than the warning was worth, and
  they never protected against another program, another machine or a cloud
  client anyway.
- Auto-save writes recovery files into the platform cache directory, outside the
  repository and outside synchronized folders. The visited file changes only
  when I save it.
- Version-controlled files are backed up too. Emacs skips them by default, on
  the assumption that the repository holds the previous content — but it holds
  only what was committed, and the edit worth recovering is the one that was
  not.
- `custom-file` points into the cache directory and is never loaded. The
  configuration is the Org file, and Customize does not get to compete with it.
- `save-place-mode`, `recentf-mode`, `winner-mode`, `repeat-mode` and
  `savehist-mode` are on.
- One writer per file. I do not edit the same canonical file on two machines,
  and capture creates uniquely named files rather than appending to a shared
  one.

## macOS

- Command is Super, left Option is Meta, and right Option is left to macOS so
  accented characters still work.
- The NS build uses the macOS pasteboard directly, so kill and yank need no
  helper. `pbcopy` and `pbpaste` are for shell commands and for bridging a
  remote terminal.
- Deleted files go to the Trash.
- Credentials come from `auth-source`, never from the configuration. Emacs 31
  includes Keychain backends, which makes Keychain the natural store here. A
  shell command that needs one wants it in the environment instead, so the
  read-later instance's address and token are exported from `~/.zprofile`,
  which is a local file — the zsh configuration is in a public repository.
- The notes live in iCloud Drive because it is one of the few providers an
  Org editor on the phone or tablet can be granted directory permission on.
  That makes iCloud's storage optimisation something that has to stay off: an
  evicted note is an `.icloud` stub, which Emacs cannot read and which Git,
  rsync and Time Machine all mishandle. `find` for `*.icloud` under the notes
  directory finds any that have been evicted.

## Debian

- A PGTK build on Sway, so Wayland handles clipboard, scaling and input without
  XWayland. `M-: window-system` reports `pgtk` on a graphical frame.
- systemd owns the daemon's lifecycle and logs; the Emacs Client desktop entry
  owns file associations; `xdg-open` handles external files and URLs.
- `auth-source` uses Secret Service or `pass`.
- The same fonts as on the Mac, with icon fonts optional: a daemon may create
  its first frame in a TTY where those glyphs do not exist.
- There is no Reminders client. I capture through iCloud.com or a nearby Apple
  device rather than rebuilding a Linux-only task list.
- There is no iCloud client either, so the notes directory is a plain
  directory in the home directory and nothing fills it. Only the Mac has both
  iCloud and a route here, so if these notes are wanted on this machine the
  Mac pushes them — one way, one writer, no second sync system over the same
  folder. rclone has an iCloud Drive backend, but it wants an Apple ID
  password and 2FA, refuses app-specific passwords, and holds a trust token
  that expires: not something to put in an unattended job.
- Platform differences stay behind `system-type`, `window-system` and per-frame
  checks. Small adapters, not parallel configurations.

## Remote hosts

For sustained work I stay in the local graphical Emacs and open the remote path
directly:

```text
/ssh:user@host:/path/to/file
```

[TRAMP](https://www.gnu.org/software/emacs/manual/html_node/tramp/Quick-Start-Guide.html)
makes remote files and Dired behave like local ones and runs processes on the
host when `default-directory` is remote, so I keep local fonts, clipboard,
packages and one kill ring, and the host needs no Emacs or dotfiles. Language
servers need explicit remote configuration, large trees and high latency feel
slow, and noisy shell startup confuses TRAMP.

For a long session on a machine that has its own Emacs, I run a daemon there and
attach with `emacsclient -t`, inside tmux when the terminal layout matters as
well. `emacs -nw` is for recovery machines, root shells and containers, and
`emacs -Q -nw` is what I reach for when the configuration itself is broken.

Graphical and terminal frames of one daemon share the kill ring. System
clipboard behaviour depends on the terminal: Emacs 31 recognises kitty and
supports OSC 52 selections, bracketed paste and mouse reporting.

## Command reference

```sh
# Graphical client; returns immediately
ec file

# Terminal client
ect file

# Blocking edit for Git or another caller; finish in Emacs with C-x #
emacsclient -t -a "" file

# Service state, and a restart in place
launchctl print gui/$(id -u)/gnu.emacs.daemon
launchctl kickstart -k gui/$(id -u)/gnu.emacs.daemon

# What is really running, when something looks wrong
pgrep -fl 'Emacs --.*daemon'

# Promote a saved article into a note; MARGIN_URL names the instance.
# The argument is the item's stem, one of its file names, or any URL for it.
margin2org.py -k clip,physics --archive 2026-11-07-article-slug

# Notes that iCloud has evicted, which Emacs cannot read
find "$(emacsclient -e 'denote-directory' | tr -d '"')" -name '*.icloud'

# Whether anything is keeping history of the notes
tmutil destinationinfo

# Remote daemon and terminal client on the remote host
ssh -t host 'emacsclient -t -a ""'

# Recovery without the personal configuration
emacs -Q -nw

# Linux daemon lifecycle
systemctl --user status --no-pager emacs.service
systemctl --user restart emacs.service
```

## Sources

- [GNU Emacs Server](https://www.gnu.org/s/emacs/manual/html_node/emacs/Emacs-Server.html)
- [Invoking emacsclient](https://www.gnu.org/s/emacs/manual/html_node/emacs/Invoking-emacsclient.html)
- [TRAMP Quick Start Guide](https://www.gnu.org/software/emacs/manual/html_node/tramp/Quick-Start-Guide.html)
- [GNU Emacs projects](https://www.gnu.org/software/emacs/manual/html_node/emacs/Projects.html)
- [GNU Emacs session persistence](https://www.gnu.org/s/emacs/manual/html_node/emacs/Saving-Emacs-Sessions.html)
- [GNU Emacs authentication](https://www.gnu.org/software/emacs/manual/html_node/emacs/Authentication.html)
- [Org code-evaluation security](https://orgmode.org/manual/Code-Evaluation-Security.html)
- [Org external protocols](https://orgmode.org/manual/Protocols.html)
- [Org exporting to LaTeX](https://orgmode.org/manual/LaTeX-Export.html)
- [Denote manual](https://protesilaos.com/emacs/denote)
- [Orgro](https://orgro.org/)
- [Orgro FAQ](https://orgro.org/faq/)
- [Pandoc manual](https://pandoc.org/MANUAL.html)
