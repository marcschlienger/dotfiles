;;; init-latex.el -*- lexical-binding: t -*-

;; Bound globally below, so it has to say no politely elsewhere rather than
;; failing inside AUCTeX.
(defun ms/latex-save-and-build ()
  "Save the buffer and run `TeX-command-run-all'."
  (interactive)
  (unless (derived-mode-p 'TeX-mode)
    (user-error "Not a TeX buffer"))
  (save-buffer)
  (TeX-command-run-all nil))

;; `LaTeX-math-mode' lives in AUCTeX's latex.el and AUCTeX does not autoload
;; it.  Naming it in :hook below would therefore make use-package invent an
;; autoload pointing at `tex-site', which cannot define it -- the same trap
;; that broke the CDLaTeX TAB hook.  Opening a .tex file happens to repair
;; that, because loading LaTeX-mode loads latex.el before the hook runs, but
;; `M-x LaTeX-math-mode' in a session with no TeX buffer would hit the bad
;; stub.  Declaring the real one first means use-package leaves it alone.
(autoload 'LaTeX-math-mode "latex" "Toggle LaTeX math mode." t)

;; AUCTeX
(use-package tex-site
  :ensure auctex
  :mode ("\\.tex\\'" . LaTeX-mode)
  :bind
  ("<f7>" . ms/latex-save-and-build)
  :custom
  (TeX-save-query nil)
  (TeX-source-correlate-mode t)
  :hook
  (LaTeX-mode . prettify-symbols-mode)
  (LaTeX-mode . visual-line-mode)
  (LaTeX-mode . flymake-mode)
  (LaTeX-mode . LaTeX-math-mode)
  (LaTeX-mode . turn-on-reftex)
  ;; No auto-fill hook here: LaTeX-mode descends from `text-mode', whose
  ;; hook already turns it on.
  (LaTeX-mode . outline-minor-mode)
  :config
  (add-hook 'TeX-after-compilation-finished-functions
            #'TeX-revert-document-buffer)
  (setq LaTeX-item-indent 0)
  (setq TeX-newline-function 'reindent-then-newline-and-indent)
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (setq TeX-PDF-mode t)
  (setq reftex-plug-into-AUCTeX t)
  ;; The PDF opens in Emacs wherever it can be drawn, and in an external
  ;; viewer on a terminal frame.  AUCTeX takes the first entry of
  ;; `TeX-view-program-selection' whose predicates all hold, so the choice
  ;; is made each time a document is viewed, not once at startup -- which
  ;; matters under a daemon, where no frame exists yet when this runs.
  ;; Set, not added to: this runs when tex-site loads, before tex.el has
  ;; defined the variable.  The list holds only predicates defined here;
  ;; AUCTeX keeps its own in `TeX-view-predicate-list-builtin'.
  (setq TeX-view-predicate-list '((graphic-frame (display-graphic-p))))
  (let* ((skim "/Applications/Skim.app/Contents/SharedSupport/displayline")
         (external
          (cond
           ((and (eq system-type 'darwin) (file-executable-p skim))
            (setq TeX-view-program-list
                  `(("Skim" ,(concat skim " -b -g %n %o %b"))))
            "Skim")
           ((eq system-type 'darwin)
            (setq TeX-view-program-list '(("System PDF viewer" "open %o")))
            "System PDF viewer")
           ;; AUCTeX's own Zathura entry rather than one defined here.  Its
           ;; builtin command carries `--synctex-forward' and an emacsclient
           ;; inverse-search hook; a bare "zathura %o" in
           ;; `TeX-view-program-list' shadows it and silently drops both
           ;; directions of SyncTeX.
           ((executable-find "zathura") "Zathura")
           (t
            (setq TeX-view-program-list
                  '(("System PDF viewer" "xdg-open %o")))
            "System PDF viewer"))))
    (setq TeX-view-program-selection
          `(((output-pdf graphic-frame) "PDF Tools")
            (output-pdf ,external))))
  (setq TeX-source-correlate-start-server t))

;; AUCTeX keeps its in-buffer previews behind C-c C-p, so the most common
;; one, preview at point, is C-c C-p C-p.  The same keymap on a single key
;; leaves every binding inside it as it was: <f6> C-p, <f6> C-b and so on.
;; Loading preview.el is what defines the keymap, and it loads latex.el
;; first, so `LaTeX-mode-map' exists by then.
(with-eval-after-load 'preview
  (keymap-set LaTeX-mode-map "<f6>" preview-map))

;; `cdlatex-tab-hook' is a global defcustom, so putting `LaTeX-indent-line'
;; in its default value had two faults.  It fired in Org buffers as well,
;; where AUCTeX indentation is wrong; and use-package, seeing a :hook
;; function it does not recognise, autoloaded it from cdlatex -- which does
;; not define it, it is AUCTeX's.  Opening Org before any LaTeX file then
;; failed with "Autoloading cdlatex.elc failed to define function
;; LaTeX-indent-line".  Add it buffer-locally instead, in LaTeX buffers,
;; where AUCTeX is loaded by definition.
(defun ms/cdlatex-latex-setup ()
  "Turn on CDLaTeX and let its TAB fall through to AUCTeX indentation."
  (turn-on-cdlatex)
  (add-hook 'cdlatex-tab-hook #'LaTeX-indent-line nil t))

(use-package cdlatex
  :ensure t
  :hook ((LaTeX-mode . ms/cdlatex-latex-setup)
         (org-mode   . turn-on-org-cdlatex)))

;; PDF Tools shows a PDF inside Emacs, with SyncTeX in both directions.
;; `pdf-loader-install' registers `pdf-view-mode' for .pdf files without
;; loading the package: the first PDF opened loads it, and offers to build
;; the epdfinfo server on a machine that has not built it yet.  The two
;; arguments matter.  The first keeps that question; the second stops the
;; build script from calling the system's package manager, which it
;; otherwise does when it finds a dependency missing.
;; Nothing reverts the buffer here.  AUCTeX does it when a compilation
;; finishes, through `TeX-revert-document-buffer' above, and Auto Revert as
;; well would be a second revert of the same buffer.
(use-package pdf-tools
  :ensure t
  :defer t
  :init
  (pdf-loader-install nil t)
  :config
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-view-use-scaling t)
  (setq pdf-view-use-imagemagick nil))

;; AUCTeX's view command only runs a forward search when
;; `pdf-sync-forward-search' is fboundp; otherwise it just shows the PDF.
;; PDF Tools defines that function in pdf-sync.el without an autoload, and
;; nothing loads pdf-sync.el until a PDF buffer exists -- so the first view
;; of a session opens the PDF at page one instead of at point.  Declaring
;; the autoload makes the function known from the start; calling it loads
;; the rest.
(autoload 'pdf-sync-forward-search "pdf-sync" nil t)

(provide 'init-latex)
