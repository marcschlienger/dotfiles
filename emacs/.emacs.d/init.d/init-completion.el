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
  (add-to-list 'eglot-server-programs '(python-ts-mode . ("ty" "server")))
  (add-to-list 'eglot-server-programs '(python-mode . ("ty" "server")))
  (add-to-list 'eglot-server-programs '((rust-ts-mode rust-mode) .
               ("rust-analyzer" :initializationOptions (:check (:command "clippy")))))
  :custom
  ;; Formatting is *not* ignored globally.  Ruff owns it for Python and
  ;; rustfmt through Rustic for Rust, so it is switched off per buffer for
  ;; those two below; clangd and texlab keep theirs, because nothing else
  ;; formats C, C++ or LaTeX here.
  (eglot-ignored-server-capabilities
   '(:documentHighlightProvider
     :colorProvider
     :foldingRangeProvider))
  :hook
  (c-mode . eglot-ensure)
  (c-ts-mode . eglot-ensure)
  (c++-mode . eglot-ensure)
  (c++-ts-mode . eglot-ensure)
  (LaTeX-mode . eglot-ensure)
  (python-mode . eglot-ensure)
  (python-ts-mode . eglot-ensure)
  (rust-mode . eglot-ensure)
  (rust-ts-mode . eglot-ensure))

;; `eglot-server-capable' reads `eglot-ignored-server-capabilities' as a
;; plain variable in the current buffer, so a buffer-local value scopes the
;; exclusion to one language.
(defun ms/eglot-server-formatting-off ()
  "Ignore the server's formatting capabilities in this buffer."
  ;; `add-hook' prepends, so this runs before the `eglot-ensure' on the same
  ;; hook -- which means Eglot is not loaded yet and its variable is void.
  ;; Requiring it here costs nothing: `eglot-ensure' is about to load it
  ;; anyway, one hook entry later.
  (require 'eglot)
  (setq-local eglot-ignored-server-capabilities
              (append '(:documentFormattingProvider
                        :documentRangeFormattingProvider
                        :documentOnTypeFormattingProvider)
                      eglot-ignored-server-capabilities)))

(dolist (hook '(python-mode-hook python-ts-mode-hook
                rust-mode-hook rust-ts-mode-hook))
  (add-hook hook #'ms/eglot-server-formatting-off))

;; Keep ty as Python's semantic server.  Ruff adds lint diagnostics through
;; Flymake and formats Python buffers on save without competing for Eglot.
;; No `:after eglot': Eglot is first loaded by `eglot-ensure' from inside
;; `python-mode-hook', and a function added to a hook while that hook is
;; running is not seen until the next buffer -- so the first Python file of
;; the session opened without any Ruff diagnostics.
(use-package flymake-ruff
  :ensure t
  :hook ((python-mode python-ts-mode) . flymake-ruff-load))

(use-package ruff-format
  :ensure t
  :hook ((python-mode python-ts-mode) . ruff-format-on-save-mode))

;;; Completion styles
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  ;; One sort function for both sides.  Vertico takes `display-sort-function'
  ;; from the completion metadata, while `completion-all-sorted-completions'
  ;; -- the list TAB cycles through -- takes `cycle-sort-function'.  Setting
  ;; only Vertico's own sort variable moved the display without moving the
  ;; cycle, so the first candidate shown was not the one TAB inserted.
  (completion-category-overrides
   '((file (styles partial-completion)
           (display-sort-function . vertico-sort-directories-first)
           (cycle-sort-function . vertico-sort-directories-first))))
  :init
  (when (boundp 'completion-pcm-leading-wildcard)
    (setq completion-pcm-leading-wildcard nil)))

;;; In-buffer completion
(use-package corfu
  :ensure t
  :bind (:map corfu-map
              ("TAB" . corfu-next)
              ([tab] . corfu-next)
              ("S-TAB" . corfu-previous)
              ([backtab] . corfu-previous))
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-preview-current nil)
  (corfu-preselect 'prompt)
  :init
  (global-corfu-mode 1)
  (corfu-history-mode 1)
  (corfu-popupinfo-mode 1))

;; Emacs 31 draws Corfu's child frames in a terminal frame by itself.  The
;; Debian machine is on the distribution's Emacs 30.1, so the fallback still
;; earns its place; corfu warns about the package being installed on 31,
;; which is the price of one configuration serving both.
(when (< emacs-major-version 31)
  (use-package corfu-terminal
    :ensure t
    :after corfu
    :config
    (corfu-terminal-mode 1)))

