;;-*- lexical-binding: t; -*-

(dolist (var '(default-frame-alist initial-frame-alist))
  (add-to-list var '(width . (text-pixels . 800)))
  (add-to-list var '(height . (text-pixels . 900))))

(when (eq system-type 'darwin)
  (setq ns-use-proxy-icon nil)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

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

;; Byte-compiled packages are version-specific. Rebuild them once after an
;; Emacs upgrade, forcing stale .elc files even when they are newer than source.
;; Write the stamp only after the pass finishes so a hard failure is retried.
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
