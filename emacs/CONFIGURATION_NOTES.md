# Emacs configuration notes

This file records machine dependencies and optional improvements that are not
enforced by the configuration itself. The canonical configuration remains
`emacs/.emacs.d/emacs-init.org`.

## External dependencies

The configuration starts Eglot or formatting/export tools automatically for
the relevant major modes. Install the corresponding executable on every
machine where that language integration is wanted:

| Feature | Executable | Current macOS status |
| --- | --- | --- |
| C and C++ Eglot | `clangd` | Installed |
| Python Eglot | `ty` (`ty server`) | Missing |
| Rust Eglot | `rust-analyzer` | Missing |
| Rust build, Clippy, and format on save | `cargo`, Clippy, and `rustfmt` | Missing |
| Clojure development | `clojure` | Missing |
| Clojure diagnostics | `clj-kondo` | Missing |
| LaTeX Eglot | `texlab` | Installed |
| LaTeX compilation | A TeX distribution providing `latexmk` or `pdflatex` | Missing |
| Swift Eglot | `sourcekit-lsp` | Installed |
| Markdown export | `multimarkdown` | Missing |
| Org Babel Python | `python3` | Installed |
| Org Babel R | `R` | Missing |
| Spell checking | `hunspell` plus `en_US` and `de_DE` dictionaries | Installed executable; verify dictionaries |

The Eglot hooks are intentionally unconditional. A missing language server
therefore produces an error when a matching buffer opens. A future refinement
could guard each hook with `executable-find`, or provide a command that reports
all missing development dependencies at once.

## Tree-sitter

Emacs provides the Tree-sitter integration, but each language still needs a
native grammar library. Those libraries are deliberately not stored in the
repository because they depend on the operating system and CPU architecture.
The generated `emacs/.emacs.d/tree-sitter/` directory is ignored by Git.

On a fresh clone, the configuration first checks `treesit-available-p` to make
sure Emacs itself has Tree-sitter support. It then checks every language with
`treesit-language-available-p`. Only grammars that can be loaded are remapped
to their Tree-sitter major modes; otherwise C, C++, Go, Python, and Swift keep
using their traditional major modes. A missing grammar therefore degrades
cleanly instead of breaking file opening. Rust uses `rust-mode`'s separate
Tree-sitter integration, while the Emacs Lisp grammar is not automatically
remapped.

Install these prerequisites before building grammars:

| Requirement | macOS | Debian/Ubuntu | Fedora | Arch Linux |
| --- | --- | --- | --- | --- |
| Emacs | Emacs 29 or newer, built with Tree-sitter support | Emacs 29 or newer, built with Tree-sitter support | Emacs 29 or newer, built with Tree-sitter support | Emacs 29 or newer, built with Tree-sitter support |
| Git, C/C++ compiler, and linker | Run `xcode-select --install` | `sudo apt install git build-essential` | `sudo dnf install git gcc gcc-c++` | `sudo pacman -S git base-devel` |
| Grammar sources | Internet access during the first build | Internet access during the first build | Internet access during the first build | Internet access during the first build |

Evaluate `M-: (treesit-available-p) RET` first; it must return non-nil. The
standalone `tree-sitter` command-line program is not required for the C, C++,
Emacs Lisp, Go, Python, or Rust recipes. Swift is an exception described
below. Emacs must be able to find Git and the compilers through `exec-path`.

On each macOS or Linux machine, run once after cloning:

```text
M-x ms/treesit-install-missing-grammars
```

This attempts to download and build the configured C, C++, Emacs Lisp, Go,
Python, Rust, and Swift grammars under the local Emacs directory. The command
reports an individual warning for a grammar that fails and continues with the
others. It then enables remapping only for the grammars that loaded
successfully. The locally generated binaries will be `.dylib`-compatible on
macOS and `.so` libraries on Linux, so every machine must build its own copies.

After installation, restart Emacs or run
`M-x ms/treesit-activate-remappings`. Confirm a buffer is using Tree-sitter by
checking `M-x describe-mode`: its major mode should have a `-ts-mode` name.