;;; Completion behavior
(use-package emacs
  :ensure nil
  :custom
  (completion-ignore-case t)
  (completion-cycle-threshold t)
  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))
  (read-buffer-completion-ignore-case t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (read-file-name-completion-ignore-case t)
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  :hook
  (minibuffer-setup . cursor-intangible-mode)
  :init
  (minibuffer-depth-indicate-mode 1)
  (defun ms/completing-read-multiple-indicator (args)
    "Add a multiple-selection indicator to the minibuffer prompt."
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?\\]\\*\\|\\[.*?\\]\\*\\'" "" crm-separator)
                  (car args))
          (cdr args)))
  ;; Emacs 31 shows the CRM indicator itself.  The advice was never added on
  ;; a fresh process, so removing it in the other branch did nothing.
  (when (< emacs-major-version 31)
    (advice-add #'completing-read-multiple :filter-args
                #'ms/completing-read-multiple-indicator)))

;;; Completion-at-point extensions
(use-package cape
  :ensure t
  :bind ("C-c p" . cape-prefix-map)
  :init
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-buster)
  ;; `add-hook' prepends by default.  Add these in reverse priority order so
  ;; ordinary text completion wins over incidental file-name matches.
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

;; Which key.  Built into Emacs since 30; there is no ELPA copy to install.
(use-package which-key
  :ensure nil
  :config
  (which-key-mode 1))

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
  :bind (:map vertico-map
              ("TAB" . minibuffer-complete)
              ([tab] . minibuffer-complete)
              ("S-TAB" . vertico-previous)
              ([backtab] . vertico-previous))
  :custom
  (vertico-cycle t)
  (vertico-preselect 'prompt)
  :init
  (vertico-mode 1))

(use-package vertico-directory
  :ensure nil
  :after vertico)

(use-package vertico-multiform
  :ensure nil
  :after vertico
  :custom
  (vertico-multiform-categories
   ;; Sorting is set through `completion-category-overrides' instead, so that
   ;; it reaches TAB as well; `vertico-sort-function' is consulted only after
   ;; `display-sort-function' and would never be seen by the completion
   ;; machinery.  Only the keymap belongs here.
   '((file (:keymap . vertico-directory-map))))
  :init
  (vertico-multiform-mode 1))

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
  ;; Not redundant: the default is ~/.emacs.d/history.  This name is the one
  ;; the existing history was written under.
  (savehist-file (locate-user-emacs-file "savehist"))
  :config
  ;; Not the kill ring.  Cross-session clipboard history is worth little
  ;; next to the chance of a password copied out of KeePassXC surviving on
  ;; disk in plain text.
  ;; `corfu-history-mode' sorts candidates by history, but only savehist
  ;; carries that history across sessions.
  (add-to-list 'savehist-additional-variables 'corfu-history)
  :init
  (savehist-mode 1))

;;; Completion annotations
(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode 1))

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

;; No preview hook here: embark-consult adds
;; `consult--default-completion-list-preview-setup' to
;; `embark-collect-mode-hook' itself.  The older idiom hooked
;; `consult-preview-at-point-mode', which Consult 3.7 no longer defines --
;; and because use-package turns an unknown :hook function into an autoload
;; pointing at the package, that failed at the worst moment: entering a
;; collect buffer, with "failed to define function".
(use-package embark-consult
  :ensure t
  :after (embark consult))

;; Template system for Emacs.
(use-package yasnippet
  :ensure t
  ;; :demand t is load-bearing: the bindings below live in keymaps that only
  ;; exist once yasnippet is loaded, so :bind alone would defer the package
  ;; forever and `yas-global-mode' would never run.
  :demand t
  :bind
  ;; Not M-z: `yas-minor-mode-map' is active almost everywhere under
  ;; `yas-global-mode', so binding there shadowed `zap-to-char' globally.
  ;; The field-motion keys below are safe -- `yas-keymap' is only live
  ;; while a snippet field is active.
  ( :map yas-minor-mode-map
    ("C-c y" . yas-expand)              ; expand a snippet
    :map yas-keymap
    ("M-j" . yas-next-field-or-maybe-expand) ; jump between fields
    ("M-k" . yas-prev-field))
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(provide 'init-completion)
