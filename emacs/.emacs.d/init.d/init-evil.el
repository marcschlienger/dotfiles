;;; init-evil.el -*- lexical-binding: t -*-

;;; Evil mode
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-mode-line-format nil)
  (setq evil-undo-system 'undo-redo) ;; Make C-r work again
  :bind ( :map evil-insert-state-map
               ("C-g" . 'evil-normal-state)
          :map evil-normal-state-map
               ("j" . 'evil-next-visual-line)
               ("k" . 'evil-previous-visual-line))
  :config
  (evil-mode 1)
  (dolist (mode '(dired-mode
                  eshell-mode
                  git-rebase-mode
                  org-capture-mode
                  term-mode
                  Info-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(defun ms-toggle-line-number-type ()
  "Toggle absolute and relative line numbering type."
  (interactive)
  (if (eq display-line-numbers 'relative)
      (setq display-line-numbers t)
    (setq display-line-numbers 'relative)))

;;; Define leader key and bindings using general.el
;; `ms-leader-keys' is a macro that `general-create-definer' defines at load
;; time, so the bindings have to follow it.  Called at top level instead, a
;; failure to load general aborted the rest of init.el -- every module after
;; this one.
(use-package general
  :ensure t
  :config
  (general-evil-setup t)
  (general-create-definer ms-leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")
  (ms-leader-keys
    "b" 'mode-line-other-buffer
    "n" 'ms-toggle-line-number-type
    "w" 'kill-buffer))

;;; Exit insert mode quickly
(use-package evil-escape
  :ensure t
  :after evil
  :config
  (setq-default evil-escape-delay 0.2)
  (setq-default evil-escape-key-sequence "jk")
  (evil-escape-mode 1))

;;; Additional key bindings for evil mode
(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;;; Highlighting
(use-package evil-goggles
  :after evil
  :ensure t
  :config
  (evil-goggles-mode)
  (setq evil-goggles-duration 0.500)
  (evil-goggles-use-diff-faces))

;;; Evil surround
(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

;;; Evil Commentary
(use-package evil-commentary
  :ensure t
  :config
  (evil-commentary-mode))

;;; Evil tex
(use-package evil-tex
  :ensure t
  :config
  (add-hook 'LaTeX-mode-hook #'evil-tex-mode))

(provide 'init-evil)
