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
anything less leaves it ambiguous which copy is current.

**Org owns documents that execute.** The literate configuration, Babel
notebooks and reproducible calculations, structured outlines, tables, export and
teaching material. The GTD agenda, capture and refile configuration stays in
working order but dormant while Reminders owns tasks; `org-directory` is
`~/org`. Babel security still matters, because literate configuration and
notebooks run code.

**Obsidian owns notes**, over a directory of Markdown files that Emacs edits
directly. The deciding constraint is the phone and the iPad: a note has to be
readable and editable there, so the collection stays plain Markdown with no
editor-specific naming or linking scheme. The vault documents its own
conventions — folders, filenames, front matter — and the Emacs commands that
follow them are in `lib.d/lib-notes.el`. Wiki links are the linking format:
Obsidian resolves them everywhere, and markdown-mode resolves them once
`markdown-wiki-link-search-type` includes `project`.

## Capture on the phone and iPad

Obsidian Mobile captures into the vault's inbox through its widgets, Siri and
the Share Sheet, and I file those captures on the Mac. It is a note inbox, not a
second task inbox: anything that starts with a verb goes to Reminders during
triage.

The vault stays under exactly one sync mechanism. Obsidian Sync covers Debian as
well, which iCloud does not, and Obsidian
[warns against combining sync services](https://obsidian.md/help/sync-notes).
Sync only moves files while Obsidian is running, so after Emacs has edited the
vault I leave the application running long enough to upload the change. On the
phone I let sync finish before editing a note that may also have changed on a
computer, and let the upload finish before closing it — mobile operating
systems do not give applications unlimited background time.

Sync is not backup. The vault is backed up independently of it, and Git history
is not a substitute for mobile synchronization either.

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
  and mobile capture creates uniquely named files rather than appending to a
  shared one.

## macOS

- Command is Super, left Option is Meta, and right Option is left to macOS so
  accented characters still work.
- The NS build uses the macOS pasteboard directly, so kill and yank need no
  helper. `pbcopy` and `pbpaste` are for shell commands and for bridging a
  remote terminal.
- Deleted files go to the Trash.
- Credentials come from `auth-source`, never from the configuration. Emacs 31
  includes Keychain backends, which makes Keychain the natural store here.

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
- [Obsidian for iOS and iPadOS](https://obsidian.md/help/ios)
- [Obsidian note synchronization](https://obsidian.md/help/sync-notes)
- [Obsidian internal links](https://obsidian.md/help/links)
