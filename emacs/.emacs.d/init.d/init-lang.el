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
(defun ms/flyspell-disable ()
  "Turn flyspell off in the current buffer."
  (flyspell-mode -1))

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
  (prog-mode . flyspell-prog-mode)
  ;; Off again for shell scripts.  `flyspell-prog-mode' checks comments AND
  ;; strings, and a shell buffer is mostly those two things — comments up
  ;; top, then strings full of paths, flags and command names.  The result
  ;; is underlining everywhere and no signal.
  ;;
  ;; This runs after the prog-mode hook that switched it on: a derived mode
  ;; runs its parent's hooks first, then its own.
  (sh-mode . ms/flyspell-disable))

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
  :hook (emacs-lisp-mode . package-lint-flymake-setup))

;;; Tree-sitter
(defvar rust-mode-treesitter-derive)

(use-package treesit
  :ensure nil
  :if (treesit-available-p)
  :init
  (setq treesit-language-source-alist
        '((c "https://github.com/tree-sitter/tree-sitter-c")
          (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
          (elisp "https://github.com/Wilfred/tree-sitter-elisp")
          (go "https://github.com/tree-sitter/tree-sitter-go")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (rust "https://github.com/tree-sitter/tree-sitter-rust")))
  (defconst ms/treesit-major-mode-remappings
    '((c c-mode c-ts-mode)
      (cpp c++-mode c++-ts-mode)
      (go go-mode go-ts-mode)
      (python python-mode python-ts-mode))
    "Tree-sitter remappings enabled when their grammar is available.")
  :config
  (defun ms/treesit-activate-remappings ()
    "Use tree-sitter modes whose grammar is available locally."
    (dolist (entry ms/treesit-major-mode-remappings)
      (pcase-let ((`(,language ,source-mode ,target-mode) entry))
        (when (treesit-language-available-p language)
          (setf (alist-get source-mode major-mode-remap-alist) target-mode))))
    ;; `rust-mode' chooses its parent mode when its package is loaded.
    (setq rust-mode-treesitter-derive
          (treesit-language-available-p 'rust)))

  (defun ms/treesit-install-missing-grammars ()
    "Build missing configured grammars for the current platform."
    (interactive)
    (dolist (entry treesit-language-source-alist)
      (let ((language (car entry)))
        (unless (treesit-language-available-p language)
          (condition-case error-data
              (treesit-install-language-grammar language)
            (error
             (display-warning
              'treesit
              (format "Could not install %s grammar: %s"
                      language (error-message-string error-data))
              :warning))))))
    (ms/treesit-activate-remappings))

  (ms/treesit-activate-remappings))

;;; Clojure(Script)
(use-package paredit
  :ensure t
  :hook (clojure-mode . paredit-mode))

(use-package clojure-mode
  :ensure t
  :mode (("\\.clj[csx]?\\'" . clojure-mode)
         ("\\.edn\\'" . clojure-mode)))

(use-package cider
  :ensure t
  :commands (cider-jack-in cider-jack-in-cljs
             cider-connect-clj cider-connect-cljs))

(use-package flycheck
  :ensure t
  :hook (clojure-mode . flycheck-mode))

;; This brings the hints from clj-kondo to the screen.
(use-package flycheck-clj-kondo
  :ensure t
  :after (flycheck clojure-mode))

;; Provides all necessary refactoring tools.
(use-package clj-refactor
  :ensure t
  :after clojure-mode
  :hook (clojure-mode . clj-refactor-mode)
  :config
  ;; This choice of keybinding leaves cider-macroexpand-1 unbound.
  (cljr-add-keybindings-with-prefix "C-c C-m"))

;;; C, C++, Java, ...
(defun ms/c-mode-setup ()
  "Apply personal indentation settings to C-family buffers."
  (setq-local indent-tabs-mode nil
              tab-width 4
              c-basic-offset 2
              c-ts-mode-indent-offset 2))

(use-package cc-mode
  :ensure nil
  :bind
  (:map c-mode-base-map
        ("\C-m" . c-context-line-break))
  :hook
  ((c-mode-common . ms/c-mode-setup)
   (c-ts-mode . ms/c-mode-setup)
   (c++-ts-mode . ms/c-mode-setup)))

(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
         ("C-c C-e" . markdown-do)))

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
  (setq rust-mode-treesitter-derive
        (and (fboundp 'treesit-available-p)
             (treesit-available-p)
             (treesit-language-available-p 'rust)))
  :hook
  (rust-mode . (lambda () (prettify-symbols-mode 1)))
  (rust-mode . (lambda () (setq-local indent-tabs-mode nil))))

(use-package rustic
  :ensure t
  :after (rust-mode)
  :config
  (setq rustic-lsp-client 'eglot))

;;; Shell mode
(defun ms/sh-mode-setup ()
  "Apply personal indentation settings to shell buffers."
  (setq-local indent-tabs-mode nil
              tab-width 2
              sh-basic-offset 2))

(use-package sh-script
  :ensure nil
  :hook ((sh-mode . ms/sh-mode-setup)
         (sh-mode . flymake-mode)))

;;; Swift syntax highlighting; Xcode owns semantic Swift development.
(use-package swift-mode
  :ensure t
  :commands swift-mode
  :mode (("\\.swift\\'" . swift-mode))
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
