;;-*- lexical-binding: t; -*-

(dolist (var '(default-frame-alist initial-frame-alist))
  (add-to-list var '(width . (text-pixels . 800)))
  (add-to-list var '(height . (text-pixels . 900))))

(when (eq system-type 'darwin)
  (progn
    ;;(add-to-list 'default-frame-alist '(undecorated-round . t))
    (setq ns-use-proxy-icon nil)
    (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))))

(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t
      frame-title-format '("%b")
      inhibit-startup-buffer-menu t
      inhibit-startup-echo-area-message user-login-name
      inhibit-startup-screen t
      inhibit-x-resources t
      ring-bell-function 'ignore
      use-dialog-box t
      use-file-dialog nil
      use-short-answers t)

;; Disable GUI elements.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Recompile packages when the Emacs version has changed.
;;
;; Byte-compiled files are tied to the Emacs that produced them.  After an
;; upgrade a package compiled by the previous binary fails at load with
;; "Symbol's value as variable is void", naming a symbol that
;; `define-minor-mode' generates — which points at the package rather than at
;; the upgrade that caused it.  Going 30.2 -> 31.1 broke `diff-hl' that way.
;;
;; `straight.el' records `emacs-version' at compile time and signals
;; `emacs-version-changed'; `package.el' does nothing of the kind.  This does
;; the check by hand and then repairs it, here in early-init so the packages
;; are rebuilt before anything tries to load them.
;;
;; It costs one slow start after an upgrade, which is the same work as doing
;; it by hand afterwards, minus the cryptic error and the diagnosis.
;;
;; FORCE is t deliberately: the stale .elc files are newer than their .el, so
;; a non-forced pass skips exactly the files that need redoing.
;;
;; The stamp is written after the rebuild, not before, so a run that is
;; interrupted or dies outright is retried at the next start.
;;
;; It does NOT retry on a package that merely fails to compile: those are
;; reported by `byte-recompile-directory' without signalling, and a package
;; that cannot compile will not compile next time either — retrying forever
;; would turn one broken package into a permanently slow startup.  Only a
;; hard error, such as the tree being unreadable, is caught below.
(let* ((stamp (expand-file-name "emacs-version-stamp" user-emacs-directory))
       (previous (and (file-exists-p stamp)
                      (with-temp-buffer
                        (insert-file-contents stamp)
                        (string-trim (buffer-string)))))
       ;; Not `package-user-dir': package.el is not loaded this early.
       (elpa (expand-file-name "elpa" user-emacs-directory))
       (done t))
  (unless (equal previous emacs-version)
    (when (and previous (file-directory-p elpa))
      (message "Emacs %s -> %s: recompiling %s, this takes a minute..."
               previous emacs-version elpa)
      (condition-case err
          (byte-recompile-directory elpa 0 t)
        (error
         (setq done nil)
         (message "Recompiling failed: %s\nRun it by hand: emacs --batch --eval %s"
                  (error-message-string err)
                  "\"(byte-recompile-directory package-user-dir 0 t)\""))))
    (when done
      (with-temp-file stamp (insert emacs-version)))))

;; Initialise installed packages.
(setq package-enable-at-startup t)
