;;; init-lang.el -*- lexical-binding: t -*-

;; Highlight matching parens.
(use-package paren
  :ensure nil
  :custom
  (show-paren-delay 0)
  (blink-matching-paren 'jump)
  :config
  (show-paren-mode 1))

;; Enable automatic pair parens en quotes.
(use-package electric
  :ensure nil
  :config
  (electric-pair-mode 1))

;; Flyspell (spell checking)
(use-package flyspell
  :ensure nil
  :config
  (setq flyspell-issue-message-flag nil)
  (setq flyspell-issue-welcome-flag nil)
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "en_US,de_DE")
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "en_US,de_DE")
  :hook
  (text-mode . flyspell-mode)
  (prog-mode . flyspell-prog-mode))

(use-package emacs
  :bind
  (:map global-map
        ("\C-m" . newline-and-indent))
  :hook (before-save . (lambda()
                              (when (not (or (derived-mode-p 'markdown-mode)
                                             (derived-mode-p 'org-mode)))
                                (delete-trailing-whitespace))))
  :config
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2))

;;; Flymake (Linting)
(use-package flymake
  :ensure nil
  :bind
  ( :map ctl-x-x-map
    ("m" . flymake-mode)
    :map flymake-mode-map
    ("C-c ! s" . flymake-start)
    ("C-c ! d" . flymake-show-buffer-diagnostics)
    ("C-c ! D" . flymake-show-project-diagnostics)
    ("C-c ! n" . flymake-goto-next-error)
    ("C-c ! p" . flymake-goto-prev-error))
  :config
  (setq flymake-fringe-indicator-position 'left-fringe)
  (setq flymake-suppress-zero-counters t)
  (setq flymake-no-changes-timeout nil)
  (setq flymake-start-on-flymake-mode t)
  (setq flymake-start-on-save-buffer t)
  (setq flymake-proc-compilation-prevents-syntax-check t)
  (setq flymake-wrap-around nil)
  (setq flymake-mode-line-format
        '("" flymake-mode-line-exception flymake-mode-line-counters))
  (setq flymake-mode-line-counter-format
        '("" flymake-mode-line-error-counter
          flymake-mode-line-warning-counter
          flymake-mode-line-note-counter "")))

;;; Elisp packaging requirements
(use-package package-lint-flymake
  :ensure t
  :after flymake
  :config
  (add-hook 'flymake-diagnostic-functions #'package-lint-flymake))

;;; Clojure(Script)
(use-package paredit
  :ensure t
  :hook
  ((clojure-mode . paredit-mode)))

(use-package cider
  :ensure t)

;; This brings the hints from clj-kondo to the screen.
(use-package flycheck-clj-kondo
  :ensure t)

;; Provides all necessary refactoring tools.
(use-package clj-refactor
  :ensure t
  :after clojure-mode
  :config
  (defun my-clojure-mode-hook ()
    (clj-refactor-mode 1)
    (yas-minor-mode 1) ; for adding require/use/import statements
    ;; This choice of keybinding leaves cider-macroexpand-1 unbound
    (cljr-add-keybindings-with-prefix "C-c C-m"))
  (add-hook 'clojure-mode-hook #'my-clojure-mode-hook))

;; This provides the basic features like highlighting, indentation,
;; navigation and basic refactoring.
(use-package clojure-mode
  :ensure t
  :after flycheck-clj-kondo
  :config
  (require 'flycheck-clj-kondo)
  (flycheck-mode 1))

;;; C , C++, Java, ...
(use-package cc-mode
  :config
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (setq c-basic-offset 2)
  :bind
  (:map c-mode-base-map
        ("\C-m" . c-context-line-break))
  :hook
  (c-initialization-hook . my-make-CR-do-indent))

;;; Pyhon
;(use-package python-mode
;  :ensure nil
;  :mode (("\\.py\\'" . python-ts-mode))
;  :config
;  (setq indent-tabs-mode nil)
;  (setq tab-width 4)
;  (setq python-indent 4))

;;; Rust
(use-package rust-mode
  :ensure t
  :config
  (setq rust-format-on-save t)
  :init
  (setq rust-mode-treesitter-derive t)
  :hook
  (rust-mode-hook . (lambda () (prettify-symbols-mode)))
  (rust-mode-hook . (lambda () (setq indent-tabs-mode nil))))

(use-package rustic
  :ensure t
  :after (rust-mode)
  :config
  (setq rustic-lsp-client 'eglot))

;;; Shell mode
(use-package sh-script
  :config
  (setq indent-tabs-mode nil)
  (setq tab-width 2)
  (setq sh-basic-offset 2)
  (setq sh-indentation 2)
  :hook (sh-mode . flymake-mode))

;;; Swift development
;; Swift mode
(use-package swift-ts-mode
    :ensure t
    :mode "\\.swift\\'"
    :interpreter "swift")

;; .editorconfig file support
(use-package editorconfig
    :ensure t
    :config (editorconfig-mode +1))

;;; Plain text (text-mode)
(use-package text-mode
  :ensure nil
  :mode "\\`\\(README\\|CHANGELOG\\|COPYING\\|LICENSE\\)\\'"
  :hook
  ((text-mode . turn-on-auto-fill)
   (prog-mode . (lambda () (setq-local sentence-end-double-space t))))
  :config
  (setq sentence-end-double-space nil)
  (setq sentence-end-without-period nil)
  (setq colon-double-space nil)
  (setq use-hard-newlines nil)
  (setq adaptive-fill-mode t))

(provide 'init-lang)
