;;; init-terminal.el -*- lexical-binding: t -*-

(use-package ghostel
  :ensure t
  :commands ghostel
  :bind (("C-c t" . ghostel)
         ("C-c T" . ghostel-project)
         :map ghostel-semi-char-mode-map
         ("C-s" . consult-line))
  :config
  (add-to-list 'ghostel-eval-cmds
               '("magit-status-setup-buffer" magit-status-setup-buffer)))

(provide 'init-terminal)
