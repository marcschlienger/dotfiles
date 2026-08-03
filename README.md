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

## Platforms

### Linux

Linux is a primary environment for development, terminal work, and general day-to-day use.

### macOS

macOS is supported with the same overall workflow in mind, while keeping the necessary platform-specific differences explicit.

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
stow nvim emacs
```

## Notes

Use these files as a reference or starting point, not as a blind one-command install. Review everything before adopting it on your own machines.
