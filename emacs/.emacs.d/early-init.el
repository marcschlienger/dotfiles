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
      inhibit-startup-screen t
      inhibit-x-resources t
      ring-bell-function 'ignore
      use-dialog-box t
      use-file-dialog nil
      use-short-answers t)

;; `inhibit-startup-echo-area-message' cannot do this job.  Emacs only
;; honours it when init.el contains a setq of that one variable followed by
;; the login name as a literal string and an immediate close paren -- it
;; greps the file for exactly that.  A variable reference, a multi-variable
;; setq, or living in early-init.el all defeat it, and hardcoding the account
;; name would break on the other machine anyway.
(advice-add 'display-startup-echo-area-message :override #'ignore)

;; Disable GUI elements.
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Initialise installed packages.
(setq package-enable-at-startup t)