### Known Swift installation issue

The current upstream
[Swift grammar](https://github.com/alex-pinkus/tree-sitter-swift#where-is-your-parserc)
does not store its generated `src/parser.c` in the Git repository. Emacs's
`treesit-install-language-grammar` expects that file to exist and only compiles
it; it does not run the Tree-sitter parser generator. Consequently,
`ms/treesit-install-missing-grammars` currently ends with a Swift warning like:

```text
clang: error: no such file or directory: 'parser.c'
```

This warning does not invalidate the other installations. C, C++, Emacs Lisp,
Go, Python, and Rust can still build and load successfully. Because remapping
is conditional, Swift continues to open safely in ordinary `swift-mode`, with
Eglot and `sourcekit-lsp` still available, instead of entering a broken
`swift-ts-mode`.

There are two reasonable future choices:

1. Remove Swift from `treesit-language-source-alist` and the remapping list,
   making `swift-mode` the intentional permanent fallback.
2. Add a separate Swift installer that obtains a generated `parser.c` from an
   upstream release artifact or generates it with a compatible standalone
   Tree-sitter CLI before asking Emacs to compile the grammar.

The first option is simpler and avoids an additional toolchain. Installing the
standalone CLI alone does not fix the current command because the Emacs
installer never invokes it.

The grammar recipes currently follow each repository's default branch. Pin
revisions in `treesit-language-source-alist` if reproducible grammar builds
become more important than automatically picking up parser updates.

## Org

- `org-directory` is `~/org`; create or restore that directory before using
  capture, agenda, or refile commands.
- The agenda contains the directory itself rather than a one-time wildcard
  expansion, so new `.org` files are discovered without restarting Emacs.
- `org-confirm-babel-evaluate` is still disabled. This is convenient, but it
  lets source blocks in cloned or downloaded Org files execute without a
  confirmation prompt. Consider enabling confirmation globally and exempting
  only explicitly trusted languages or files.
- The temporary default-notes and diary files are intentionally ephemeral.
  Replace them with persistent files if those features should retain data.
- Refile caching improves completion speed but may need
  `org-refile-cache-clear` after large outline changes.

## Package reproducibility and startup

- A fresh clone has no installed ELPA packages and needs network access on its
  first startup. Consider a small bootstrap command that refreshes archives
  once and reports failed packages clearly.
- Packages are not pinned or locked. Consider recording package versions with
  a reproducible package manager if identical macOS and Linux installations
  become important.
- Heavy packages should remain command- or hook-driven. Magit and the Clojure
  stack are now deferred, but the same rule should be applied to future
  additions.
- `all-the-icons` was unused and has been removed; `nerd-icons` is the active
  icon package.

## Editing and persistence choices

- `custom-file` points to a new temporary file on every startup, so Customize
  changes do not persist. Use a stable ignored file if persistence is wanted.
- Lockfiles are disabled while visited files are automatically written every
  30 seconds. This is convenient but reduces protection from concurrent Emacs
  sessions and makes accidental edits reach disk quickly.
- The global before-save whitespace cleanup can create large unrelated diffs.
  Consider limiting it to selected programming modes or using a dedicated
  whitespace-cleanup mode.

## Interface and integrations

- `Linux Libertine O` is not installed on the current Mac, so variable-pitch
  text falls back to Verdana. Install it or define an explicit platform-aware
  fallback family.
- `display-line-numbers-width-start` can add work when opening very large
  files; disable it or add a large-file guard if this becomes noticeable.
- Rainbow mode on every programming buffer can be expensive for large or
  generated files; selective hooks are an alternative.
- Eglot currently ignores several server capabilities, including hover and
  formatting. Revisit `eglot-ignored-server-capabilities` if those features
  are wanted later.
- Elfeed has no local subscription list. If it is enabled, configure Feedbin
  through a compatible synchronization package and keep credentials in
  `auth-source`, never in the dotfiles repository.
