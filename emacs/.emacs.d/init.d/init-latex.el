;;; init-latex.el -*- lexical-binding: t -*-

;; AUCTeX
(use-package tex-site
  :ensure auctex
  :mode ("\\.tex\\'" . LaTeX-mode)
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

(provide 'init-latex)
