;;-*- lexical-binding: t; -*-

;; Load config modules.  This has to come first: the settings below are
;; written in terms of `ms-cache-file' from lib.d.
(mapc
 (lambda (string)
   (add-to-list 'load-path (locate-user-emacs-file string)))
 '("lib.d" "init.d"))

(require 'lib-paths)

;; Save backup files in a dedicated backup directory.
(setq backup-directory-alist `(("" . ,(ms-cache-file "backup/"))))

;; Do not create lock files.
(setq create-lockfiles nil)

;; Discard persistent customisations.  Custom insists on a file to write to,
;; so give it a fixed one and never load it.  `make-temp-file' also works but
;; leaves a fresh file behind on every single start.
(setq custom-file (ms-cache-file "custom.el"))

;; Package settings.
(require 'package)
(setq package-name-column-width 40)

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

;; Keep ordinary recovery auto-saves outside the repository and synced files.
(let ((auto-save-directory (ms-cache-file "auto-save/")))
  (make-directory auto-save-directory t)
  (setq auto-save-file-name-transforms
        `((".*" ,auto-save-directory t)))
  (setq auto-save-list-file-prefix
        (expand-file-name ".saves-" auto-save-directory)))

(require 'init-basic)
(require 'init-dired)
(require 'init-theme)
(require 'init-lang)
(require 'init-completion)
(require 'init-org)
(require 'init-latex)
(require 'init-vc)
(require 'init-denote)
