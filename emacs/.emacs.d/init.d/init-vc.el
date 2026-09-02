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
  :config
  ;; Fringes do not exist in a terminal frame, so the change indicators are
  ;; simply invisible there.  `diff-hl-margin-mode' is global rather than
  ;; per-frame, so this only switches automatically for an Emacs that is
  ;; itself a terminal -- under a daemon serving both kinds of frame the
  ;; choice cannot be made for you, and `M-x diff-hl-margin-mode' is the
  ;; manual switch.
  (unless (or (daemonp) (display-graphic-p))
    (diff-hl-margin-mode 1))
  :hook
  (after-init . global-diff-hl-mode)
  ;; Without this the fringe only catches up when the buffer is saved.
  (after-init . diff-hl-flydiff-mode)
  (dired-mode . diff-hl-dired-mode)
  (magit-pre-refresh . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh)
  (vc-checkin . diff-hl-update))

(provide 'init-vc)
