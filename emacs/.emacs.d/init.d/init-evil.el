;;; ms-emacs-evil.el -*- lexical-binding: t -*-

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
  (dolist (mode '(ag-mode
                  dired-mode
                  elfeed-show-mode
                  elfeed-search-mode
                  eshell-mode
                  git-rebase-mode
                  org-capture-mode
                  term-mode
                  Info-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

;;; Define leader key and bindings using genral.el
(use-package general
  :ensure t
  :config
  (general-evil-setup t)
  (general-create-definer ms-leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC"))

(ms-leader-keys
  "b" 'mode-line-other-buffer
  "n" 'ms-toggle-line-number-type
  "w" 'kill-buffer
  )

(defun ms-toggle-line-number-type ()
  "Toggle absolute and relative line numbering type."
  (interactive)
  (if (eq display-line-numbers 'relative)
      (setq display-line-numbers t)
    (setq display-line-numbers 'relative)))

;;; Exit insert mode quickly
(use-package evil-escape
  :ensure t
  :config
  (evil-escape-mode t)
  (setq-default evil-escape-delay 0.2)
  (setq-default evil-escape-key-sequence "jk"))

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
