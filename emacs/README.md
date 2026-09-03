# Emacs configuration notes

This file records machine dependencies and optional improvements that are not
enforced by the configuration itself. The canonical configuration remains
`emacs/.emacs.d/emacs-init.org`.

## External dependencies

The editor configurations require this shared language-server and Python-tool
set. Install every executable on both macOS and Linux:

| Language | Executable | Used by | Current macOS status |
| --- | --- | --- | --- |
| C and C++ | `clangd` | Emacs and Neovim | Installed (`21.0.0`) |
| Go | `gopls` | Emacs | Not installed |
| Lua | `lua-language-server` | Neovim | Installed (`3.19.1`) |
| Python semantics and type checking | `ty` (`ty server`) | Emacs and Neovim | Installed (`0.0.74`) |
| Python linting and formatting | `ruff` (`ruff server` in Neovim) | Emacs and Neovim | Installed (`0.16.4`) |
| Rust | `rust-analyzer` | Emacs and Neovim | Installed (`1.98.0`) |
| LaTeX | `texlab` | Emacs and Neovim | Installed (`5.26.0`) |

Python deliberately uses two complementary Astral tools: ty owns completion,
navigation, and type analysis, while Ruff owns lint diagnostics and formatting.
`pylsp` is neither installed nor configured. Neovim runs the two native language servers
together and also exposes Ruff fixes and import organization. Emacs uses ty
through Eglot, `flymake-ruff` for diagnostics on save (or manual `C-c ! s`),
and `ruff-format` for formatting on save.

Neovim 0.11.3 or newer is required by the current `nvim-lspconfig` and for the
native `vim.lsp.config` and `vim.lsp.enable` APIs used by this configuration.
Debian 13's standard package is Neovim 0.10.4, so it needs a newer Neovim build
from another trusted package source. Version 0.12 or newer is recommended for
automatic terminal appearance detection; the current Mac has Neovim `0.12.5`.

Other configured features need these executables:

| Feature | Executable | Current macOS status |
| --- | --- | --- |
| Rust build, Clippy, and format on save | `cargo`, Clippy, `rustfmt`, and `rust-src` | Installed (Rust `1.98.0`; all components present) |
| LaTeX compilation | A TeX distribution providing `latexmk` or `pdflatex` | Missing |
| Markdown export | `multimarkdown` | Installed (`6.8.0`) |
| Org Babel Python | `python3` | Installed (`3.9.6`) |
| Org Babel R | `R` | Installed (`4.6.1`) |
| Spell checking | Enchant plus `en_US` and `de_DE` Hunspell dictionaries | Installed; Jinx is used where its module builds, Flyspell otherwise |

Swift development intentionally belongs to Xcode. Emacs retains `swift-mode`
for lightweight syntax highlighting, but has no Swift Eglot hook or Tree-sitter
grammar. `sourcekit-lsp` is therefore not a dotfiles dependency, including on
Linux. The current Mac has Apple Command Line Tools but not the full Xcode
application; install Xcode before resuming Apple-platform Swift development.

The Eglot hooks and Ruff formatting hook are intentionally unconditional. If a
language server is absent, Eglot cannot start for that language. If Ruff is
absent, Python buffers still open normally, but Ruff diagnostics are unavailable
and formatting reports the missing executable when the buffer is saved. Keeping
the hooks unconditional makes an incomplete development environment visible.

Go's save hook is the one exception. It organizes imports and reformats through
gopls, and both are server operations, so it checks that a server is managing
the buffer and otherwise does nothing: a `before-save-hook` that signals would
refuse the save outright. Nothing is hidden by that, because the unconditional
`eglot-ensure` on the same buffer already reports a missing gopls.

AUCTeX uses Skim on macOS when its `displayline` helper is installed, otherwise
it uses the system `open` command. On Linux it prefers Zathura and falls back to
`xdg-open`. Skim and `pdf-tools` are optional and are not installed or required.
The deferred PDF Tools configuration is retained and activates after the
package is installed explicitly and Emacs is restarted. A TeX distribution is
still required to compile PDFs.

## Theme families and automatic switching

Ef Maris is the default. Ef Maris, Modus Tinted, Catppuccin Latte/Macchiato,
and Solarized light/dark pairs are installed for Emacs, Kitty, Neovim, and
Zathura. Each application owns its theme selection. The optional
`wayland-theme` command synchronizes Kitty with Sway, Waybar, Mako, Fuzzel,
and Swaylock without coupling any of those applications to Emacs or Neovim.

### Emacs

Emacs uses Circadian with the configured coordinates, so it changes at local
sunrise and sunset. The controls affect Emacs only:

- `C-<f5>` or `M-x ms/theme-family-select`: select and persist another family.
- `<f5>` or `M-x ms/theme-pair-toggle`: temporarily toggle light/dark within
  that family. The next Circadian event resumes automatic switching.
