;;; init-terminal.el -*- lexical-binding: t -*-

(use-package ghostel
  :ensure t
  :commands ghostel
  :bind (:map ghostel-semi-char-mode-map
              ("C-s" . consult-line))
  :config
  (add-to-list 'ghostel-eval-cmds
               '("magit-status-setup-buffer" magit-status-setup-buffer)))

(provide 'init-terminal)
