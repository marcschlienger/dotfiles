# Integrating Neovim on macOS and Linux

Research date: 2026-08-29

## Recommendation

I would use Neovim as a second editor without trying to reproduce Emacs inside
a terminal.

1. Keep terminal Neovim in Kitty as the common macOS/Linux implementation.
2. Make Kitty the bridge from Finder and Linux desktop applications to Neovim.
3. Keep ordinary terminal instances independent at first. Add a Neovim server
   only if repeated startup or nested editors become an actual problem.
4. Trial Neovide on macOS if native windows, Finder behavior, Command-key
   shortcuts, input methods, and document semantics matter enough to influence
   the Emacs-versus-Neovim decision.
5. Keep Emacs as the default file handler during the trial. Expose Neovim as an
   explicit **Open With** action instead of changing every text-file association.

This gives Neovim good desktop integration with little maintenance, retains one
configuration on both operating systems, and avoids an elaborate imitation of
`emacsclient`. Emacs will still have the more coherent server/client and macOS
application story; Neovide is the closest Neovim gets to a native application,
while Kitty is the more portable and transparent solution.

## What is already in place

The current dotfiles are much closer to this result than they may appear:

- Neovim 0.12.5 is installed on this Mac.
- Kitty 0.48.2 is installed and used on macOS and Linux.
- `EDITOR=nvim`, `VISUAL=$EDITOR`, and `vim=nvim` are already set in Zsh.
- Neovim has `clipboard=unnamedplus`, so normal yanks, puts, changes, and
  deletions use the operating-system clipboard.
- Yazi offers Neovim as its blocking secondary editor while Emacs remains the
  default graphical opener.
- Sway uses Kitty as its terminal and already has `wl-copy`-based clipboard
  history through `cliphist`.
- Kitty currently copies mouse selections to its private buffer `a1`, not the
  system clipboard; `Shift-Command-V` pastes that private buffer. This is a good
  way to preserve a useful selection without overwriting the macOS clipboard.
- The installed `kitty.app` already advertises text files, directories, scripts,
  and generic data to macOS Launch Services. It also provides **Open with
  kitty**, **New kitty Window Here**, and **New kitty Tab Here** Services.

The missing pieces are therefore integration policy and small launch adapters,
not a different Neovim configuration.

## Ranked integration ideas

| Rank | Idea | Value | Cost | Verdict |
| ---: | --- | --- | --- | --- |
| 1 | Use Kitty's file-opening actions as the cross-platform bridge | Very high | Low | Implement first |
| 2 | Verify native clipboard providers and keep safe terminal paste behavior | Very high | Low | Essential |
| 3 | Add a Linux `.desktop` entry that explicitly launches Kitty and Neovim | High | Low | Implement on Debian/Sway |
| 4 | Trial Neovide as an optional GUI frontend | High on macOS | Medium | Best native experiment |
| 5 | Separate asynchronous desktop opening from blocking editor calls | High | Low | Essential design rule |
| 6 | Integrate Git, `sudoedit`, file managers, and Kitty shell integration | High | Low | Implement incrementally |
| 7 | Add one Sway/Fuzzel launcher and, optionally, a macOS Quick Action | Medium | Low | Useful convenience |
| 8 | Use OSC 52 or Kitty's clipboard kitten over SSH | Medium to high | Low | Add when needed |
| 9 | Reuse an instance with Neovide or `neovim-remote` | Medium | Medium | Only after a real need appears |
| 10 | Use VimR instead of Neovide | Medium on macOS | Medium | Worth comparing, not the default |
| 11 | Use Firenvim for browser text areas | Niche | Medium/high | Opt-in for selected sites only |
| 12 | Build a custom Automator application immediately | Low incremental value | Medium | Avoid for now |
| 13 | Enable unrestricted Kitty remote control or silent clipboard reads | Low | Security cost | Avoid |

## 1. Kitty as the common application boundary

This is the best fit for the current setup. Kitty can already receive files
through Finder's **Open With**, Dock drag-and-drop, macOS Services, Linux file
associations, and its `kitty +open` command. Its `launch-actions.conf` decides
what happens next. Kitty's documented default is already to open text files in
the configured terminal editor.

A deliberate configuration would look like this:

```conf
# ~/.config/kitty/launch-actions.conf
protocol file
mime text/*
action launch --type=os-window -- $EDITOR -- $FILE_PATH
```

