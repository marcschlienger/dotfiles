;;; init-denote.el -*- lexical-binding: t -*-

;; Trial silo. Point this at ~/Notes only once the link interoperability
;; question below has been settled.
(use-package denote
  :ensure t
  :custom
  (denote-directory (expand-file-name "~/denote-test/"))
  (denote-file-type 'markdown-yaml)
  ;; Mirrors the `domain' values already used in the Obsidian vault.
  (denote-known-keywords
   '("teaching" "school-it" "computing" "mathematics" "personal"))
  (denote-infer-keywords t)
  (denote-sort-keywords t)
  (denote-prompts '(title keywords))
  (denote-date-prompt-use-org-read-date nil)
  :bind
  (("C-c n n" . denote)
   ("C-c n o" . denote-open-or-create)
   ("C-c n l" . denote-link)
   ("C-c n b" . denote-backlinks)
   ("C-c n r" . denote-rename-file)
   ("C-c n g" . denote-grep))
  :commands (denote denote-open-or-create denote-link
             denote-backlinks denote-rename-file denote-grep))

;; Surfaces Denote through the consult/vertico/embark stack configured in
;; init-completion.el rather than adding a parallel set of commands.
;; No `:after' here.  It would hold the two bindings back until consult and
;; denote had both been loaded by some other route -- which makes them
;; useless as the way in, since pressing the key is meant to be what loads
;; Denote.  consult-denote.el requires consult and denote itself, so :bind
;; can autoload it directly, exactly as the denote bindings above do.
(use-package consult-denote
  :ensure t
  :bind
  (("C-c n f" . consult-denote-find)
   ("C-c n s" . consult-denote-grep))
  :config
  (consult-denote-mode 1))

;; Converts between Denote's link syntax and plain Markdown links. This is the
;; package that decides whether one directory can be shared with Obsidian.
;; Inspect the `denote-markdown-' command prefix before relying on it.
(use-package denote-markdown
  :ensure t
  :after denote)

(provide 'init-denote)
