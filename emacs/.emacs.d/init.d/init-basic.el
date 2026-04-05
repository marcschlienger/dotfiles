;;-*- lexical-binding: t; -*-

;; Ensure environment variables inside Emacs look the same as in the shell.
(use-package exec-path-from-shell
  :ensure t
  :if (memq system-type '(darwin gnu/linux))
  :config
  (exec-path-from-shell-initialize))

;; Delete the selected/highlighted text as soon as the user types something.
(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

;; Always make sure that there is a final newline character when saving a file.
(use-package emacs
  :custom
  (require-final-newline t)
)

;; Easily move the current line up or down.
(defun move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "M-<down>") 'move-line-down)
(global-set-key (kbd "M-<up>") 'move-line-up)

;; MacOS specific settings
(use-package emacs
  :if (eq system-type 'darwin)
  :config
  (setq mac-command-modifier 'super) ; use the cmd key as modifier
  ;(setq mac-option-modifier 'nil) ; diable the option key as modifier
  (setq ns-alternate-modifier 'meta) ; diable the option key as modifier
  (setq ns-right-alternate-modifier 'none) ; diable the option key as modifier
  (setq ns-pop-up-frames 'nil) ; reuse existing frames whenever possible
)

(provide 'init-basic)