Set `editor nvim` in `kitty.conf` if Neovim should be independent of the
environment inherited by a graphical launch. Kitty otherwise resolves its
editor from `VISUAL`, then `EDITOR`, and can ask the login shell if those are
missing. On newer Kitty versions, `env read_from_shell=PATH EDITOR VISUAL` is
another option, but it adds startup work and is unnecessary if `editor nvim`
resolves reliably.

The entry point is then the same conceptually everywhere:

```sh
# macOS: Finder, Services, scripts, and other applications
open -a kitty.app -- file1 file2

# Both platforms: ask Kitty to classify and open the arguments
kitty +open file1 file2
```

Why this ranks first:

- It preserves the exact terminal rendering, fonts, themes, and Option-as-Meta
  behavior already configured in Kitty.
- It works with both macOS Launch Services and Linux file associations.
- Kitty passes file paths as arguments; a correct action therefore handles
  spaces without constructing unsafe shell command strings.
- It does not require a background daemon or unrestricted remote-control socket.
- It also covers clickable file hyperlinks and remote-file workflows.

The limitation is equally important: macOS sees the application as Kitty, not
as a native Neovim document editor. Application switching, menus, tabs, proxy
icons, and document state remain terminal-oriented.

### macOS usage

Use Finder's **Open With → kitty** or the existing **Open with kitty** Service.
Dragging a text file onto Kitty's Dock icon uses the same launch actions. Do not
make Kitty the default for all text files until the Neovim trial has proved
itself; leaving Emacs as the default and using **Open With** makes coexistence
pleasant.

An Automator or Shortcuts Quick Action named **Open in Neovim** is still useful
if the label **Open with kitty** feels too indirect. It should merely call
`open -a kitty.app -- "$@"`; it should not duplicate editor-selection logic.
That makes the Quick Action a thin user-interface alias rather than another
launcher that can go stale.

### Linux usage

For Sway, use an explicit desktop entry rather than `Terminal=true`. The latter
asks the desktop environment to choose a terminal and is less predictable in a
minimal Wayland session. A suitable entry is:

```ini
# ~/.local/share/applications/nvim-kitty.desktop
[Desktop Entry]
Type=Application
Name=Neovim in Kitty
Comment=Edit files in Neovim inside Kitty
TryExec=kitty
Exec=kitty --detach nvim -- %F
Terminal=false
NoDisplay=true
MimeType=text/plain;text/markdown;text/x-shellscript;
```

After installing it, refresh the desktop database if available:

```sh
update-desktop-database ~/.local/share/applications
```

The entry then appears in file-manager **Open With** menus. Add MIME types only
for formats that are genuinely useful; setting `text/plain` as the global
default is optional. The freedesktop specifications put application metadata in
the `.desktop` file and user defaults in `mimeapps.list`, so the association is
portable across compliant desktops.

## 2. Copy and paste: use the correct layer

There are two different kinds of selection in a terminal editor:

1. A Neovim Visual-mode selection belongs to Neovim.
2. A mouse selection made by the terminal belongs to Kitty.

Confusing them is the source of most terminal copy-and-paste complaints.

### Neovim's clipboard

Neovim delegates the `+` and `*` registers to a provider. The current
`clipboard=unnamedplus` setting makes the `+` register the default, so:

- `y`, `d`, `c`, and `p` interact with the system clipboard;
- `"+y` and `"+p` remain the explicit forms;
- on macOS Neovim automatically finds the built-in `pbcopy`/`pbpaste` tools;
- on Sway it should find `wl-copy`/`wl-paste` from the `wl-clipboard` package;
- on an X11 session it can fall back to `xsel` or `xclip`.

Run this after installation or when clipboard behavior changes:

```vim
:checkhealth vim.provider
```

`unnamedplus` is the easiest behavior while using Emacs and Neovim alongside
each other. Its tradeoff is that deleting or changing text also overwrites the
desktop clipboard. If that becomes irritating, remove `unnamedplus` and map
intentional system operations instead:

```lua
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p')
```

I would not change this until the existing simple behavior causes a problem.

### Kitty's clipboard

- On macOS, `Command-V` is terminal paste. Kitty sends bracketed paste to
  Neovim, which can distinguish pasted text from typed commands.
- On Linux, use `Ctrl-Shift-V` for terminal paste.
- `Command-C`/`Ctrl-Shift-C` copies a Kitty terminal selection, not a Neovim
  Visual selection. Hold Shift while selecting with the mouse if Neovim has
  captured mouse input.