- `M-<f5>` or `M-x consult-theme`: preview any installed Emacs theme without
  changing the automatic pair.

The Emacs family is stored per machine in
`$XDG_STATE_HOME/dotfiles/emacs-theme-family`, falling back to
`~/.local/state/dotfiles/emacs-theme-family`. It stays outside the Git
repository and is not read by Kitty or Neovim.

### Kitty

Kitty's automatic files load `themes/current-light.conf` and
`themes/current-dark.conf`; the no-preference fallback uses the light palette.
The current default is Ef Maris. To change Kitty independently, copy any named
light/dark pair from `themes/` over those two current files. To select the same
family for Kitty and the Wayland desktop at once, use `wayland-theme ef`,
`wayland-theme modus`, `wayland-theme catppuccin`, or
`wayland-theme solarized`.

Kitty has recognized `light-theme.auto.conf`, `dark-theme.auto.conf`, and
`no-preference-theme.auto.conf` since version 0.38. Use 0.42 or newer for the
subsequent automatic-theme startup and reload fixes. After installing these
dotfiles, run `stow -R kitty` and restart Kitty once. Thereafter Kitty follows
changes reported by the operating system:

- On macOS, set **System Settings → Appearance → Auto**. macOS publishes its
  transition and Kitty changes immediately.
- GNOME and KDE can publish their current light/dark preference through the
  desktop portal. GNOME commonly reports `no-preference` for its normal light
  appearance, so that fallback deliberately uses the light palette.
