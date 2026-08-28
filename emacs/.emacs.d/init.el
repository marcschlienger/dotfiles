;;-*- lexical-binding: t; -*-

;; Save backup files in a dedicated backup directory.
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

;; Do not create lock files.
(setq create-lockfiles nil)

;; Write persistant cutomisations to a temporary file.
(setq custom-file (make-temp-file "custom.el"))

;; Package settings.
(require 'package)
(setq package-name-column-width 40)
(setq package-version-column-width 14)
(setq package-status-column-width 12)
(setq package-archive-column-width 8)
(add-hook 'package-menu-mode-hook #'hl-line-mode)

(setq package-archives
      '(("elpa" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))

;;; The higher the number assigned to a archive the higher its priority.
(setq package-archive-priorities
      '(("elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

;;; Upgrade built-in packages.
(setq package-install-upgrade-built-in t)

;; Real auto save mode.
(auto-save-visited-mode 1)
(setq auto-save-visited-interval 30)

;; Load config modules.
(mapc
 (lambda (string)
   (add-to-list 'load-path (locate-user-emacs-file string)))
 '("lib.d" "init.d"))

(require 'init-basic)
(require 'init-dired)
(require 'init-theme)
(require 'init-evil)
(require 'init-lang)
(require 'init-completion)
(require 'init-org)
(require 'init-latex)
(require 'init-vc)
(require 'init-elfeed)
(require 'init-denote)