- The current `copy_on_select a1` deliberately uses a private Kitty buffer.
  `Shift-Command-V` pastes it, while the ordinary operating-system clipboard
  remains untouched.

This division is sensible: use `y`/`p` for editor text and terminal shortcuts
for content selected outside Neovim or pasted from another application.

### Neovide clipboard shortcuts

Neovide forwards keys but does not invent `Command-C` and `Command-V` mappings.
Its official FAQ recommends GUI-only mappings such as:

```lua
if vim.g.neovide then
  vim.keymap.set("x", "<D-c>", '"+y', { desc = "Copy" })
  vim.keymap.set({ "n", "i", "x", "c", "t" }, "<D-v>", function()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
  end, { desc = "Paste" })
end
```

Keep those conditional. In the TUI, Kitty should continue to own the Command
key conventions.

## 3. Neovide for the most native macOS experience

Neovide is the GUI I would try first, but as an additional frontend rather than
as a replacement for terminal Neovim. Current Neovide versions provide more
macOS integration than older comparisons suggest:

- files can be opened from Finder;
- a macOS-only `--reuse-instance` mode forwards later open requests;
- multiple editor windows can use native macOS tabs;
- Window/Dock menus and configurable system shortcuts are available;
- the title bar can expose the current file as a document proxy icon and show
  the native modified-document indicator;
- Option can be treated as Meta on the left, right, both, or neither side;
- IME, trackpad scrolling, drag-and-drop, Metal rendering, and native global
  activation are supported;
- the same Neovim configuration and plugins continue to run underneath;
- Neovide also runs on Linux if a common graphical frontend is desirable.

For a short trial, start with:

```sh
neovide --reuse-instance file
```

Then consider these GUI-only settings:

```lua
if vim.g.neovide then
  vim.g.neovide_proxy_icon = true
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"
end
```

Native tabs and global hotkeys live in Neovide's `config.toml`. Do not enable
cursor and scrolling animations merely because they exist; a low-motion setup
will feel more like the precise Emacs and terminal experience.

Why it is not ranked first: it introduces a second rendering/input layer,
GUI-specific mappings, and another application to maintain. It also does not
make terminal Neovim launched by Git, Yazi, or SSH disappear. It is nevertheless
the fairest way to judge whether macOS integration is still a decisive Emacs
advantage.

VimR is the alternative if a Swift/Cocoa application and integrated workspace,
file browser, Markdown preview, and trackpad support matter more than having the
same GUI on Linux. Neovide has the stronger cross-platform story and should be
tested first.

## 4. Do not conflate desktop openers with blocking editors

Two commands with similar names need opposite lifetime behavior:

- A desktop opener should detach immediately. Finder, Fuzzel, and file managers
  should not wait for the editor window to close.
- A blocking editor must remain alive until editing is finished. Git commits,
  interactive rebases, `sudoedit`, and programs that create temporary files rely
  on this.

Recommended policy:

| Caller | Command style |
| --- | --- |
| Finder, macOS Service, Fuzzel, Linux file manager | Kitty/Neovide opener; detached |
| Interactive shell | `nvim file`; blocking |
| Git from a normal terminal | `nvim`; blocking |
| Yazi | existing blocking `nvim %s` entry |
| `sudoedit` | `SUDO_EDITOR=nvim` or Kitty's `edit-in-kitty` |
| Existing Neovim `:terminal` | `nvr` only if nested Neovim becomes annoying |

Do not point `GIT_EDITOR` at an asynchronous Finder-style launcher: Git may read
the temporary file before it has been edited.

## 5. Server/client workflows

Neovim has native RPC sockets and can start with:

```sh
nvim --listen "$XDG_RUNTIME_DIR/nvim-main.sock"
nvim --server "$XDG_RUNTIME_DIR/nvim-main.sock" --remote file
```

It can also attach another terminal UI with `--remote-ui`. This is useful for a
long-lived remote session, but it is not as polished as `emacsclient`:

- native Neovim still lacks the `--remote-wait` family needed by blocking
  callers;
- opening a file in a server does not by itself find and focus the Kitty window
  displaying that server;
- multiple attached UIs share editor state and can be surprising;
- one global process mixes working directories, LSP clients, project state, and
  plugin state.

If a server becomes desirable, prefer one socket per project over one global
daemon. For an Emacs-like command with wait support, `neovim-remote` (`nvr`) is
the mature convenience layer:

