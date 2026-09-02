# Improving Emacs on macOS, Linux, and remote servers

Research date: 2026-08-29; Org audit updated 2026-08-30

## Recommendation

I would keep Emacs as the primary editor and development/writing environment,
without making it the task manager. Apple Reminders should remain the single
authoritative task system: its iPhone, iPad, Watch, Siri, sharing, location, and
notification integration are more valuable here than Org Agenda's flexibility.
Maintaining the same commitments in Org would create a second inbox and
unreliable state.

The interesting decision is not simply “Obsidian or Denote.” Denote is an Emacs
interface and file-naming/linking method, while Obsidian is an application over
Markdown files. They can be tested on the same carefully constrained Markdown
collection. For this workflow, Obsidian Mobile is also the best available
Denote companion: there is no official Denote app for iOS or iPadOS, but a
Denote Markdown note remains an ordinary file that Obsidian can read and edit.

My preferred end state is:

1. Run exactly one long-lived Emacs server per machine. Start it on demand on
   macOS and through the user service on Linux.
2. Use graphical client frames for normal local work, `emacsclient -t` for a
   terminal attached to the same machine, and TRAMP from the local GUI for most
   remote editing.
3. Keep Apple Reminders as the **action system**. Do not synchronize or mirror
   its tasks into Org.
4. Keep the repaired Org task workflow available as a fallback, but do not
   mirror current Apple Reminders tasks into it. Org also remains the format
   for literate configuration, Babel notebooks, structured documents, and
   export.
5. Trial Denote as the **Emacs-side knowledge interface** using Markdown YAML.
   Keep Obsidian available over the same test collection rather than migrating
   the entire existing vault immediately.
6. Use Obsidian Mobile as the rare iPhone/iPad companion. Capture to a mobile
   inbox, then turn worthwhile captures into proper Denote notes on the Mac.
7. Preserve the Org task configuration in working order so returning to it is
   possible without a rebuild; treat it as dormant while Reminders owns tasks.

This preserves one portable configuration while still taking advantage of
macOS application integration and Linux's systemd/Wayland environment.

## What is already in place

The repository and the installed Mac were inspected before preparing these
recommendations.

- The Mac currently runs a GNU Emacs 31.1 development build with native
  compilation, Tree-sitter, SQLite, GnuTLS, SVG, native macOS (NS), and module
  support.
- `/Applications/Emacs Client.app` already handles Finder/Dock opening and the
  `org-protocol://` URL scheme. Its launcher uses `emacsclient -c -a '' -n`, so
  it starts a daemon on demand when none exists.
- Zsh already defines `ec='emacsclient -c -n -a ""'`.
- Yazi opens files through the Emacs client by default, with Neovim as a
  fallback.
- The graphical frame and theme setup already accounts for daemon-created
  frames and macOS light/dark appearance.
- `exec-path-from-shell` already normalizes the graphical environment on both
  operating systems.
- Org uses `~/org`, a directory-based agenda, capture templates, refile targets,
  a custom GTD view, dependency enforcement, and Babel. The GTD portion is
  repaired and retained, but dormant while Apple Reminders owns tasks.
- Denote currently uses the trial silo `~/denote-test/`, Markdown with YAML
  front matter, `consult-denote`, and `denote-markdown`.
- Completion is already well covered by Vertico, Orderless, Consult, Embark,
  Corfu, Cape, and Yasnippet. Replacing that stack would create churn without a
  corresponding benefit.
- Development is already well covered by Eglot, Flymake, Ruff, `ruff-format`,
  Tree-sitter, Magit, and language-specific modes.

The system does not need an Emacs distribution or a wholesale rewrite. It needs
a lifecycle policy, a notes policy, and a focused round of cleanup.

## Ranked roadmap

The rankings combine benefit, risk reduction, portability, and maintenance
cost. This table contains only recommendations: unconditional improvements and
clearly labelled options that become worthwhile under a stated condition. It
does not list approaches that should simply be avoided.

| Rank | Improvement | Value | Effort | Status or trigger |
| ---: | --- | --- | --- | --- |
| 1 | Keep Apple Reminders authoritative and retain repaired Org GTD as a fallback | Very high | Low | Adopted |
| 2 | Trial Denote over Markdown without abandoning Obsidian | Very high | Medium | Trial in progress in `~/denote-test/` |
| 3 | Use Obsidian Mobile for Denote/Markdown capture | Very high | Low | Best Denote mobile route |
| 4 | Use one server/client lifecycle per machine | Very high | Low | Policy documented; adopt operationally |
| 5 | Keep Org capture, agenda, appointment refresh, and Babel behavior correct | Very high | Low | Completed 2026-08-30 |
| 6 | Protect notes from concurrent writes and sync conflicts | High | Low | Nextcloud selected; single-writer and recovery auto-save policy documented |
| 7 | Use `emacsclient -t` for local and remote terminal frames | High | None | Usage practice; no Emacs configuration change |
| 8 | Add persistent places, recent files, repeat keys, and window undo | High | Low | Completed 2026-08-31 |
| 9 | Define a mobile-note inbox and desktop triage command | High | Low | After choosing the sync layout |
| 10 | Promote the Denote trial only after testing real Obsidian notes | High | Low | After the trial |
| 11 | Use TRAMP as the default remote-editing route | High | Low | Adopt as practice |
| 12 | Make credentials use `auth-source` backends, never dotfiles | High | Low | Before adding authenticated services |
| 13 | Add project workspaces with built-in tab bars or Activities | Medium/high | Medium | Trial one approach |
| 14 | Add `denote-journal` only if a daily knowledge log is wanted | Medium | Low | Optional |
| 15 | Add `envrc` for per-project development environments | Medium | Low | Useful for mixed toolchains |
| 16 | Add Popper for transient help/build/process buffers | Medium | Medium | If transient-buffer clutter recurs |
| 17 | ~~Add `dired-preview` to the existing Dired setup~~ | — | — | Done; bound to `V` in Dired |
| 18 | Add Eat or Vterm as an in-Emacs terminal | Medium | Medium | Only if project-local shells would be used |
| 19 | Add `org-modern`, `org-appear`, or `org-transclusion` | Medium | Low/medium | Only for document work |
| 20 | Use Drafts only as a capture-to-Org front end | Medium | Medium | Only if it improves Org capture enough to justify another app |
| 21 | Build a Shortcut that creates perfect Denote filenames on iOS | Medium | Medium | If Markdown-inbox triage becomes costly |
| 22 | Use `citar-denote` or `org-noter` | Niche/high | Medium | Only for a specific workflow |
| 23 | Add exact package locking or a second package manager | Medium | High | Only if reproducibility becomes a real problem |

## 1. Make the server/client lifecycle unambiguous

This is the most important usability improvement because a server-based Emacs
is excellent only when every entry point reaches the same process.

