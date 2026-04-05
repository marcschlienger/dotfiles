;;-*- lexical-binding: t; -*-

(dolist (var '(default-frame-alist initial-frame-alist))
  (add-to-list var '(width . (text-pixels . 800)))
  (add-to-list var '(height . (text-pixels . 900))))

(when (eq system-type 'darwin)
  (progn
    (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
    (add-to-list 'default-frame-alist '(ns-appearance . dark))))

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

;; Initialise installed packages.
(setq package-enable-at-startup t)
