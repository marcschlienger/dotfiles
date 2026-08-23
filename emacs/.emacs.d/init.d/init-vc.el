;;-*- lexical-binding: t; -*-

;;; init-vc.el -*- lexical-binding: t -*-

;; Version control framework
(use-package vc
  :ensure nil
  :init
  (setq vc-follow-symlinks t)
  :config
  (setq vc-handled-backends '(Git))
  (require 'vc-annotate)
  (require 'vc-dir)
  (require 'vc-git)
  (require 'add-log)
  (require 'log-view)
  (require 'log-edit))

;; Magit
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch))
  :commands (magit-status magit-dispatch magit-file-dispatch)
  :init
  (setq magit-define-global-key-bindings nil)
  (setq git-commit-summary-max-length 50)
  (setq git-commit-style-convention-checks '(non-empty-second-line)))

;; diff-hl-mode (https://github.com/dgutov/diff-hl) to highlight lines with uncommitted changes
(use-package diff-hl
  :ensure t
  :custom
  ; TODO Determine whether Tramp mode is slow without the following setting.
  (diff-hl-disable-on-remote t)
  :hook
  (after-init . global-diff-hl-mode)
  (dired-mode . diff-hl-dired-mode)
  (magit-pre-refresh . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh)
  (vc-checkin . diff-hl-update))

(provide 'init-vc)
