# Zathura configuration

The UI and optional document recoloring use the same four theme families as
Emacs, Kitty, and Neovim:

- Ef Maris Light / Dark
- Modus Operandi Tinted / Vivendi Tinted
- Catppuccin Latte / Macchiato
- Solarized Light / Dark

Zathura selects its theme independently. Edit
`.config/zathura/themes/current`, leave exactly one `include` active, and
restart Zathura. Ef Maris Dark is the default.

Document recoloring is disabled at startup so PDFs retain their intended
appearance. Press `Ctrl-r` in Zathura to toggle recoloring with the selected
theme. Original hues and image colors are preserved where Zathura supports
them.