The current `ec` alias and Emacs Client application use the documented
`--alternate-editor=""` behavior: if no server exists, `emacsclient` starts a
daemon and connects to it. GNU Emacs explicitly documents this as an on-demand
server strategy, alongside daemon startup and systemd activation in the
[Emacs Server manual](https://www.gnu.org/software/emacs/manual/html_node/emacs/Emacs-Server.html).

There is no `server-start` in the current configuration. Therefore, launching
the ordinary `Emacs.app` first creates a normal, non-server Emacs. Running `ec`
later can create a second, independent daemon. Buffers, kill rings, agenda
state, unsaved changes, and package state can then be split between two Emacs
processes.

### Recommended macOS policy

Use the existing **Emacs Client.app** and `ec` as the normal entry points. Let
them start the daemon on first use. Pin Emacs Client to the Dock if a Dock icon
is wanted, and use it for Finder associations. Do not routinely launch the
ordinary Emacs application.

This is simpler than a LaunchAgent because it consumes nothing before first
use, remains compatible with Homebrew upgrades, and is already installed. A
login LaunchAgent is worthwhile only if the first frame is noticeably slow or
scheduled background work must run before the first client connects.

An alternative is to use ordinary `Emacs.app` and add `server-start`. That is
valid, but it is less natural for a machine where terminal and Finder requests
must also work before the GUI app has been launched. Choose one model rather
than combining the two.

### Recommended Linux policy

Use the Emacs-provided systemd user service:

```sh
systemctl --user enable --now emacs.service
```

If Debian's unit points to a different Emacs binary from the one intentionally
installed, copy the unit into `~/.config/systemd/user/`, adjust `ExecStart`, run
`systemctl --user daemon-reload`, and then enable it. The official manual also
documents socket activation, but a normal user service is easier to inspect and
restart.

A desktop launcher should call `emacsclient -c -a ''`, not start a second
`emacs` process. Freedesktop-compatible installations commonly provide an
**Emacs (Client)** entry already.

### Choose frame and wait behavior explicitly

The current GUI command is correct for interactive opening:

```sh
alias ec='emacsclient -c -n -a ""'
```

For a terminal frame, use the client directly:

```sh
emacsclient -t -a ""
```

This is a command, not an Emacs configuration change. If the daemon is known
to be running, the command is simply `emacsclient -t`; `-a ""` only tells the
client to start a daemon when none is available. The existing `ec` alias is
GUI-specific because it already supplies `-c -n`, so adding `-t` to that alias
would mix incompatible frame options. A separate `ect` alias would be optional
shell shorthand, not a required part of the setup.

`-n` means “do not wait”, which is desirable for Finder, Yazi, and shell
commands where a frame should appear and the caller should return. It is wrong
for programs such as Git that must wait for editing to finish. For a blocking
editor, use:

```sh
emacsclient -t -a ""
```

and finish with `C-x #` (`server-edit`). The distinction and the `-c`/`-t`
options are documented in [Invoking emacsclient](https://www.gnu.org/s/emacs/manual/html_node/emacs/Invoking-emacsclient.html).
The present choice of `EDITOR=nvim` can remain; it is a sensible independent
fallback and does not weaken Emacs integration.

## 2. Separate tasks, documents, and knowledge

### Apple Reminders: the only task system

Keep tasks, deadlines, recurring reminders, grocery items, location reminders,
and shared lists in Apple Reminders. Apple documents capture through Siri,
Control Center, the Share Sheet, and the Reminders/Calendar applications in
[Create reminders on iPhone](https://support.apple.com/guide/iphone/create-reminders-iph88463e18/26/ios/26).
Those entry points—and reliable delivery on the devices that are actually at
hand—matter more than the extra programmability of Org Agenda.

Do not mirror reminders into Org, add an import/export job, or use Org as a
secondary inbox. Two-way synchronization would have to preserve completion,
dates, recurrence, list membership, tags, subtasks, links, and edits on both
sides. Anything less produces ambiguity about which task is current.

On macOS, an optional Emacs command could invoke a small Apple Shortcut for
“Add Reminder” when keyboard-only capture is desirable. It should create a
reminder and return; it should not maintain a copy in Emacs. This adapter would
be macOS-only. On Debian, use iCloud.com or a nearby Apple device rather than
inventing a Linux-only shadow task list.

### Org: documents and executable notebooks

Org remains valuable without Org Agenda. Keep it for:

- the canonical literate Emacs configuration;
- Babel notebooks and reproducible calculations;
- structured outlines and long-form documents;
- tables, export, and teaching material;
- temporary project planning when it is part of a document rather than a task
  inbox.

The existing GTD agenda, task capture, appointment, and refile configuration is
now dormant complexity. Preserve it in Git history or a separate archival file
if the workflow might return, but do not keep repairing and loading it merely
because it was once useful. Babel security remains relevant because literate
configuration and notebooks still execute code.

### Denote and Obsidian can share a Markdown layer

Denote is most useful here as the Emacs interface to durable knowledge:

- concept and literature notes;
- explanations and technical discoveries;
- teaching material;
- durable meeting notes and decisions;
- people, organizations, systems, and recurring topics;
- project context that should survive a particular task.

It deliberately builds on ordinary files, file names, links, and standard Emacs
facilities. Its [official manual](https://protesilaos.com/emacs/denote) supports
Markdown with YAML front matter, which Obsidian also understands as properties.
This means the first experiment does not need a destructive migration away from
Obsidian.

The current `markdown-yaml` choice is the right one. Point Denote at a copied or
small representative subset of the Obsidian vault and answer these questions
with real notes:

1. Can Denote find and rename the notes that matter?
2. Do titles and tags appear correctly in Obsidian Properties?
3. Do links created in Emacs open on mobile?
4. Do links created in Obsidian remain useful in Emacs?
5. Does either application rewrite YAML or links in an undesirable way?

Only then decide whether the permanent Denote directory should be the existing
vault, a Denote-managed subdirectory inside it, or a separate collection.

### The link-format caveat

Native `denote:` links are intentionally file-type independent inside Emacs,
but generic Markdown applications do not understand that scheme. The
[`denote-markdown` manual](https://elpa.gnu.org/packages/denote-markdown.html)
explicitly says that links must be converted to path or Obsidian style for use
outside Emacs. Obsidian supports both Wikilinks and ordinary Markdown file links
according to its [internal-link documentation](https://obsidian.md/help/links).

For a shared collection:

- prefer links that resolve as ordinary paths or Obsidian links on mobile;
- use `denote-markdown` conversion commands deliberately;
- avoid Obsidian block references and plugin-only syntax in notes that must
  remain portable;
- test rename behavior before bulk-renaming existing notes;
- keep a backup or Git history during the trial.

There is also an important creation limitation: `denote-org-capture` always
creates an Org file, regardless of `denote-file-type`. Do not route this Markdown
workflow through Org Capture. Use direct Denote commands on desktop and the
mobile inbox described below.

### Suggested directory model

The least risky trial is a Denote-managed area inside the Obsidian vault:

```text
Obsidian vault/
├── Inbox/
│   └── Mobile inbox.md
├── Notes/
│   └── 20260829T143000--example-title__keyword.md
├── Attachments/
└── Templates/
```

Set `denote-directory` to `Notes/` for the initial trial. Obsidian can see the
whole vault, while Denote has a clean namespace and does not try to interpret
every historic Obsidian file. If the boundary later feels artificial, widen it
only after existing filenames and links have been normalized safely.

Keep the vault under exactly one sync mechanism. Obsidian recommends its own
Sync service for cross-platform use and iCloud for macOS/iOS-only use, and
explicitly warns against combining sync services in
[Sync your notes across devices](https://obsidian.md/help/sync-notes). Because
Debian is part of this setup, the paid Obsidian Sync service is the simplest
fully supported option; iCloud alone does not provide the same Linux path.
Working Copy plus Git can avoid that subscription, but synchronization becomes
manual on iOS and is a much poorer fit for quick capture.

Obsidian Sync only transfers files while Obsidian is running. When Emacs edits
the vault, keep the desktop application running in the background long enough
to observe and upload the external changes; Obsidian documents that it refreshes
its vault for external file changes. On a machine where the GUI should not run,
[Obsidian Headless Sync](https://obsidian.md/help/sync/headless) can watch the
vault, but it is currently an open beta. Never run desktop Sync and Headless
Sync on the same machine, as the official documentation warns that this can
cause conflicts.

On iPhone/iPad, open Obsidian and confirm sync has completed before editing a
note that may also have changed on a computer. Confirm the upload before closing
it. Mobile operating systems do not give applications unlimited background
execution.

### Denote extensions worth considering

- [`denote-journal`](https://protesilaos.com/emacs/denote-journal) is useful only
  if a daily knowledge/work log is wanted. It is not a replacement for
  Reminders.
- [`denote-silo`](https://protesilaos.com/emacs/denote-silo) is useful for truly
  isolated personal and employer collections. Do not use a silo merely as an
  ordinary folder.
- `citar-denote` is compelling for a bibliography-driven academic workflow,
  but unnecessary for ordinary web and technical notes.
- `denote-org` is not a priority while interoperability requires Markdown.

Do not add Org-roam alongside Denote now. It would introduce another note model
and an SQLite index while the more basic Denote/Obsidian interoperability
question is still being answered.

## 3. Mobile capture for Denote

There is no official Denote application for iOS or iPadOS. For occasional
mobile use, that is not a serious limitation: capture needs to be fast and
lossless, but it does not need to reproduce every Denote prompt on the phone.

### Rank 1: Obsidian Mobile as the companion

This is the clear recommendation because it reuses an application and file
format already in the workflow. Current Obsidian for iOS/iPadOS provides:

- Home Screen, Lock Screen, and Control Center capture widgets;
- Siri commands such as “Capture to Obsidian”;
- Apple Shortcuts actions for opening a new note or appending/prepending to a
  daily or bookmarked note;
- a native Share Sheet that can create a note or append to an inbox;
- capture templates for web title, URL, author, selection, and timestamps.

These capabilities are documented in
[Obsidian for iOS and iPadOS](https://obsidian.md/help/ios). For rare capture,
configure one widget/Shortcut and one Share Sheet Location to append to
`Inbox/Mobile inbox.md`. This is faster and more reliable than forcing every
fleeting thought to have a perfect title, slug, keyword set, and Denote ID.

Desktop triage is then simple:

1. Open the mobile inbox from Consult or Obsidian.
2. Delete transient material.
3. Send actionable material to Apple Reminders.
4. Turn durable material into a Denote note with `denote`, then move/paste the
   captured text.
5. Clear the processed inbox.

This is a note inbox, not a second task inbox. Any line beginning with an action
verb should leave it for Reminders during triage.

### Rank 2: create a valid Denote note directly with an Apple Shortcut

If inbox triage becomes annoying, a Shortcut can ask for title/body/tags and
construct:

```text
YYYYMMDDTHHMMSS--slugified-title__mobile_tags.md
```

with matching YAML front matter. The documented
[`obsidian://new`](https://obsidian.md/help/uri) action accepts a vault-relative
file path and initial content, so the Shortcut can create the file inside
`Notes/` and open it in Obsidian.

This is feasible but ranks second because the Shortcut must correctly implement
timestamp formatting, title slugification, tag normalization, URI encoding, and
YAML quoting. Denote remains the authoritative implementation of those rules;
any future filename-policy change must also update the Shortcut. Treat this as
an optimization after the inbox workflow has proven too slow.

Obsidian's built-in
[Unique note creator](https://obsidian.md/help/Plugins/Unique%2Bnote%2Bcreator)
can create timestamped notes from a template and works on mobile, but its normal
timestamp-only name is not automatically a complete Denote filename. It is a
useful near-match, not a guarantee of Denote validity.

### Rank 3: Drafts as a capture-only front end

Drafts is excellent when instant capture, dictation, Apple Watch capture, and
custom actions matter more than seeing the whole knowledge base. Its actions can
create files from templates, and folder bookmarks can grant access to an
external iCloud Drive or file-provider folder; see the
[Drafts file action](https://docs.getdrafts.com/docs/actions/steps/services) and
[folder bookmarks](https://docs.getdrafts.com/docs/settings/bookmarks).

If Drafts is adopted here, its role should stop at capture. The important action
is **Export as Org**, not task synchronization and not browsing the Org tree on
iOS. Drafts can create files through a file-provider folder bookmark, a direct
Dropbox action, or WebDAV; its documented File step supports create, replace,
prepend, and append operations. Folder bookmarks are device-specific and must
be granted once on every iPhone/iPad/Mac that runs the action.

The safest export is one immutable file per capture, for example:

```text
mobile-captures/20260830T143200--meeting-idea.org
```

with a small, valid Org document:

```org
#+title: Meeting idea
#+date: [2026-08-30 Sun 14:32]
#+filetags: :mobile:

Captured text...
```

This avoids two devices appending to the same file. Emacs can later refile the
content into `notes.org`, convert it to a Denote note, or discard it. If having
mobile captures immediately in the GTD Inbox is more important than conflict
resistance, append an ordinary heading to `inbox.org` instead; by design that
file alone defines Inbox membership. I would not choose the append route while
Emacs may also save `inbox.org` on another machine.

Drafts itself remains usable offline for capture. Export through WebDAV or a
cloud file provider still needs connectivity; a failed export should leave the
draft available to retry. That is a reasonable offline queue, but it is not
transparent background synchronization. The drawbacks remain another
application, an action to maintain, and Drafts Pro for creating/editing custom
actions.

### Lower-ranked alternatives

- **Apple Notes as a fleeting inbox:** fastest native capture, scanning, and
  handwriting, but the note must later be copied into the Markdown collection.
- **A generic Markdown editor:** fine for editing an existing Denote file from
  Files, but it supplies no Denote-aware creation, backlinks, or rename logic.
- **Working Copy/Git:** excellent for versioning and emergency edits, poor as a
  quick-capture interface. Git is not background mobile sync.
- **Org-specific mobile clients:** unnecessary while Reminders owns tasks and
  Drafts, if used, only exports captures. They become relevant only after an
  intentional return to Org as the task system.
- **Running Emacs on iOS:** not a reasonable solution for occasional capture.

### The resulting system boundary

```text
Tasks
  Apple Reminders on iPhone/iPad/Mac/Watch

Knowledge files
  Markdown vault, synchronized once
    ├── Emacs + Denote on macOS/Linux
    └── Obsidian on macOS/Linux/iPhone/iPad

Structured/executable documents
  Org in Emacs
    └── optional Drafts capture queue exported as Org files
```

This is simpler than making any pair synchronize semantically. Reminders owns
task state; the Markdown vault owns the Denote collection; Org owns structured
documents and the retained fallback workflow.

## 4. Retained Org configuration audit

The Org workflow is deliberately retained even though Apple Reminders currently
owns tasks. The correctness problems below were repaired on 2026-08-30. The
workflow choices are recorded separately and remain open for a later decision.

### 4.1 Babel confirmation — fixed

`org-confirm-babel-evaluate` is now `t`, so enabled C, Clojure, Python, R, and
shell blocks require confirmation. Org's manual treats a source block as
equivalent in risk to an executable file and warns against removing the
safeguard in [Code Evaluation Security](https://orgmode.org/manual/Code-Evaluation-Security.html).

If the prompts later become too noisy, use a function that skips confirmation
only for a narrow trusted-directory policy. File location is more meaningful
than language alone: a shell block in a personal literate config may be trusted,
while a shell block in a cloned README is not.

Also consider `:eval never-export` or `:eval query-export` on blocks that must
not execute silently during export. The available controls are documented in
[Evaluating Code Blocks](https://orgmode.org/manual/Evaluating-Code-Blocks.html).

### 4.2 Inbox membership — fixed

Inbox membership is now structural: every unfinished TODO entry in
`~/org/inbox.org` belongs to the Inbox, with no `:inbox:` tag required. Moving
or refiling an entry out of that file removes it from the Inbox.

### 4.3 Project containers — fixed

The project template now creates an ordinary top-level heading tagged
`:project:`. Only child actions receive TODO states. The statistics hook also
checks that a parent already has a TODO keyword before changing its state, so a
plain project container cannot become `TODO` or `DONE` accidentally.

### 4.4 Meeting capture — fixed as a note

The `m` template is explicitly a meeting **note**, not an appointment. It writes
to `notes.org`, records the capture time as metadata, adds `:meeting:`, and
leaves point in the note body. It intentionally has no scheduled timestamp.

### 4.5 Every unmarked task defaults to priority A

`org-default-priority` is `A`. This makes the absence of a priority marker mean
“highest priority,” which erases most of the value of prioritization. Default B
is generally a better neutral baseline; reserve A for a deliberate exception.
This is a workflow choice, not a technical error, but it should be intentional.

### 4.6 Deadline view fixed; project depth remains a workflow choice

The GTD deadline section now finds every heading with a deadline, independent
of date range. It excludes completed states, sorts by deadline, and places
`WAITING` deadlines in their own block.

The project template currently makes project headings level 1, a `Tasks`
container level 2, and its actions level 3. Therefore the existing project view
correctly finds `NEXT` items created by that template. Yes, a valid `NEXT` can
exist at another level: it may be entered directly under a project, nested
under a subproject, or moved by refile. The fixed-level query will then omit it.
Keep it only if the three-level project structure is an intentional invariant;
otherwise a later improvement should select `NEXT` descendants of a
`:project:` ancestor semantically, probably with `org-ql` or a small skip
function. This is not changed now because it is a workflow decision.

### 4.7 Appointment refresh — fixed

The built-in appointment integration now loads reliably and calls
`org-agenda-to-appt` with its refresh argument after a capture is finalized and
after an agenda file is saved. Saves are debounced for two seconds. A fifteen
minute timer also catches changes arriving from Nextcloud, Dropbox, or another
editor without requiring a local save operation.

The following sections are deferred workflow choices, not confirmed bugs. They
should be revisited together if Org becomes the active task system again.

### 4.8 Hard-coded daylight offsets are unnecessary

The calendar configuration hard-codes `+0100` and `+0200`. That matches
Europe/Berlin standard and daylight time, but system time-zone data already
knows when the transition occurs. Rely on the system zone unless the labels are
needed for a deliberate presentation. Hard-coded labels become misleading when
travelling or when the system zone changes.

### 4.9 Refile caching needs an invalidation policy

`org-refile-use-cache` improves completion performance, but large manual
outline changes can leave candidates stale. Bind or document
`org-refile-cache-clear`, or clear the cache after programmatic structure
changes. The current README already mentions this; the workflow should make it
routine rather than mysterious. If task refiling is retired, remove the cache
configuration too.

### 4.10 Configuration cleanup — completed

Duplicate assignments, settings that only repeated upstream defaults, and
low-value presentation defaults have been removed. The unused Agenda
logging/clocking block and its future-use comment were removed as well. Settings
that define intentional behavior remain, and the generated modules were
retangled from the canonical literate file.

## 5. Persistence, synchronization, and recovery

The current configuration intentionally disables lockfiles because stale locks
have repeatedly required manual cleanup. Normal recovery auto-save remains
enabled, but Emacs does not automatically write the visited file. Customize
output is sent to a new temporary file on each startup.

### What the synchronization method changes

Nextcloud is the selected provider for the time being. Choosing it instead of
Dropbox does not materially change concurrent editing safety. Both maintain
separate local replicas, synchronize whole-file changes, and preserve competing
edits as conflict copies rather than merging Org or Markdown structure. Their
differences are operational: Nextcloud offers self-hosting and WebDAV, while
Dropbox is simpler to operate and integrate with mobile applications.

The consequential choice is the storage model:

| Method | Concurrent-editing behavior | Main tradeoff |
| --- | --- | --- |
| Nextcloud or Dropbox | Separate local replicas can diverge; Emacs lockfiles do not cross machines | Offline access and convenient mobile sync, with conflict risk |
| One authoritative server | Clients edit one filesystem, making a single-writer policy easier to follow | Lowest conflict risk, but remote access requires a connection |
| Git | Conflicts are explicit and history is strong, but synchronization is manual | Good history and review, poor transparent mobile sync |

The conflict policy therefore does not need to wait for a choice between
Nextcloud and Dropbox: use only one provider, do not edit the same canonical
file on two machines, keep one Emacs server per machine, and make mobile capture
create uniquely named files. Choose between the two providers based on hosting
and client convenience, not an expectation that one can merge simultaneous
note edits safely.

### What lockfiles and auto-save actually protect

- Keep `create-lockfiles` disabled. Lockfiles can warn when two Emacs processes
  see the same filesystem, but stale locks have caused more disruption in this
  workflow than that warning has prevented. They would not lock a file against
  Drafts, a cloud client, Neovim, or an offline computer. Revisit this decision
  only if accidental same-filesystem concurrent edits become a recurring
  problem.
- Normal Emacs auto-save writes separate recovery files. They are kept outside
  the dotfiles repository and synchronized directories under the platform cache
  directory. The visited Nextcloud file changes only on an explicit or
  workflow-driven save.
- The former policy wrote the actual visited file after 30 idle seconds. It can
  be restored if explicit saving proves inconvenient:

  ```elisp
  (auto-save-visited-mode 1)
  (setq auto-save-visited-interval 30)
  ```

  This sends changes to Nextcloud quickly, but it can also synchronize
  half-finished or accidental edits and create more filesystem activity. If the
  former policy is restored, retain the separate recovery-file location.
- `custom-file` is now a stable path in the cache directory, but deliberately
  never loaded: the configuration is this Org file, not Customize. That keeps
  Customize from silently competing with it, and stops the old `make-temp-file`
  call leaving a stray file behind on every start. Load it if Customize should
  ever persist.
- Enable built-in `save-place-mode`, `recentf-mode`, `winner-mode`, and
  `repeat-mode`. Recentf is documented in [File Conveniences](https://www.gnu.org/software/emacs/manual/html_node/emacs/File-Conveniences.html),
  window-layout undo in [Window Convenience](https://www.gnu.org/s/emacs/manual/html_node/emacs/Window-Convenience.html),
  and transient repeat keys in [Repeating](https://www.gnu.org/software/emacs/manual/html_node/emacs/Repeating.html).
- Keep `savehist-mode`; it already complements these features.
- Back up the Markdown vault independently of its one primary sync mechanism.
  Sync is not backup. Git is excellent for history but not automatic mobile
  synchronization; do not run Git, iCloud, and Obsidian Sync concurrently over
  the same files.

### A safe Drafts-to-Org synchronization boundary

Use exactly one sync provider for the Org directory: Nextcloud **or** Dropbox,
never both. Keep Drafts one-way:

```text
Drafts capture
    ↓ explicit Export as Org action
new file in mobile-captures/
    ↓ one cloud provider
Emacs triage/refile
    ↓
notes.org, a Denote note, or deletion
```

New-file creation is substantially safer than appending to a shared
`inbox.org`: two machines can create different filenames without merging the
same bytes. The timestamp should include seconds; adding a short device suffix
is cheap insurance. Do not let Drafts edit canonical project, agenda, or Denote
files. If Inbox membership is required, add an Emacs import command later that
refiles the spool entry into `inbox.org`; that preserves the file-based Inbox
definition without making the mobile device a concurrent writer.

With Nextcloud, Drafts can use its WebDAV action directly. Nextcloud documents
[WebDAV access](https://docs.nextcloud.com/server/latest/user_manual/en/files/access_webdav.html)
and recommends its desktop clients when local offline copies are wanted. This
route offers control and works on macOS and Linux, but the server, WebDAV, TLS,
and sync client are all parts that must remain healthy. Nextcloud creates a
separate conflict file when local and remote versions both change, as described
in its [conflict documentation](https://docs.nextcloud.com/desktop/3.8/conflicts.html).

Dropbox is the easier operational route if self-hosting is not a goal. Drafts
has a direct Dropbox action and documents that iOS folder bookmarks work with
the Dropbox file provider. Dropbox still cannot merge arbitrary simultaneous
text edits; it also creates conflicted copies. The one-file-per-capture design
is therefore useful with either provider, not merely a Nextcloud workaround.

Connecting to the server and editing with terminal Emacs avoids cloud conflicts
and gives the full configuration, but it is an online-only workflow. Drafts can
capture locally while offline and retain the draft until export can be retried.
That division is honest: the phone supplies a durable capture queue, while the
server or desktop Emacs remains the place where Org structure is edited.

For private notes, use EasyPG (`.org.gpg`/`.md.gpg`) or a separately encrypted
storage area. Denote documents how to define encrypted file types, but encrypt
only the notes that need it; a wholly encrypted collection loses easy external
search and interoperability.

## 6. macOS integration

### Native application entry points

The existing Emacs Client application is still useful. It supplies precisely
what a shell alias cannot: Finder **Open With**, Dock drag-and-drop, Spotlight,
and Launch Services. An old Automator wrapper is unnecessary unless it provides
a distinct named Quick Action that the current client app lacks.

The app also registers `org-protocol`, but registration alone is not a reason to
send browser material into an unused Org task inbox. Keep the capability for
literate documents if useful; capture knowledge directly into the Markdown
inbox or a Denote note. Org documents the protocol in
[Protocols for External Access](https://orgmode.org/manual/Protocols.html).

### Apple Reminders from Emacs

The best integration is intentionally one-way and small. If creating a reminder
without leaving Emacs becomes useful on the Mac, define an Apple Shortcut that
accepts text and uses Reminders' “Add New Reminder” action, then invoke that
shortcut from Emacs through the `shortcuts` command-line tool. Let Reminders
handle list selection, due dates, recurrence, notification, and later edits.

Do not query Reminders into an Emacs buffer periodically or reconstruct its
state as Org headings. Direct use of Siri, the Share Sheet, and Reminders itself
will remain better on iPhone and iPad.

### Modifier keys

The current configuration sets `mac-command-modifier`, but this is a native NS
build. The documented variables are `ns-command-modifier`,
`ns-alternate-modifier`, and their right-hand variants. Use those explicitly.
The GNU [macOS/NS customization documentation](https://www.gnu.org/software/emacs/manual/emacs.html#Mac-_002f-GNUstep-Customization)
explains that `none` leaves a modifier available to macOS for character entry.

The current conceptual mapping is sound:

- Command → Super, preserving standard Emacs Meta keys;
- left Option → Meta;
- right Option → `none`, preserving accented and special-character entry.

Only add Command-C/V/A/S style bindings if native-app muscle memory is more
valuable than the Super key space. Global remapping can conflict with existing
Emacs and Evil commands; a small, deliberate set is better than a complete
macOS imitation.

### Clipboard and drag-and-drop

Graphical NS Emacs uses the macOS pasteboard directly, so ordinary kill/yank
and GUI copy/paste require no `pbcopy` integration. Finder can open files in the
client app, and native Emacs supports file drag events and macOS Services.

Use `pbcopy`/`pbpaste` only from shell commands or when bridging a remote
terminal. Avoid clipboard packages that periodically poll or overwrite the
kill ring; the built-in integration is already better.

### Secrets

Store service credentials through `auth-source`, not in the literate
configuration. Emacs supports encrypted auth files and, on
Linux, Secret Service or `pass`; see [Keeping Persistent Authentication Information](https://www.gnu.org/software/emacs/manual/html_node/emacs/Authentication.html).
The installed Emacs 31 source also includes macOS Keychain backends, making
Keychain the natural Mac choice once the consuming package is confirmed to use
`auth-source`.

## 7. Linux integration

### Prefer a native Wayland build on Sway

On Debian/Sway, prefer an Emacs build with PGTK/Wayland support. It gives native
Wayland clipboard, scaling, input, and window behavior without forcing the
application through XWayland. Verify with `M-: window-system`; a graphical PGTK
frame reports `pgtk`.

This is a build choice, not a reason to fork the Lisp configuration. Keep
platform differences behind `system-type`, `window-system`, and per-frame
checks.

### Desktop services

- Let systemd own the daemon lifecycle and logs.
- Use the Emacs Client desktop entry for file associations.
- Use `xdg-open` for external files and URLs where the existing opener helper
  needs a platform-neutral route.
- Use Secret Service (GNOME Keyring, KDE Wallet, or compatible KeePassXC
  integration) or `pass` as the Linux `auth-source` backend. The
  [auth-source manual](https://www.gnu.org/software/emacs/manual/html_mono/auth.html)
  documents Secret Service support.
- Install the same fonts used on macOS, but keep icons optional. A daemon may
  create its first frame in a TTY where Nerd Font glyphs are unavailable.

Apple Reminders has no native Linux client in this architecture. Use iCloud.com
or an Apple device for task capture/review; do not restore Org GTD solely to
fill that platform gap unless Linux task capture becomes frequent enough to
justify choosing a genuinely cross-platform task manager.

### Keep platform code narrow

Do not maintain `init-macos.el` and `init-linux.el` copies of large subsystems.
Use small adapters for:

- open/reveal in the native file manager;
- desktop notifications;
- credentials;
- font candidates;
- daemon startup outside Emacs.

Org, Denote, completion, Magit, Eglot, and almost all key bindings should remain
identical.

## 8. Emacs in a terminal and on a server

There are three distinct remote workflows. Each is best for a different job.

### Rank 1: local graphical Emacs plus TRAMP

For sustained work, use the local GUI and open:

```text
/ssh:user@host:/path/to/file
```

TRAMP makes remote files and Dired behave like local buffers and runs processes
on the remote host when `default-directory` is remote. Its syntax and behavior
are documented in the [TRAMP Quick Start Guide](https://www.gnu.org/software/emacs/manual/html_node/tramp/Quick-Start-Guide.html).

Advantages:

- local fonts, clipboard, themes, packages, and macOS integration;
- no full Emacs installation or dotfiles required on the server;
- remote Dired, compilation, shell commands, and `/sudo:` are available;
- one local kill ring and one notes/task environment.

Limitations:

- language servers usually need explicit remote configuration and can be slow;
- projects with huge file counts or high-latency links may feel sluggish;
- shell startup output and unusual SSH configuration can confuse TRAMP.

Use SSH ControlMaster carefully for connection reuse, keep remote shell startup
quiet for non-interactive sessions, and avoid running local file watchers over
large TRAMP trees.

### Rank 2: a remote terminal client to a remote daemon

For long sessions on a development server, install Emacs there and run:

```sh
ssh -t host 'emacsclient -t -a ""'
```

This starts or reuses an Emacs daemon **on that server**. It survives a dropped
terminal, retains buffers and processes, and avoids transferring every file
operation through TRAMP. Run it inside tmux if preserving the terminal layout
also matters.

Use the same dotfiles, but allow capabilities to degrade cleanly:

- no GUI-only icon mode in TTY frames;
- theme selected for 256-color or truecolor terminal support;
- no assumptions about macOS modifiers or desktop notifications;
- language-server packages enabled only when their executables exist;
- a terminal-safe font and mode line.

Do not connect a local `emacsclient` directly to the remote daemon's socket.
Run the client after SSHing to the host. Unix-domain sockets are the safe normal
case; exposing Emacs's TCP server increases authentication and network risk
without improving this workflow.

### Rank 3: one-shot `emacs -nw`

Use `emacs -nw file` for recovery machines, root shells, containers, and hosts
where no persistent daemon is wanted. It is slower to initialize and state is
discarded on exit, but it has the fewest moving parts. `emacs -Q -nw` is an
important recovery command when the configuration itself is broken.

### Terminal clipboard, mouse, and color

In the same local machine, graphical and TTY frames belong to one daemon and
therefore share the Emacs kill ring. System clipboard behavior depends on the
terminal.

The installed Emacs 31 xterm layer recognizes Kitty and supports OSC 52
selection operations, bracketed paste, mouse reporting, background-color
reporting, and cursor capabilities. This makes a modern Kitty/Emacs TTY much
better than older terminal Emacs advice suggests. Still test the actual remote
chain: SSH and tmux can filter capabilities, and clipboard reads are more
restricted than writes for security reasons.

Practical rules:

- use Emacs kill/yank inside Emacs;
- use Kitty's paste shortcut for desktop-to-terminal paste;
- hold Shift when a terminal mouse selection must bypass Emacs mouse tracking;
- use `M-x xterm-mouse-mode` on older Emacs versions if it is not automatic;
- set `COLORTERM=truecolor` only when the whole terminal path supports it;
- prefer Modus or the selected Ef theme with tested terminal contrast;
- avoid relying on Nerd Font icons in administrative or minimal server shells.

One daemon can display graphical and TTY frames simultaneously, but themes are
largely global. A face that looks excellent in a graphical frame can be reduced
to the terminal palette. If mixed frames become a daily workflow, choose the
most terminal-safe theme globally rather than trying to switch the entire theme
per frame.

## 9. High-value built-in improvements

Before installing packages, use more of the Emacs already present.

### `save-place-mode`, `recentf-mode`, `winner-mode`, and `repeat-mode`

These restore positions, surface recently visited files, undo/redo window
layouts, and make repeated key sequences shorter. They work in GUI and TTY
frames and have negligible conceptual cost. They are enabled globally. Recentf
keeps 200 entries, and remote file-access checks are limited to five seconds so
an unavailable TRAMP host cannot block Recentf indefinitely.

### `project.el`

The current Consult and Magit setup can build on the standard project API
without a new project manager. The built-in project commands cover file search,
regexp search, buffer switching, compilation, shell/Eshell, and VC status; see
[Working with Projects](https://www.gnu.org/software/emacs/manual/html_node/emacs/Projects.html)
and [Project File Commands](https://www.gnu.org/software/emacs/manual/html_node/emacs/Project-File-Commands.html).

Use one tab per project only if it improves orientation. Emacs tab bars are
named window configurations, not browser-like buffer tabs, and work on
graphical and terminal frames. They can be hidden while still being controlled
by commands. See [Tab Bars](https://www.gnu.org/software/emacs/manual/html_node/emacs/Tab-Bars.html).

If plain tabs are too ephemeral, [`activities`](https://github.com/alphapapa/activities.el)
can suspend and resume a named task with its window configuration and buffers.
It is available from GNU ELPA and can use tabs without taking ownership of
unrelated tabs. I would start with built-in tabs, then add Activities only if
“resume writing/teaching/project X exactly where I left it” is a frequent need.

### Desktop/session persistence

`desktop-save-mode` can restore files, buffers, tabs, and window layouts, but it
is not an automatic win with a daemon: the manual recommends delaying restore
until the first client frame if necessary. Start with save-place/recentf and
explicit project tabs. Add desktop persistence only if reconstructing sessions
remains costly. The tradeoffs are documented in
[Saving Emacs Sessions](https://www.gnu.org/s/emacs/manual/html_node/emacs/Saving-Emacs-Sessions.html).

### Keep Org document-oriented

Retain `org-mode`, Babel languages that are actually used, export backends,
source editing, tables, and the literate tangle workflow. Agenda, `appt`, task
capture, refile, priority, and clock settings can be archived or removed. This
will make the remaining Org configuration far easier to understand and test.

## 10. Package recommendations

### Tier A: add for a demonstrated need

#### `envrc`

Per-project `direnv` environments are a cleaner fit than putting every language
tool into the global shell PATH. This matters when Python, Rust, Clojure, and
LaTeX projects require different toolchains. Allow `.envrc` files explicitly
and never commit secrets into them. [`envrc`](https://github.com/purcell/envrc)
keeps these environments buffer-local, so two projects can use different tool
versions in the same Emacs process.

### Tier B: good trials

#### `org-modern` and `org-appear`

[`org-modern`](https://github.com/minad/org-modern) styles headings, lists,
tables, tags, and blocks without changing file contents. `org-appear` reveals
hidden emphasis markers and link details near point. They complement the
current `org-hide-emphasis-markers` preference.

Enable visual styling only in graphical frames at first. Terminal alignment and
glyph availability deserve separate testing. Do not combine several competing
Org beautification packages.

#### `org-transclusion`

[`org-transclusion`](https://github.com/nobiot/org-transclusion) displays linked
content from Org, Markdown, plain text, or source files without copying it into
the document. It is valuable for assembling teaching material, project status
reports, and writing from atomic Denote notes. It is not required for basic
note linking, and excessive transclusion can make source ownership less clear.

#### Popper

[`popper`](https://github.com/karthink/popper) can keep Help, compilation, REPL,
diagnostics, and transient process buffers from repeatedly disrupting the
working layout. It has real value in a development-heavy Emacs, but requires a
carefully curated popup buffer list. Poor rules are more irritating than
default `display-buffer` behavior.

#### `dired-preview` — installed

No longer a candidate. [`dired-preview`](https://elpa.gnu.org/packages/dired-preview.html)
is configured and bound to `V` in `dired-mode-map`, as a manual toggle rather
than a default, with a delay and a size limit and archives and disk images
excluded — which is the shape this section recommended.

#### Eat or Vterm

Use an in-Emacs terminal when a shell should share the project, window layout,
and buffer switching. Do not expect it to replace Kitty for every task.

- Eat is implemented in Emacs Lisp, supports rich terminal behavior, and can
  integrate with Eshell. It avoids a native module but is not currently in GNU
  ELPA/MELPA through the simplest route.
- [`vterm`](https://github.com/akermu/emacs-libvterm) uses `libvterm`, is fast
  and highly compatible, but needs the native module toolchain and sends many
  keys directly to the terminal application. Its own documentation notes that
  this is less integrated with ordinary Emacs editing and Evil.

For this configuration I would trial Eat first for integration, then choose
Vterm if terminal throughput or compatibility is inadequate. Keep Kitty for
long-running shells, SSH multiplexing, and recovery when Emacs is restarting.

### Tier C: specialized additions

- `citar` plus `citar-denote`: citations and literature notes driven by a BibTeX
  library.
- `org-noter`: synchronized notes alongside PDFs or EPUBs; most attractive if
  the retained `pdf-tools` configuration is later enabled.
- `denote-journal`: daily log, as described above.
- `consult-dir`: fast directory switching if normal Consult/project commands
  prove insufficient.
- `denote-org`: heading-level Denote/Org workflows, only if a separate
  Org-format note collection is later created.

### Packages and complexity I would avoid for now

- an Emacs distribution on top of the current literate configuration;
- Org-roam alongside Denote without a specific graph/database requirement;
- Org Agenda enhancement packages while Apple Reminders owns tasks;
- Treemacs merely to reproduce an IDE sidebar—Dired, Project, and Consult
  already cover navigation;
- multiple terminal emulators inside Emacs;
- several overlapping session/workspace packages;
- global automatic formatting beyond languages with a clear owner;
- a package solely to reproduce native macOS clipboard behavior;
- packages that duplicate the current completion stack.

## 11. Development and configuration maintenance

### Use built-in packages as built-ins

`use-package` and Which-Key are built into current Emacs releases. On the
current Emacs 31 build, mark them `:ensure nil` rather than asking the package
manager to install another copy. If the same dotfiles must support an older
Emacs, state the minimum version and handle only that compatibility boundary.

### Decide whether development snapshots are intentional

The installed Mac uses an Emacs 31.1 development snapshot. It provides the
newest terminal and platform work, but package ABI or byte-code changes can
force recompilation and occasionally reveal package incompatibilities. Use a
stable Emacs release on machines where reliability matters most, or keep the
snapshot intentionally and update it on a controlled cadence—not every time a
Homebrew update happens to run.

### Improve reproducibility only as far as needed

The present package setup installs from GNU ELPA, NonGNU ELPA, and MELPA without
a lockfile. That is easy to understand and usually sufficient for a personal
configuration. Before changing package managers, first record:

- the minimum Emacs version;
- required external executables and grammar compilers;
- a bootstrap/package-refresh procedure;
- a batch command that loads or byte-compiles the configuration;
- a smoke test for GUI, daemon, and TTY startup.

Exact package locking is justified if a fresh Linux machine repeatedly receives
incompatible versions. It otherwise adds another moving part to a configuration
that already uses upstream package metadata effectively.

### Add three lightweight checks

1. **Tangle check:** tangle `emacs-init.org` and fail if generated modules
   differ from the working tree.
2. **Batch load check:** start Emacs in batch mode with the repository config
   and treat initialization warnings as visible results.
3. **Interactive smoke test:** after upgrades, open one GUI client frame and
   one Kitty TTY client, execute a trusted Org Babel block, open a Denote note,
   start Eglot in a small project, and inspect `*Messages*`.

The literate Org file is canonical. Never fix only `init.d/*.el`; the next
tangle would undo it.

## 12. A phased implementation plan

### Phase 1: reliability and safety

- [x] Document the one-server policy.
- [x] Document `emacsclient -t` for terminal frames; no additional alias or
  Emacs configuration is required.
- [x] Repair Org Babel safety, file-based Inbox membership, deadline grouping,
  project containers, meeting-note capture, and appointment refreshing.
- [x] Keep the repaired Org workflow dormant but usable while Apple Reminders
  remains authoritative.
- [x] Keep lockfiles disabled because stale locks have repeatedly caused
  problems; revisit only if same-filesystem concurrent edits recur.
- [x] Use Nextcloud as the sole cloud provider for the time being and retain
  normal recovery auto-save without 30-second writes to visited files.
- [x] Replace the Mac modifier variable with the documented NS variable.
- [x] Remove duplicate/default assignments, low-value presentation defaults,
  and the unused Agenda logging/clocking block.

### Phase 2: daily workflow

- [x] Enable save-place, Recentf, Winner, and Repeat modes.
- [ ] Make a backup and test Denote against a representative subset of real
  Obsidian Markdown notes.
- [ ] Choose the mobile capture route: an Obsidian Markdown inbox, or Drafts
  exporting one new Org file per capture.
- [ ] Implement one desktop triage command for the chosen mobile inbox.
- [ ] Test link creation, conversion, rename behavior, YAML properties, and
  synchronization on macOS, Debian, iPhone, and iPad.
- [ ] Decide whether Denote owns a subdirectory or the whole vault.
- [ ] Promote `~/denote-test/` only after that trial succeeds.

### Phase 3: selective expansion

- [ ] Add a macOS-only “Add Reminder” command only if leaving Emacs for capture
  is genuinely disruptive.
- [ ] Build a Denote-filename Shortcut only if mobile-inbox triage becomes
  costly.
- [ ] Trial `denote-journal` if a daily knowledge log is wanted.
- [ ] Trial project tabs or Activities, not both at first.
- [ ] Add Eat or Vterm only if project-local shells inside Emacs would be used.
- [ ] Add transclusion, bibliography, or PDF-note packages only when a real
  document workflow calls for them.

## 13. Practical command reference

```sh
# Existing graphical client; asynchronous
ec file

# Explicit terminal client, starting a daemon on demand
emacsclient -t -a "" file

# Blocking edit for Git or another caller; finish in Emacs with C-x #
emacsclient -t -a "" file

# Graphical client without the alias
emacsclient -c -n -a "" file

# Remote daemon and terminal client on the remote host
ssh -t host 'emacsclient -t -a ""'

# Recovery without the personal configuration
emacs -Q -nw

# Linux daemon lifecycle
systemctl --user status emacs.service
systemctl --user restart emacs.service
journalctl --user -u emacs.service
```

Inside Emacs:

```text
C-x C-f /ssh:user@host:/path/to/file   open a remote file with TRAMP
C-x d   /ssh:user@host:/path/          open remote Dired
C-x #                                  finish a blocking client request
M-x server-edit-abort                  abort a blocking client request
M-x denote                             create a durable note
M-x denote-link                        link to a durable note
M-x denote-backlinks                   inspect incoming links
M-x consult-denote-find                find a Denote note
C-x C-f .../Inbox/Mobile inbox.md      triage mobile captures
```

## Sources

Primary manuals and project documentation used for this review:

- [GNU Emacs Server](https://www.gnu.org/s/emacs/manual/html_node/emacs/Emacs-Server.html)
- [Invoking emacsclient](https://www.gnu.org/s/emacs/manual/html_node/emacs/Invoking-emacsclient.html)
- [TRAMP Quick Start Guide](https://www.gnu.org/software/emacs/manual/html_node/tramp/Quick-Start-Guide.html)
- [GNU Emacs projects](https://www.gnu.org/software/emacs/manual/html_node/emacs/Projects.html)
- [GNU Emacs tab bars](https://www.gnu.org/software/emacs/manual/html_node/emacs/Tab-Bars.html)
- [GNU Emacs session persistence](https://www.gnu.org/s/emacs/manual/html_node/emacs/Saving-Emacs-Sessions.html)
- [GNU Emacs authentication](https://www.gnu.org/software/emacs/manual/html_node/emacs/Authentication.html)
- [Org code-evaluation security](https://orgmode.org/manual/Code-Evaluation-Security.html)
- [Org external protocols](https://orgmode.org/manual/Protocols.html)
- [Apple: create reminders on iPhone](https://support.apple.com/guide/iphone/create-reminders-iph88463e18/26/ios/26)
- [Denote manual](https://protesilaos.com/emacs/denote)
- [`denote-markdown`](https://elpa.gnu.org/packages/denote-markdown.html)
- [Denote Journal manual](https://protesilaos.com/emacs/denote-journal)
- [Denote Org manual](https://protesilaos.com/emacs/denote-org)
- [Denote Silo manual](https://protesilaos.com/emacs/denote-silo)
- [Obsidian for iOS and iPadOS](https://obsidian.md/help/ios)
- [Obsidian note synchronization](https://obsidian.md/help/sync-notes)
- [Obsidian Headless Sync](https://obsidian.md/help/sync/headless)
- [Obsidian URI](https://obsidian.md/help/uri)
- [Obsidian internal links](https://obsidian.md/help/links)
- [Obsidian Unique note creator](https://obsidian.md/help/Plugins/Unique%2Bnote%2Bcreator)
- [Drafts file actions](https://docs.getdrafts.com/docs/actions/steps/services)
- [Drafts folder bookmarks](https://docs.getdrafts.com/docs/settings/bookmarks)
- [`org-modern`](https://github.com/minad/org-modern)
- [`org-transclusion`](https://github.com/nobiot/org-transclusion)
- [`dired-preview`](https://elpa.gnu.org/packages/dired-preview.html)
- [`emacs-libvterm`](https://github.com/akermu/emacs-libvterm)
- [`activities`](https://github.com/alphapapa/activities.el)
- [`envrc`](https://github.com/purcell/envrc)
- [`popper`](https://github.com/karthink/popper)