```sh
nvr --remote file
git config --global core.editor 'nvr --remote-wait-silent'
```

`nvr` can also avoid starting a nested Neovim from `:terminal`. The cost is a
Python dependency and another process-discovery convention. Neovide's
`--reuse-instance` is simpler for GUI-originated macOS file opens. Start with
independent instances; add `nvr` only when an observed workflow justifies it.

Do not enable unrestricted Kitty remote control merely to focus editor windows.
Kitty supports scoped remote-control permissions, but file opening does not need
remote control at all.

## 6. Integration by application type

### Shell and terminal tools — rank 1

Keep `EDITOR=nvim` and `VISUAL=nvim`. Add a short `v` alias only if it is more
comfortable than `nvim`; the existing `vim=nvim` alias is sufficient. Kitty's
shell integration already supports opening new tabs/windows at the current
directory and provides `edit-in-kitty`, including across its SSH kitten.

For commands that understand line numbers, preserve normal Neovim syntax:

```sh
nvim +42 file
```

### Git and command-line programs — rank 2

Plain `nvim` is the most reliable Git editor because its process blocks. Only
switch Git to `nvr --remote-wait-silent` after adopting a persistent server.
Keep diff and merge tools independent until there is a reason to couple them to
the main editing session.

For privileged files, prefer `sudoedit` over running Neovim as root:

```sh
SUDO_EDITOR=nvim sudoedit /etc/example.conf
```

Kitty also documents `SUDO_EDITOR='kitten edit-in-kitty'` for editing in a new
Kitty window.

### Finder and graphical file managers — rank 3

Use Kitty's existing Service on macOS and the explicit `.desktop` entry on
Linux. Neovide is the alternative when native document behavior matters. Keep
associations narrow and reversible during the trial.

### Yazi and terminal file managers — rank 4

The current Yazi ordering is good: Emacs opens asynchronously by default and
Neovim is available from **Open with** as a blocking editor. Reverse the order
only if Neovim becomes the primary editor. Ranger and similar programs should
continue to use `VISUAL`/`EDITOR`.

### Launchers and global shortcuts — rank 5

- On Sway, a Fuzzel entry or binding can run `kitty nvim` for a blank editor or
  a project-selecting wrapper.
- On macOS, Spotlight can launch Kitty or Neovide. A Shortcuts/Automator Quick
  Action is justified for selected Finder files, but should delegate to Kitty.
- Neovide now has its own optional global activation and editor-switcher
  shortcuts, which are preferable to a third-party hotkey daemon for that GUI.

### Clickable paths, compiler output, and remote files — rank 6

Kitty can attach actions to terminal hyperlinks. This allows paths printed by
`ls`, compilers, and other tools to open in the configured editor. Kitty's SSH
kitten also supports clicking a remote file, downloading it for local editing,
and transferring changes back. This is a substantial integration win that a
standalone Automator app cannot provide.

### Browsers and text areas — rank 7

Firenvim embeds Neovim into Firefox and Chromium-family text areas. It is useful
for long Markdown forms, issue descriptions, and comments, but it requests broad
website access and Safari is unsupported. Some browser shortcuts also conflict
with Neovim. If used at all, configure manual activation or a small site
allowlist; do not take over every text area.

### IDEs and language-specific applications — rank 8

Use each tool where it is strongest. Xcode can remain the Swift environment,
while Neovim handles general source code. VS Code's Neovim integration and other
embedded frontends are useful only when their surrounding IDE features are
needed; they are not necessary for desktop integration.

## 7. Linux, Wayland, SSH, and clipboard details

For Debian 13 with Sway, install `wl-clipboard`. That supplies the provider
Neovim expects and the `wl-copy`/`wl-paste` commands already referenced by the
Sway configuration. Install `xclip` or `xsel` only on machines that actually run
an X11 session.

Across SSH, the remote host cannot use the local Mac's `pbcopy` or the local
Wayland compositor. The choices, in order, are:

1. Let Neovim use OSC 52 for copying to the terminal's local clipboard, and use
   the normal terminal paste shortcut for pasting. This is simple and limits
   remote clipboard reads.
2. Use `kitten clipboard`, which works over Kitty SSH and can both read and
   write; keep Kitty's default confirmation for reads.
3. Define a custom Neovim clipboard provider only if automatic behavior is
   insufficient.

Neovim can force its built-in OSC 52 provider with:

