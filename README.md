# dotfiles

My personal dotfiles for Linux and macOS.

Repository: `https://github.com/marcschlienger/dotfiles`

This repo contains the configuration I use for a Unix-like, keyboard-driven workflow across machines, with a focus on:

- Linux
- macOS
- Neovim
- Emacs

## Scope

The repository is intended to keep my everyday environment consistent while still allowing platform-specific differences where needed.

It includes configuration for:

- shell and terminal workflows
- editor setup
- operating-system-specific adjustments for Linux and macOS

## Editors

### Neovim

Neovim is part of the main editing setup and is configured for fast modal editing, programming, and text work.

### Emacs

Emacs is included as a complementary environment for writing, editing, and workflows that benefit from its extensibility.

## Fonts

Fonts are not tracked in this repository; they are installed by the
`debian-bootstrap` and `macos-bootstrap` repositories. The Emacs
configuration names families in order of preference and applies the first one
actually installed, so a machine without them still starts correctly and
simply looks different.

- **Aporetic Sans Mono** — the `default` and `fixed-pitch` faces in Emacs
- **Aporetic Serif** — the `variable-pitch` face, used in Org and Denote
  buffers
- **FiraCode Nerd Font Mono** — the terminal font in kitty
- **Symbols Nerd Font Mono** — the icon font, set explicitly as
  `nerd-icons-font-family`

Emacs and the terminal use different fonts on purpose. Measuring the advance
width per em: Fira Code 0.615, IBM Plex Mono 0.600, Aporetic 0.525, stock
Iosevka 0.500. Iosevka proved too crowded to read comfortably in a terminal,
and IBM Plex, though wide enough, has the smallest x-height of the wide fonts
— 0.516 against Fira Code's 0.540 — which reads as faint.

Fira Code is the widest measured and the easiest to scan, so it takes the
terminal. Aporetic keeps Emacs, where its matched sans, serif, and mono
faces make `variable-pitch-mode` in Org and Denote buffers read as one
typeface, and where prose at a comfortable size is far more forgiving of
narrow letterforms than dense code is.

Aporetic carries no Nerd Font glyphs, so Emacs draws its icons from Symbols
Nerd Font Mono instead. Fira Code is Nerd-patched and needs no such
fallback.

Install them with `./install-fonts aporetic` on Debian, or
`./bootstrap install-fonts` on macOS.

## Platforms

### Linux

Linux is a primary environment for development, terminal work, and general day-to-day use.

### macOS

macOS is supported with the same overall workflow in mind, while keeping the necessary platform-specific differences explicit.

#### tmux prefix

The tmux prefix is `Control-Space`. On macOS 27, both system shortcuts in
**System Settings → Keyboard → Keyboard Shortcuts → Input Sources** must be
disabled so the key reaches the terminal:

- **Select the previous input source**
- **Select next source in Input menu**

Leaving either shortcut enabled can prevent tmux from receiving
`Control-Space`. No terminal-specific key mapping is required.

## Philosophy

These dotfiles are meant to be:

- practical
- readable
- versioned
- cross-platform where useful
- personal rather than universal

This is not a generic framework for everyone. It is my own setup, tracked in a form that is easy to maintain and adapt.

## Installation

Clone the repository and use GNU Stow to symlink the parts you want to enable:

```bash
git clone https://github.com/marcschlienger/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow neovim emacs
```

The `teaching-agent` package installs the shared teaching skills under
`~/.agents/skills`:

```bash
stow teaching-agent
```

## Notes

Use these files as a reference or starting point, not as a blind one-command install. Review everything before adopting it on your own machines.
