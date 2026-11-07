;;; init-notes.el -*- lexical-binding: t -*-

(require 'lib-paths)

(use-package denote
  :ensure t
  :bind (("C-c n n" . denote)
         ("C-c n l" . denote-link)
         ("C-c n b" . denote-backlinks)
         ("C-c n r" . denote-rename-file)
         ("C-c n d" . denote-sort-dired))
  :hook (dired-mode . denote-dired-mode)
  :custom
  (denote-directory ms-paths-notes-directory)
  (denote-file-type 'org)
  (denote-known-keywords '("reference" "exercise" "worksheet" "lesson"
                           "meeting" "project" "clip" "teaching" "school"
                           "ipad" "personal" "computing" "research" "emacs"
                           "math" "physics"))
  (denote-infer-keywords t)
  (denote-sort-keywords t)
  ;; Backdating a note through the Org date prompt rather than typing an
  ;; identifier by hand; the prompt accepts "-1d" and the like.
  (denote-date-prompt-use-org-read-date t)
  :config
  ;; A buffer named after the identifier tells me nothing in the buffer
  ;; list; this names it after the title.  It is a mode, so it is called
  ;; here rather than set as a variable.
  (denote-rename-buffer-mode 1))

;; Search and find restricted to the notes, with Consult's preview.
(use-package consult-denote
  :ensure t
  :bind (("C-c n f" . consult-denote-find)
         ("C-c n g" . consult-denote-grep))
  :config
  (consult-denote-mode 1))

(provide 'init-notes)