```lua
vim.g.clipboard = "osc52"
```

Do this conditionally for remote sessions, not globally, because local
`pbcopy`/`wl-copy` providers are simpler and can read without terminal protocol
round trips. If tmux sits between Neovim and Kitty, tmux must expose clipboard
terminal capabilities and use `set-clipboard on` for applications inside tmux
to update the outer clipboard. Restart the tmux server after changing that
setting.

Do not configure Kitty to allow unprompted clipboard reads from arbitrary
terminal programs. A remote program reached over SSH would gain the same access.

## 8. Practical rollout

### Phase 1: no new GUI and no server

1. Confirm `:checkhealth vim.provider` on macOS and Debian.
2. Confirm `y` in Neovim can be pasted into a graphical application.
3. Add explicit Kitty launch actions for text files.
4. Test Finder **Open with kitty** and Dock drag-and-drop.
5. Add `nvim-kitty.desktop` on Linux and test it from a file manager or Fuzzel.
6. Keep Emacs as the default application.

### Phase 2: native macOS comparison

1. Install Neovide without changing file defaults.
2. Add GUI-only Command-C/Command-V and Option-as-Meta settings.
3. Test Finder opening, `--reuse-instance`, native tabs, proxy icons, input
   methods, full-screen behavior, and application switching for a week.
4. Compare this honestly with the Emacs client app rather than comparing Emacs
   with terminal Neovim alone.

### Phase 3: only if friction remains

1. Add a thin **Open in Neovim** Quick Action on macOS.
2. Add a Sway/Fuzzel shortcut for project selection.
3. Adopt `nvr` and per-project sockets only if nested editors or repeated
   launches are demonstrably inconvenient.
4. Try Firenvim only for specific browser workflows.

## What I would avoid

- Replacing Emacs file associations globally before the experiment is settled.
- A custom app bundle that duplicates Kitty's existing Launch Services support.
- A single global Neovim server for unrelated projects.
- An asynchronous opener as `GIT_EDITOR` or `SUDO_EDITOR`.
- `Terminal=true` desktop entries in a minimal Sway environment when Kitty can
  be invoked explicitly.
- Shell commands that interpolate filenames into a quoted string instead of
  passing `"$@"` as arguments.
- Globally forcing OSC 52 when native local clipboard tools are available.
- Disabling Kitty's clipboard-read confirmation.
- Enabling unrestricted Kitty remote control just to launch or focus Neovim.

## Sources

- [Neovim clipboard providers, including `pbcopy`, `wl-copy`, X11 tools, and OSC 52](https://neovim.io/doc/user/provider/#clipboard)
- [Neovim remote/server commands and the unsupported wait variants](https://neovim.io/doc/user/remote/)
- [Neovim GUI architecture and multiple UI clients](https://neovim.io/doc/user/gui/)
- [Kitty file-opening and launch-action configuration](https://sw.kovidgoyal.net/kitty/open_actions/)
- [Kitty shell integration, `edit-in-kitty`, and SSH behavior](https://sw.kovidgoyal.net/kitty/shell-integration/)
- [Kitty clipboard controls and their security implications](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clipboard_control)
- [Kitty clipboard kitten, including operation over SSH](https://sw.kovidgoyal.net/kitty/kittens/clipboard/)
- [Neovide command-line reference: instance reuse, native tabs, and servers](https://neovide.dev/command-line-reference)
- [Neovide macOS configuration: proxy icons, Option as Meta, windows, and global shortcuts](https://neovide.dev/configuration.html)
- [Neovide FAQ: Command-C and Command-V mappings](https://neovide.dev/faq.html#how-can-i-use-cmd-ccmd-v-to-copy-and-paste)
- [VimR, a Swift-based Neovim GUI for macOS](https://github.com/qvacua/vimr)
- [`neovim-remote` and its blocking remote-editor workflows](https://github.com/mhinz/neovim-remote)
- [Firenvim browser integration, permissions, and limitations](https://github.com/glacambre/firenvim)
- [Freedesktop Desktop Entry specification](https://specifications.freedesktop.org/desktop-entry/latest/)
- [Freedesktop MIME application association specification](https://specifications.freedesktop.org/mime-apps/latest/)
- [Apple Automator Quick Actions](https://support.apple.com/guide/automator/create-a-workflow-aut7cac58839/mac)
- [tmux clipboard and OSC 52 behavior](https://github.com/tmux/tmux/wiki/Clipboard)
