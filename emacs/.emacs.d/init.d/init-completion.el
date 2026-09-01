;;; init-completion.el -*- lexical-binding: t -*-

;; Eglot mode
(use-package eglot
  :ensure nil
  :config
  (add-to-list 'eglot-server-programs '(c-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(c-ts-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(c++-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(c++-ts-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(LaTeX-mode . ("texlab")))
  (add-to-list 'eglot-server-programs '(LaTeX-ts-mode . ("texlab")))
  (add-to-list 'eglot-server-programs '(python-ts-mode . ("ty" "server")))
  (add-to-list 'eglot-server-programs '(python-mode . ("ty" "server")))
  (add-to-list 'eglot-server-programs '((rust-ts-mode rust-mode) .
               ("rust-analyzer" :initializationOptions (:check (:command "clippy")))))
  :custom
  (eglot-ignored-server-capabilities
   '(:documentHighlightProvider
     :documentFormattingProvider
     :documentRangeFormattingProvider
     :documentOnTypeFormattingProvider
     :colorProvider
     :foldingRangeProvider))
  :hook
  (c-mode . eglot-ensure)
  (c-ts-mode . eglot-ensure)
  (c++-mode . eglot-ensure)
  (c++-ts-mode . eglot-ensure)
  (LaTeX-mode . eglot-ensure)
  (LaTeX-ts-mode . eglot-ensure)
  (python-mode . eglot-ensure)
  (python-ts-mode . eglot-ensure)
  (rust-mode . eglot-ensure)
  (rust-ts-mode . eglot-ensure))

;; Keep ty as Python's semantic server.  Ruff adds lint diagnostics through
;; Flymake and formats Python buffers on save without competing for Eglot.
(use-package flymake-ruff
  :ensure t
  :after eglot
  :hook ((python-mode python-ts-mode) . flymake-ruff-load))

(use-package ruff-format
  :ensure t
  :hook ((python-mode python-ts-mode) . ruff-format-on-save-mode))

;;; Completion styles
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  :init
  (when (boundp 'completion-pcm-leading-wildcard)
    (setq completion-pcm-leading-wildcard t)))

;;; In-buffer completion
(use-package corfu
  :ensure t
  :bind (:map corfu-map
              ("S-TAB" . corfu-previous)
              ([backtab] . corfu-previous))
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode))

;; Emacs 31 supports Corfu child frames in terminal frames directly.
(when (< emacs-major-version 31)
  (use-package corfu-terminal
    :ensure t
    :after corfu
    :config
    (corfu-terminal-mode)))

;;; Completion behavior
(use-package emacs
  :ensure nil
  :custom
  (completion-cycle-threshold 3)
  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (read-extended-command-predicate #'command-completion-default-include-p)
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  :hook
  (minibuffer-setup . cursor-intangible-mode)
  :init
  (defun ms/completing-read-multiple-indicator (args)
    "Add a multiple-selection indicator to the minibuffer prompt."
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?\\]\\*\\|\\[.*?\\]\\*\\'" "" crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args
              #'ms/completing-read-multiple-indicator))

;;; Completion-at-point extensions
(use-package cape
  :ensure t
  :bind ("C-c p" . cape-prefix-map)
  :init
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-buster)
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

;; Which key
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;;; Consult
(use-package consult
  :ensure t
  :bind (([remap Info-search] . consult-info)
         ([remap bookmark-jump] . consult-bookmark)
         ([remap goto-line] . consult-goto-line)
         ([remap project-switch-to-buffer] . consult-project-buffer)
         ([remap switch-to-buffer] . consult-buffer)
         ([remap switch-to-buffer-other-frame] . consult-buffer-other-frame)
         ([remap switch-to-buffer-other-tab] . consult-buffer-other-tab)
         ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
         ([remap yank-pop] . consult-yank-pop)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ("M-s d" . consult-fd)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         :map minibuffer-local-map
         ("M-s" . consult-history))

  :init
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :custom
  (consult-narrow-key "<")

  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.5 any)
   consult-fd consult-man consult-ripgrep
   consult-bookmark consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   :preview-key '(:debounce 0.4 any)))

;;; Minibuffer completion
(use-package vertico
  :ensure t
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word)))

(use-package vertico-repeat
  :ensure nil
  :after vertico
  :bind ("M-R" . vertico-repeat)
  :hook (minibuffer-setup . vertico-repeat-save))

;;; Completion history
(use-package savehist
  :ensure nil
  :custom
  (history-delete-duplicates t)
  (history-length 200)
  (savehist-file (locate-user-emacs-file "savehist"))
  :config
  (add-to-list 'savehist-additional-variables 'kill-ring)
  :init
  (savehist-mode))

;;; Completion annotations
(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

;;; Embark
(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t)

;; Template system for Emacs.
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

;; Use Meta-z to exapnd a snippet
(define-key yas-minor-mode-map (kbd "M-z") 'yas-expand)

;; Use Meta-j and Meta-k to jump between fields
(define-key yas-keymap (kbd "M-j") 'yas-next-field-or-maybe-expand)
(define-key yas-keymap (kbd "M-k") 'yas-prev-field)

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(provide 'init-completion)
