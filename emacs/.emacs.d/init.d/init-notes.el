;;; init-notes.el -*- lexical-binding: t -*-

(require 'lib-notes)

(defvar markdown-enable-wiki-links)
(defvar markdown-wiki-link-alias-first)
(defvar markdown-wiki-link-search-type)

(defun ms/notes-markdown-setup ()
  "Resolve [[target|alias]] wiki links anywhere in the vault."
  (when (ms-notes-file-p)
    (setq-local markdown-enable-wiki-links t
                markdown-wiki-link-alias-first nil
                markdown-wiki-link-search-type '(project))))

(add-hook 'markdown-mode-hook #'ms/notes-markdown-setup)

(provide 'init-notes)
