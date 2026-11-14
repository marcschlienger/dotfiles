;;; init-vc.el -*- lexical-binding: t -*-

;; Version control framework.  Nothing is required by hand: `vc-annotate',
;; `vc-dir', the log modes and the Git backend are all autoloaded by the
;; commands that need them.
(use-package vc
  :ensure nil
  :init
  (setq vc-follow-symlinks t)
  :config
  (setq vc-handled-backends '(Git)))

;; Magit
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch))
  :commands (magit-status magit-dispatch magit-file-dispatch)
  :init
  (setq magit-define-global-key-bindings nil)
  (setq git-commit-summary-max-length 50)
  (setq git-commit-style-convention-checks '(non-empty-second-line))
  :config
  ;; C-<up> and C-<down> are how I move through a diff, but a hunk's lines
  ;; carry a leading + or -, so a blank line reads as " " and paragraph
  ;; motion runs to the end of the hunk.  Allowing the marker in both
  ;; patterns makes a blank context line a paragraph break again.
  (add-hook 'magit-diff-mode-hook
            (lambda ()
              (setq-local paragraph-separate
                          (format "[+-]?\\(?:%s\\)" paragraph-separate))
              (setq-local paragraph-start
                          (format "[+-]?\\(?:%s\\)" paragraph-start)))))

;; diff-hl-mode (https://github.com/dgutov/diff-hl) to highlight lines with uncommitted changes
(use-package diff-hl
  :ensure t
  :custom
  ;; diff-hl asks version control for a diff every time the buffer changes.
  ;; Over Tramp each of those is a remote process, paying the connection
  ;; latency, so the indicators stay off for remote files.
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
