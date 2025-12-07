;;; init-completion.el -*- lexical-binding: t -*-

;; Eglot mode
(use-package eglot
  :ensure nil
  :config
  (setq completion-category-defaults nil)
  (add-to-list 'eglot-stay-out-of 'flymake)
  (add-to-list 'eglot-server-programs '(c-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(c-ts-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(c++-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(c++-ts-mode . ("clangd")))
  (add-to-list 'eglot-server-programs '(LaTeX-mode . ("texlab")))
  (add-to-list 'eglot-server-programs '(LaTeX-ts-mode . ("texlab")))
  (add-to-list 'eglot-server-programs '(python-ts-mode . ("pylsp")))
  (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))
  (add-to-list 'eglot-server-programs '(swift-ts-mode . ("sourcekit-lsp")))
  (add-to-list 'eglot-server-programs '(swift-mode . ("sourcekit-lsp")))
  (add-to-list 'eglot-server-programs '((rust-ts-mode rust-mode) .
               ("rust-analyzer" :initializationOptions (:check (:command "clippy")))))
  :custom
  (eglot-ignored-server-capabilities
   '(:hoverProvider
     :documentHighlightProvider
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
  (swift-mode . eglot-ensure)
  (swift-ts-mode . eglot-ensure)
  (rust-mode-hook . eglot-ensure)
  (rust-ts-mode-hook . eglot-ensure))

;;
(use-package rfn-eshadow
  :ensure nil
  :config
  (file-name-shadow-mode 1))

;; In-buffer completion with corfu
(use-package corfu
  :ensure t
  :bind
  ( :map corfu-map
        ("TAB" . corfu-next)
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous))
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  ;(corfu-quit-at-boundary nil)
  ;(corfu-quit-no-match nil)
  ;(corfu-preview-current nil)
  ;(corfu-preselect 'prompt)
  ;(corfu-on-exact-match nil)
  :init
  (global-corfu-mode))

;; A few more useful configurations...
(use-package emacs
  :ensure nil
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function. As an alternative,
  ;; try `cape-dict'.
  (setq text-mode-ispell-word-completion nil)

  ;; Emacs 28 and newer: Hide commands in M-x which do not apply to the current
  ;; mode.  Corfu commands are hidden, since they are not used via M-x. This
  ;; setting is useful beyond Corfu.
  (setq read-extended-command-predicate #'command-completion-default-include-p))

;; Cape
(use-package cape
  :ensure t
  ;; Bind dedicated completion commands
  ;; Alternative prefix keys: C-c p, M-p, M-+, ...
  :bind (("C-c p p" . completion-at-point)
         ("C-c p t" . complete-tag)
         ("C-c p d" . cape-dabbrev)
         ("C-c p h" . cape-history)
         ("C-c p f" . cape-file)
         ("C-c p k" . cape-keyword)
         ("C-c p s" . cape-elisp-symbol)
         ("C-c p e" . cape-elisp-block)
         ("C-c p a" . cape-abbrev)
         ("C-c p l" . cape-line)
         ("C-c p w" . cape-dict)
         ("C-c p :" . cape-emoji)
         ("C-c p \\" . cape-tex)
         ("C-c p _" . cape-tex)
         ("C-c p ^" . cape-tex)
         ("C-c p &" . cape-sgml)
         ("C-c p r" . cape-rfc1345))
  :config
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  :init
  (add-hook 'completion-at-point-functions #'cape-keyword)
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-tex))

;; Which key
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;;; Consult
;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark))

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
 )

;; Vertico
(use-package vertico
  :ensure t
  :bind
  ( :map vertico-map
    ("TAB" . minibuffer-complete))
  :custom
  (vertico-scroll-margin 0)
  (vertico-count 8)
  (vertico-resize nil)
  (vertico-cycle t)
  :config
  (with-eval-after-load 'rfn-eshadow
    ;; This works with `file-name-shadow-mode' enabled.  When you are in
    ;; a sub-directory and use, say, `find-file' to go to your home '~/'
    ;; or root '/' directory, Vertico will clear the old path to keep
    ;; only your current input.
    (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy))
  :init
  (vertico-mode))

;;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure t
  :config
  (setq savehist-file (locate-user-emacs-file "savehist"))
  (setq history-length 200)
  (setq history-delete-duplicates t)
  (setq savehist-save-minibuffer-history t)
  (add-to-list 'savehist-additional-variables 'kill-ring)
  :init
  (savehist-mode))

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :ensure t
  :bind
  ( :map minibuffer-local-map
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

;; Embark-Consult
(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package all-the-icons
  :ensure t
  :if (or (daemonp) (display-graphic-p)))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

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
