;;; init--latex.el -*- lexical-binding: t -*-

;; AUCTeX
(use-package tex-site
  :ensure auctex
  :mode ("\\.tex\\'" . latex-mode)
  :bind
  ("<f7>" . (lambda ()
		     "Save the buffer and run `TeX-command-run-all`."
		     (interactive)
		     (save-buffer)
		     (TeX-command-run-all nil)))
  :custom
  (TeX-save-query nil)
  (TeX-source-correlate-mode t)
  :hook
  (LaTeX-mode . prettify-symbols-mode)
  (LaTeX-mode . visual-line-mode)
  (LaTeX-mode . flymake-mode)
  (LaTeX-mode . LaTeX-math-mode)
  (LaTeX-mode . turn-on-reftex)
  (LaTeX-mode . turn-on-auto-fill)
  (LaTeX-mode . outline-minor-mode)
  (TeX-after-compilation-finished-functions . TeX-revert-document-buffer)
  :config
  (setq LaTeX-item-indent 0)
  (setq TeX-newline-function 'reindent-then-newline-and-indent)
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (setq TeX-PDF-mode t)
  (setq reftex-plug-into-AUCTeX t)
  (setq TeX-view-program-selection '((output-pdf "PDF Tools")))
  (setq TeX-source-correlate-start-server t))

(use-package cdlatex
  :ensure t
  :hook ((LaTeX-mode  . turn-on-cdlatex)
         (org-mode    . turn-on-org-cdlatex)
         (cdlatex-tab . LaTeX-indent-line)))

(use-package pdf-tools
  :ensure t
  :hook
  (pdf-view-mode . (lambda () (auto-revert-mode 1)))
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width))

(provide 'init-latex)