- Sway does not schedule an OS color preference by itself. A good companion is
  [Darkman](https://darkman.whynothugo.nl/), which calculates sunrise/sunset
  and publishes the result through the XDG settings portal. A suitable
  `~/.config/darkman/config.yaml` is:

  ```yaml
  lat: 49.0
  lng: 8.6
  usegeoclue: false
  portal: true
  ```

  With xdg-desktop-portal 1.17 or newer, its Sway portal configuration must
  prefer Darkman for settings:

  ```ini
  [preferred]
  org.freedesktop.impl.portal.Settings=darkman
  ```

  Install Darkman and enable its user service using the mechanism supplied by
  the Linux distribution. Without a working settings portal, Kitty safely
  stays on the light `no-preference` fallback rather than pretending that it
  can detect a transition.

### Neovim

Neovim 0.12 detects the host terminal's appearance; Kitty also notifies it when
the automatic color scheme changes. The configuration responds by loading the
light or dark member of Neovim's selected family. Change `default_family` in
`lua/config/theme.lua` to persist a different Neovim family. The commands
`:ThemeFamily ef-maris`, `:ThemeFamily modus-tinted`,
`:ThemeFamily catppuccin`, `:ThemeFamily solarized`, `:ThemeLight`,
`:ThemeDark`, and `:ThemeToggle` affect only the current Neovim session.

The terminal palettes intentionally share the same base colors but cannot
match the full granularity of the Emacs themes: Kitty exposes a small terminal
UI plus an ANSI palette, while Emacs themes style hundreds of semantic faces.

### Zathura

Zathura's palette is selected independently in `.config/zathura/themes/current`.
Leave exactly one include active and restart Zathura after changing it. The
default is Ef Maris Dark. Document recoloring remains disabled at startup;
`Ctrl-r` toggles recoloring with the selected palette while preserving hues
and image colors where Zathura supports them.

## Tree-sitter

Emacs provides the Tree-sitter integration, but each language still needs a
native grammar library. Those libraries are deliberately not stored in the
repository because they depend on the operating system and CPU architecture.
The generated `emacs/.emacs.d/tree-sitter/` directory is ignored by Git.

On a fresh clone, the configuration first checks `treesit-available-p` to make
sure Emacs itself has Tree-sitter support. It then checks every language with
`treesit-language-available-p`. Only grammars that can be loaded are remapped
to their Tree-sitter major modes; otherwise C, C++, Go and Python keep using
their traditional major modes. A missing grammar therefore degrades cleanly
instead of breaking file opening: `go-mode` claims `.go` on its own, and the
remapping only redirects it to `go-ts-mode` once the grammar is built. Rust
uses `rust-mode`'s separate
Tree-sitter integration only when the Rust grammar is available at startup;
otherwise it derives from ordinary `prog-mode`. The Emacs Lisp grammar is not
automatically remapped.

Install these prerequisites before building grammars:

| Requirement | macOS | Debian/Ubuntu | Fedora | Arch Linux |
| --- | --- | --- | --- | --- |
| Emacs | Emacs 29 or newer, built with Tree-sitter support | Emacs 29 or newer, built with Tree-sitter support | Emacs 29 or newer, built with Tree-sitter support | Emacs 29 or newer, built with Tree-sitter support |
| Git, C/C++ compiler, and linker | Run `xcode-select --install` | `sudo apt install git build-essential` | `sudo dnf install git gcc gcc-c++` | `sudo pacman -S git base-devel` |
| Grammar sources | Internet access during the first build | Internet access during the first build | Internet access during the first build | Internet access during the first build |

Evaluate `M-: (treesit-available-p) RET` first; it must return non-nil. The
standalone `tree-sitter` command-line program is not required for the C, C++,
Emacs Lisp, Go, Python, or Rust recipes. Emacs must be able to find Git and the
compilers through `exec-path`.

On each macOS or Linux machine, run once after cloning:

```text
M-x ms/treesit-install-missing-grammars
```

This attempts to download and build the configured C, C++, Emacs Lisp, Go,
Python, and Rust grammars under the local Emacs directory. The command
reports an individual warning for a grammar that fails and continues with the
others. It then enables remapping only for the grammars that loaded
successfully. The locally generated binaries will be `.dylib`-compatible on
macOS and `.so` libraries on Linux, so every machine must build its own copies.

After installation, `M-x ms/treesit-activate-remappings` is enough to pick up
C, C++, Go, and Python in the current session.
`M-x ms/treesit-install-missing-grammars` calls it for you, so the two routes
behave the same. Restarting is still required if
`rust-mode` was already loaded, because that package chooses its parent mode
when it loads. Confirm a buffer is
using Tree-sitter by checking `M-x describe-mode`: C, C++, Go, and Python should
have a `-ts-mode` name; Rust remains named `rust-mode` even when it derives from
`rust-ts-mode`.

The grammar recipes currently follow each repository's default branch. Pin
revisions in `treesit-language-source-alist` if reproducible grammar builds
become more important than automatically picking up parser updates.

## Org

- `org-directory` is `~/org`; create or restore that directory before using
  capture, agenda, or refile commands.
- The agenda contains the directory itself rather than a one-time wildcard
  expansion, so new `.org` files are discovered without restarting Emacs.
- `org-confirm-babel-evaluate` is enabled, so source blocks in cloned or
  downloaded Org files prompt before running.
- The default-notes and diary files point into the cache directory rather
  than `org-directory`. Neither feature is used; give them real paths if that
  changes.
- Refile caching is disabled: it did not notice files appearing in a
  directory-based `org-agenda-files`, so targets went stale.

## Package reproducibility and startup

- A fresh clone has no installed ELPA packages and needs network access on its
  first startup. Consider a small bootstrap command that refreshes archives
  once and reports failed packages clearly.
- Packages are not pinned or locked. Consider recording package versions with
  a reproducible package manager if identical macOS and Linux installations
  become important.
- Heavy packages should remain command- or hook-driven. Magit is deferred,
  and the same rule should be applied to future additions.
- `all-the-icons` was unused and has been removed; `nerd-icons` is the active
  icon package.

## Editing and persistence choices

- `custom-file` is a fixed path in the cache directory that is never loaded,
  so Customize changes are written but have no effect on the next start. This
  is deliberate: the configuration is the Org file, not Customize. It replaced
  a `make-temp-file` call that left a stray file behind on every start.
- Lockfiles are disabled. Emacs does not write the visited file on its own;
  the earlier 30-second `auto-save-visited-mode` policy was removed because it
  pushed edits into Nextcloud before they were finished. Ordinary recovery
  auto-save still runs, into the cache directory rather than beside the file.
- The global before-save whitespace cleanup can create large unrelated diffs.
  Consider limiting it to selected programming modes or using a dedicated
  whitespace-cleanup mode.

## Interface and integrations

- Fonts are selected from platform-aware candidate lists for each graphical
  frame. Both lists now start with Aporetic: `Aporetic Sans Mono` for
  fixed-pitch and `Aporetic Serif` for variable-pitch, followed by
  FiraCode Nerd Font and Fira Code, then Linux Libertine O and Linux
  Libertine. macOS falls back through Menlo and Monaco, or Avenir Next,
  Helvetica Neue and Arial; Linux uses DejaVu Sans Mono and Liberation Mono,
  or Noto Serif, Liberation Serif and DejaVu Serif. Daemon-created frames are
  configured by `after-make-frame-functions`.
- `display-line-numbers-width-start` can add work when opening very large
  files; disable it or add a large-file guard if this becomes noticeable.
- Rainbow mode on every programming buffer can be expensive for large or
  generated files; selective hooks are an alternative.
- Eglot ignores document highlighting, color, and folding for every server.
  Formatting is ignored only in Python and Rust buffers, where Ruff and
  rustfmt own it; clangd, gopls, and texlab keep theirs, because nothing else
  formats C, C++, Go, or LaTeX here. Go buffers additionally organize imports
  and reformat through gopls on save.
