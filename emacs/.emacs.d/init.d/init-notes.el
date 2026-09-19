;;; init-notes.el -*- lexical-binding: t -*-

(require 'ucs-normalize)

(defvar markdown-enable-wiki-links)
(defvar markdown-wiki-link-alias-first)
(defvar markdown-wiki-link-search-type)

(defvar ms/notes-directory (expand-file-name "~/Notes/")
  "Root of the notes vault.")

(defconst ms/notes-folders
  '(("teaching"  . "20_school/teaching")
    ("ipad-team" . "20_school/ipad-team")
    ("personal"  . "30_personal")
    ("research"  . "40_research")
    ("computing" . "50_computing"))
  "Domain value and the folder its living notes live in.")

(defun ms/notes-file-p ()
  "Return non-nil when the current buffer visits a file inside the vault."
  (and buffer-file-name
       (file-in-directory-p buffer-file-name ms/notes-directory)))

(defun ms/notes-markdown-setup ()
  "Resolve [[target|alias]] wiki links anywhere in the vault."
  (when (ms/notes-file-p)
    (setq-local markdown-enable-wiki-links t
                markdown-wiki-link-alias-first nil
                markdown-wiki-link-search-type '(project))))

(add-hook 'markdown-mode-hook #'ms/notes-markdown-setup)

(defun ms/notes-slug (title)
  "Turn TITLE into the vault's filename description: lowercase ASCII kebab case.
German umlauts and ß are transliterated; other accents are dropped from their
letter, so é becomes e."
  (let ((s (downcase title)))
    (dolist (pair '(("ä" . "ae") ("ö" . "oe") ("ü" . "ue") ("ß" . "ss")))
      (setq s (string-replace (car pair) (cdr pair) s)))
    (setq s (seq-remove (lambda (c) (eq (get-char-code-property c 'general-category) 'Mn))
                        (ucs-normalize-NFD-string s)))
    (setq s (replace-regexp-in-string "[^a-z0-9]+" "-" (apply #'string s)))
    (replace-regexp-in-string "\\`-+\\|-+\\'" "" s)))

(defun ms/notes-new (title domain type)
  "Create a note TITLE of TYPE in DOMAIN, named and filed by the vault's rules.
Meetings go to the journal as YYYY-MM-DD_mem_description; every other type
goes to the domain's folder as description."
  (interactive
   (list (read-string "Title: ")
         (completing-read "Domain: " (mapcar #'car ms/notes-folders) nil t)
         (completing-read "Type (default note): "
                          '("note" "reference" "literature" "moc" "project" "meeting")
                          nil t nil nil "note")))
  (let* ((today (format-time-string "%F"))
         (slug (ms/notes-slug title))
         (file (if (string= type "meeting")
                   (expand-file-name (format "70_journal/%s/%s_mem_%s.md"
                                             (substring today 0 4) today slug)
                                     ms/notes-directory)
                 (expand-file-name (concat slug ".md")
                                   (expand-file-name (cdr (assoc domain ms/notes-folders))
                                                     ms/notes-directory)))))
    (when (string-empty-p slug) (user-error "Title has no usable characters"))
    (when (file-exists-p file) (user-error "Already exists: %s" file))
    (make-directory (file-name-directory file) t)
    (find-file file)
    (insert (format "---\ntype: %s\ndomain: %s\ncreated: %s\nlang: de\n---\n\n# %s\n\n"
                    type domain today title))))

(defun ms/notes-today ()
  "Open today's daily note, creating it from the vault's daily template.
The template's {{date}} and {{title}} placeholders become today's date."
  (interactive)
  (let* ((today (format-time-string "%F"))
         (template (expand-file-name "99_meta/templates/daily.md" ms/notes-directory))
         (file (expand-file-name (format "70_journal/%s/%s.md" (substring today 0 4) today)
                                 ms/notes-directory)))
    (unless (or (file-exists-p file) (file-readable-p template))
      (user-error "Daily template not found: %s" template))
    (make-directory (file-name-directory file) t)
    (find-file file)
    (when (= (buffer-size) 0)
      (insert-file-contents template)
      (goto-char (point-min))
      (while (re-search-forward "{{\\(date\\|title\\)}}" nil t)
        (replace-match today t t)))))

(provide 'init-notes)
