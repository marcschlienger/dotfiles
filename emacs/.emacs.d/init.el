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

;; Byte-compiled files are tied to the Emacs version that produced them, so an
;; upgrade leaves stale .elc files that fail in confusing ways -- typically a
;; void variable from a macro that changed shape between versions.
;;
;; This lives here rather than in early-init.el because package activation
;; happens between the two: until it has run, no package directory is on
;; `load-path', so compiling a package cannot resolve its dependencies.  A
;; missing macro is the dangerous case -- the compiler emits an ordinary
;; function call instead of expanding it, and writes a silently wrong .elc.
(defun ms-recompile-packages ()
  "Byte-recompile every installed package, forcing stale .elc files.
Return the number of files that failed to compile."
  (interactive)
  (require 'bytecomp)
  (let ((failed 0) (total 0))
    (dolist (file (directory-files-recursively package-user-dir "\\.el\\'"))
      ;; package.el regenerates these two itself; compiling them proves nothing.
      (unless (string-match-p "\\(?:-autoloads\\|-pkg\\)\\.el\\'" file)
        (setq total (1+ total))
        ;; `byte-recompile-file' returns nil for a file that will not
        ;; compile, but it *signals* for a filesystem problem -- an
        ;; unwritable .elc, say.  Uncaught, that would abort init.el and
        ;; leave the rest of the configuration unloaded, which is a far
        ;; worse outcome than a stale .elc.
        (unless (condition-case err
                    (byte-recompile-file file t 0)
                  (error
                   (message "Recompiling %s failed: %s"
                            (file-name-nondirectory file)
                            (error-message-string err))
                   nil))
          (setq failed (1+ failed)))))
    (message "Recompiled %d package files, %d failed" total failed)
    failed))

(let* ((stamp (expand-file-name "emacs-version-stamp" user-emacs-directory))
       (previous (and (file-exists-p stamp)
                      (with-temp-buffer
                        (insert-file-contents stamp)
                        (string-trim (buffer-string))))))
  (unless (equal previous emacs-version)
    (if (not (and previous (file-directory-p package-user-dir)))
        ;; First run here, or nothing installed yet: just record the version.
        (with-temp-file stamp (insert emacs-version))
      (message "Emacs %s -> %s: recompiling packages, this takes a minute..."
               previous emacs-version)
      ;; `byte-recompile-directory' reports failures in its return *string*
      ;; and never signals, so the previous version wrote the stamp after a
      ;; failed pass and never retried.  Count per file instead.
      (if (zerop (ms-recompile-packages))
          (with-temp-file stamp (insert emacs-version))
        (display-warning
         'init
         (format "Packages failed to byte-compile after the upgrade to Emacs %s.
The version stamp was not written, so this is retried at the next start.
Run M-x ms-recompile-packages to see which files fail."
                 emacs-version)
         :warning)))))

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
(require 'init-evil)
(require 'init-lang)
(require 'init-completion)
(require 'init-org)
(require 'init-latex)
(require 'init-vc)
(require 'init-denote)
