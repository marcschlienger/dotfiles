;;; init-notes.el -*- lexical-binding: t -*-

(require 'lib-paths)

(use-package denote
  :ensure t
  :bind (("C-c n n" . denote)
         ;; `denote' takes the file type from `denote-file-type'; this one
         ;; asks.  The directory holds both extensions quite happily --
         ;; `denote-filetype-heuristics' reads each file's type from its
         ;; name, and links resolve by identifier either way -- so the
         ;; format is a per-note decision: Org where a note runs code or
         ;; assembles a worksheet, Markdown where it is read on a phone.
         ("C-c n t" . denote-type)
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
  ;; Offered by `denote-template', which asks for one before creating the
  ;; note.  An exercise keeps its solution under a tagged heading, so a
  ;; worksheet that includes it can leave the solution out with
  ;; #+exclude_tags; the worksheet entry is the header such a file needs.
  (denote-templates
   `((exercise . "* Exercise\n\n* Solution :solution:\n")
     (worksheet
      . ,(concat "#+options: toc:nil num:t\n"
                 "#+latex_class: article\n"
                 "#+latex_header: \\usepackage{amsmath,amssymb,siunitx}\n"
                 "#+latex_header: \\usepackage[margin=2cm]{geometry}\n"
                 "#+exclude_tags: solution\n"))))
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
  :init
  ;; The mode is what gives Denote's own prompts -- the link target, the
  ;; file to rename -- Consult's preview.  In :config it would run only
  ;; once one of the two commands above had loaded this package, and
  ;; `C-c n l' would prompt differently depending on whether `C-c n f' had
  ;; been used earlier in the session.  Tied to Denote loading it is on
  ;; from the first prompt; the mode is autoloaded, so calling it is what
  ;; loads this package.
  (with-eval-after-load 'denote
    (consult-denote-mode 1)))

;; The Org-specific commands Denote keeps in a package of their own.
;; `denote-org-extract-org-subtree' moves the heading at point into a note
;; of its own -- title, tags and date taken from the heading -- which is how
;; an entry leaves inbox.org.  The dynamic blocks list links and backlinks
;; inside a note.  Every command is autoloaded, so nothing loads until one
;; is called.
(use-package denote-org
  :ensure t
  :defer t)

;; `org-web-tools-read-url-as-org' fetches a page and shows it as Org,
;; converted by Pandoc, for a page worth reading here before deciding
;; whether it becomes a note.
(use-package org-web-tools
  :ensure t
  :defer t)

(provide 'init-notes)
