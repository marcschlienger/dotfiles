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
  ;; No `turn-on-auto-fill' here: LaTeX-mode descends from `text-mode',
  ;; whose hook already turns it on.
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
  (let ((skim "/Applications/Skim.app/Contents/SharedSupport/displayline"))
    (cond
     ((and (eq system-type 'darwin) (file-executable-p skim))
      (setq TeX-view-program-selection '((output-pdf "Skim"))
            TeX-view-program-list
            `(("Skim" ,(concat skim " -b -g %n %o %b")))))
     ((eq system-type 'darwin)
      (setq TeX-view-program-selection '((output-pdf "System PDF viewer"))
            TeX-view-program-list '(("System PDF viewer" "open %o"))))
     ((executable-find "zathura")
      (setq TeX-view-program-selection '((output-pdf "Zathura"))
            TeX-view-program-list '(("Zathura" "zathura %o"))))
     (t
      (setq TeX-view-program-selection '((output-pdf "System PDF viewer"))
            TeX-view-program-list '(("System PDF viewer" "xdg-open %o"))))))
  (setq TeX-source-correlate-start-server t))

(use-package cdlatex
  :ensure t
  :hook ((LaTeX-mode  . turn-on-cdlatex)
         (org-mode    . turn-on-org-cdlatex)
         (cdlatex-tab . LaTeX-indent-line)))

;; Optional PDF Tools integration.  Keep it dormant until the package is
;; installed explicitly, then activate it on the next Emacs startup.
(defun ms/pdf-view-setup ()
  "Reload a PDF buffer when the file on disk is rebuilt."
  (auto-revert-mode 1))

(use-package pdf-tools
  :ensure nil
  :if (locate-library "pdf-tools")
  ;; `:demand t', not `:defer t'.  `pdf-tools-install' is the call that
  ;; registers pdf-view-mode for .pdf files, so deferring the package left
  ;; nothing to trigger it and DocView kept winning.
  :demand t
  :hook (pdf-view-mode . ms/pdf-view-setup)
  :config
  (pdf-tools-install t)
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-view-use-scaling t)
  (setq pdf-view-use-imagemagick nil))

(provide 'init-latex)
