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

;;; Spell checking
;;
;; Jinx is the checker; Flyspell is the fallback where Jinx cannot run.
;;
;; Jinx checks only the visible region, and only text carrying prose faces.
;; That is the important difference: Flyspell cannot tell code from prose, so
;; shell scripts produced so many false positives that the checker had to be
;; switched off there wholesale.  Jinx skips the code and still checks the
;; comments.  Multiple languages are native to it rather than a hunspell
;; multi-dictionary trick.
;;
;; It needs libenchant and a module compiled on first use:
;;
;;   macOS   ./steps/install-enchant-hunspell   (in macos-bootstrap)
;;   Debian  ./extras spell                      (in debian-bootstrap)
;;
;; What the module actually needs is the library and its headers plus a
;; compiler -- libenchant-2-dev, pkg-config, build-essential.  The enchant-2
;; command is a separate package and Jinx does not use it; it is installed
;; only so `enchant-lsmod-2' below can be run.
;;
;; Enchant does not check spelling itself; it dispatches to whichever provider
;; it was built with, and German needs that to be hunspell.  Aspell cannot
;; decompose compounds: over eighteen everyday school words it accepted 6,
;; hunspell 18.  Homebrew's enchant ships no hunspell provider at all, which
;; is what the macos-bootstrap step above builds and installs.
;;
;; English stays on aspell on both platforms -- enchant's own ordering file
;; prefers it for en_US and en_GB, and English does not compound.
;;
;; Check what is actually serving a language before trusting it:
;;
;;   enchant-lsmod-2 -lang de_DE     # want: de_DE (hunspell)
(defun ms/spell-checker-setup ()
  "Enable Jinx if its module builds and loads here, otherwise Flyspell.

Whether Jinx works is not something the presence of the enchant CLI can
answer, which is what this used to test.  Debian packages the command
line tools (enchant-2), the library (libenchant-2-2) and the headers
(libenchant-2-dev) separately, so the probe said no on a machine where
Jinx would have worked -- and a machine with the command but no compiler
or headers made it say yes, leaving Jinx enabled but broken while
Flyspell was switched off, so nothing checked spelling at all.

Ask the real question instead.  `jinx--load-module' is what compiles the
module on first use and loads it afterwards, and it is the step that
fails when enchant, pkg-config or a compiler are missing."
  (if (condition-case err
          (progn (require 'jinx) (jinx--load-module) t)
        (error
         (display-warning
          'spell
          (format "Jinx unavailable (%s).\nUsing Flyspell instead; see the \
spell checking section of emacs-init.org."
                  (error-message-string err))
          :warning)
         nil))
      (progn
        (global-jinx-mode 1)
        ;; Bound here rather than with :bind so the keys follow whichever
        ;; checker actually won.  Under Flyspell they keep their defaults,
        ;; where M-$ is `ispell-word'.
        (keymap-global-set "M-$" #'jinx-correct)
        (keymap-global-set "C-M-$" #'jinx-languages))
    (add-hook 'text-mode-hook #'flyspell-mode)
    (add-hook 'prog-mode-hook #'flyspell-prog-mode)
    ;; Shell paths and command strings create too many false positives.
    (add-hook 'sh-mode-hook #'ms/flyspell-disable)))

(add-hook 'emacs-startup-hook #'ms/spell-checker-setup)

(use-package jinx
  :ensure t
  :defer t
  :custom
  (jinx-languages "en_US de_DE"))

(defun ms/flyspell-disable ()
  "Turn flyspell off in the current buffer."
  (flyspell-mode -1))

(use-package flyspell
  :ensure nil
  :defer t
  :config
  (setq flyspell-issue-message-flag nil)
  (setq flyspell-issue-welcome-flag nil))

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
  ;; No `go' entry.  A remapping needs a mode to remap *from*, and `go-mode'
  ;; is not installed; Emacs supplies the association itself, because its own
  ;; go-ts-mode.el autoloads `go-ts-mode-maybe' into `auto-mode-alist'.  A .go
  ;; file therefore opens in `go-ts-mode' with no help from this list, which
  ;; is why the entry was dead rather than wrong.  The grammar recipe below
  ;; stays: go-ts-mode needs the grammar even though it needs no remapping.
  ;;
  ;; Worth confirming on Debian's Emacs 30.1, where that autoload may predate
  ;; the `-maybe' dispatcher:
  ;;
  ;;   emacs -Q --batch --eval \
  ;;     '(princ (assoc-default "x.go" auto-mode-alist (quote string-match)))'
  ;;
  ;; Anything printed means .go is associated and nothing is needed here.  If
  ;; it prints nothing, add the association rather than a remapping:
  ;;
  ;;   (add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
  (defconst ms/treesit-major-mode-remappings
    '((c c-mode c-ts-mode)
      (cpp c++-mode c++-ts-mode)
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

;;; Clojure was configured here -- clojure-mode, CIDER, clj-refactor and
;;; Flycheck with clj-kondo -- but never used, and the Debian side never
;;; installed a JVM or the Clojure CLI for any of it to talk to.  Removed.
;;;
;;; Flycheck went with it.  It is a general framework, but it had exactly one
;;; hook here, `clojure-mode'.  Diagnostics everywhere else come from Flymake
;;; (Eglot, flymake-ruff, package-lint-flymake, and `sh-shellcheck-flymake'
;;; for shell scripts), and running both frameworks in one buffer duplicates
;;; every message.

;;; Emacs Lisp
;; `lisp-data-mode' is the parent of `emacs-lisp-mode', so one hook covers
;; .el sources and .eld data files alike.  IELM is deliberately left out:
;; it derives from `comint-mode', where Paredit's RET would fight
;; `comint-send-input'.
(defun ms/lisp-mode-setup ()
  "Structural editing and section navigation for Lisp buffers."
  ;; Paredit inserts its own delimiters; `electric-pair-mode' as well gives
  ;; doubled parens and quotes.
  (electric-pair-local-mode -1)
  (paredit-mode 1)
  ;; The mode already sets `outline-regexp' to match `;;;' headings and
  ;; `outline-level' to `lisp-outline-level', so this only switches it on.
  (outline-minor-mode 1))

(use-package paredit
  :ensure t
  :hook (lisp-data-mode . ms/lisp-mode-setup))

;; Byte-compile and checkdoc diagnostics on save -- not while typing:
;; `flymake-no-changes-timeout' is nil above, so nothing is checked until the
;; buffer is written.  Nothing else turns
;; Flymake on in an ordinary .el buffer: `elisp-flymake-byte-compile' and
;; `elisp-flymake-checkdoc' are registered by default but never run without
;; the mode.  `package-lint-flymake-setup' used to enable it as a side
;; effect, which stopped when that was restricted to real packages.
(use-package elisp-mode
  :ensure nil
  :hook (emacs-lisp-mode . flymake-mode))

;; Expand a macro in place, one step at a time, and collapse it again.
(use-package macrostep
  :ensure t
  :bind ( :map emacs-lisp-mode-map
          ("C-c e" . macrostep-expand)))

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
