# Yazi

Small overrides on top of Yazi's built-in configuration. The defaults already
provide Vim navigation, tabs, archive extraction, previews, `fzf` search (`z`),
`zoxide` directory jumping (`Z`), and `fd`/`ripgrep` search (`s`/`S`).

Install the package from the dotfiles root:

```sh
stow yazi
```

Local additions:

- `Enter`/`o` opens text, code, or a directory in a new Emacs client frame
  (directories open in Dired); `l` still enters a directory inside Yazi.
- `O` offers other applicable openers, including blocking Neovim for text files.
- `!` opens an interactive shell in the current directory.
- `Ctrl-n` creates a directory.
- `g .` jumps to `~/.dotfiles`.
- `g n` jumps to `~/Nextcloud`.
- `Esc` cancels an input prompt in one keypress.

The shell wrapper in `zsh/.zsh/yazi.zsh` exposes `y`; quitting with `q` changes
the parent shell to Yazi's last directory, while `Q` leaves it unchanged.

## Editors

The `ec` command is a Zsh alias, which is not available to the non-interactive
shell Yazi uses for openers. `yazi.toml` therefore calls its underlying command,
`emacsclient -c -n -a ""`, directly. The `-a ""` option starts an Emacs daemon
if no server is running, `-c` creates a graphical frame, and `-n` returns without
making Yazi wait for that frame to close.

To make Neovim the default instead, put its entry first in `[opener].edit` (and
optionally remove the Emacs entry):

```toml
[opener]
edit = [
	{ run = "nvim %s", desc = "Neovim", for = "unix", block = true },
]
```

## macOS and Linux

Yazi supports an OS selector on opener rules and keybindings:

- `for = "unix"` applies to both macOS and Linux (and Android).
- `for = "macos"` applies only on macOS.
- `for = "linux"` applies only on Linux.

Use separate entries only where commands differ. For example:

```toml
[opener]
reveal = [
	{ run = "open -R %s1",  desc = "Reveal in Finder", for = "macos" },
	{ run = "xdg-open %d1", desc = "Reveal in folder", for = "linux" },
]
```

Yazi's built-in `open` and `reveal` rules already make this macOS/Linux
distinction, so there is no need to copy those rules into this configuration
unless they need customization. The Emacs and Neovim commands are shared and
therefore use `for = "unix"`.
