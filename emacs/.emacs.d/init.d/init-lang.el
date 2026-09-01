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
  ;; Shell paths and command strings create too many false positives.
  (sh-mode . ms/flyspell-disable))

;; Trailing whitespace is a hard line break in Markdown and part of the table
;; syntax in Org, so those two are left alone.  A named function can be
;; removed again and does not pile up a second copy when init.el is reloaded.
(defun ms/delete-trailing-whitespace-maybe ()
  "Trim trailing whitespace unless the major mode gives it meaning."
  (unless (derived-mode-p 'markdown-mode 'org-mode)
    (delete-trailing-whitespace)))

(use-package emacs
  :bind
  (:map global-map
        ("\C-m" . newline-and-indent))
  :hook (before-save . ms/delete-trailing-whitespace-maybe)
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

;;; Elisp packaging requirements.  `package-lint-flymake-setup' switches
;;; Flymake on unconditionally, and its checks -- Package-Requires, Version,
;;; a Commentary section, prefixed symbols -- are all meaningless in a
;;; personal init file, where they produced eighteen diagnostics per module.
;;; Run it only in buffers that declare themselves a package.
(defun ms/package-lint-flymake-setup ()
  "Enable package-lint diagnostics in real package sources only."
  (when (save-excursion
          (goto-char (point-min))
          (re-search-forward "^;;+ *Package-Requires *:"
                             (min 4000 (point-max)) t))
    (package-lint-flymake-setup)))

(use-package package-lint-flymake
  :ensure t
  :hook (emacs-lisp-mode . ms/package-lint-flymake-setup))

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
;; Paredit inserts its own delimiters; leaving `electric-pair-mode' on as
;; well gives doubled parens and quotes.
(defun ms/paredit-setup ()
  "Enable Paredit and stand `electric-pair-mode' down in this buffer."
  (electric-pair-local-mode -1)
  (paredit-mode 1))

(use-package paredit
  :ensure t
  :hook (clojure-mode . ms/paredit-setup))

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

;;; Rust
(defun ms/rust-mode-setup ()
  "Apply personal settings to Rust buffers."
  (prettify-symbols-mode 1)
  (setq-local indent-tabs-mode nil))

(use-package rust-mode
  :ensure t
  :hook (rust-mode . ms/rust-mode-setup))

;; Rustic owns formatting.  It replaces `rust-before-save-hook' with its own
;; function, and that function asks `rustic-format-on-save-p', which reads
;; `rustic-format-trigger' and ignores `rust-format-on-save' entirely.  With
;; the trigger left at nil, `rust-format-on-save t' looked like
;; format-on-save while formatting nothing.
(use-package rustic
  :ensure t
  :after (rust-mode)
  :config
  (setq rustic-format-trigger 'on-save)
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

;; .editorconfig file support.  Built into Emacs since 30.
(use-package editorconfig
    :ensure nil
    :config (editorconfig-mode +1))

;;; Plain text (text-mode)
(defun ms/prog-mode-sentence-spacing ()
  "Require two spaces after a sentence in code, as Emacs Lisp does."
  (setq-local sentence-end-double-space t))

(use-package text-mode
  :ensure nil
  ;; `auto-mode-alist' is matched against the whole path, so a regexp
  ;; anchored with \` matched a bare "README" and never /some/where/README
  ;; -- which is every file you actually open.  Anchor on the separator.
  :mode "\\(?:\\`\\|/\\)\\(README\\|CHANGELOG\\|COPYING\\|LICENSE\\)\\'"
  :hook
  ((text-mode . turn-on-auto-fill)
   (prog-mode . ms/prog-mode-sentence-spacing))
  :config
  (setq sentence-end-double-space nil)
  (setq sentence-end-without-period nil)
  (setq colon-double-space nil)
  (setq use-hard-newlines nil)
  (setq adaptive-fill-mode t))

(provide 'init-lang)
