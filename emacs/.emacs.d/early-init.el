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

;; Warn when the Emacs version has changed since packages were compiled.
;;
;; Byte-compiled files are tied to the Emacs that produced them.  After an
;; upgrade, a package compiled by the previous binary fails at load with
;; "Symbol's value as variable is void" naming a symbol that
;; `define-minor-mode' generates — which points at the package rather than
;; at the upgrade that actually caused it.
;;
;; `straight.el' handles this by recording `emacs-version' at compile time
;; and signalling `emacs-version-changed' on mismatch; `package.el' does
;; nothing of the kind.  This is the same check, done by hand, and it runs
;; here in early-init so the message arrives before the failure does.
;;
;; It reports rather than repairs: recompiling takes minutes and would fire
;; exactly when a file is being opened.
(let* ((stamp (expand-file-name "emacs-version-stamp" user-emacs-directory))
       (previous (and (file-exists-p stamp)
                      (with-temp-buffer
                        (insert-file-contents stamp)
                        (string-trim (buffer-string))))))
  (unless (equal previous emacs-version)
    (when previous
      ;; `straight' quoting, or Emacs renders the apostrophes as curly
      ;; quotes and the command below cannot be pasted into a shell.
      (let ((text-quoting-style 'straight))
        (warn (concat "Emacs %s -> %s. Byte-compiled packages are stale.\n"
                      "Recompile them, then restart:\n"
                      "  emacs --batch --eval '(byte-recompile-directory package-user-dir 0 t)'\n"
                      "The trailing t forces it; stale .elc files look newer than their .el.")
              previous emacs-version)))
    (with-temp-file stamp (insert emacs-version))))

;; Initialise installed packages.
(setq package-enable-at-startup t)
