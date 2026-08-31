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
  (require-final-newline t))

;; Revert buffers when the underlying file has changed
(use-package emacs
  :config
  (global-auto-revert-mode 1)
  (setq auto-revert-verbose t))

;; Restore point when reopening files.
(use-package saveplace
  :ensure nil
  :config
  (save-place-mode 1))

;; Include recently visited files in commands such as `consult-buffer'.
(use-package recentf
  :ensure nil
  :custom
  (recentf-max-saved-items 200)
  (remote-file-name-access-timeout 5)
  :config
  (recentf-mode 1))

;; Undo and redo changes to window layouts.
(use-package winner
  :ensure nil
  :bind (("C-c w u" . winner-undo)
         ("C-c w r" . winner-redo))
  :init
  (winner-mode 1))

;; Continue supported command families with short repeat keys.
(use-package repeat
  :ensure nil
  :config
  (repeat-mode 1))

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
  (setq ns-command-modifier 'super
        ns-alternate-modifier 'meta
        ns-right-alternate-modifier 'none
        ns-pop-up-frames nil) ; reuse existing frames whenever possible
)

(provide 'init-basic)
