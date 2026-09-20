;;; lib-notes.el -*- lexical-binding: t -*-

(require 'ucs-normalize)

(defvar ms-notes-directory (expand-file-name "~/Notes/")
  "Root of the notes vault.")

(defconst ms-notes-folders
  '(("teaching"  . "20_school/teaching")
    ("ipad-team" . "20_school/ipad-team")
    ("personal"  . "30_personal")
    ("research"  . "40_research")
    ("computing" . "50_computing"))
  "Domain value and the folder its living notes live in.")

(defun ms-notes-file-p ()
  "Return non-nil when the current buffer visits a file inside the vault."
  (and buffer-file-name
       (file-in-directory-p buffer-file-name ms-notes-directory)))

(defun ms-notes-slug (title)
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

(defun ms-notes-new (title domain type)
  "Create a note TITLE of TYPE in DOMAIN, named and filed by the vault's rules.
Meetings go to the journal as YYYY-MM-DD_mem_description; every other type
goes to the domain's folder as description."
  (interactive
   (list (read-string "Title: ")
         (completing-read "Domain: " (mapcar #'car ms-notes-folders) nil t)
         (completing-read "Type (default note): "
                          '("note" "reference" "literature" "moc" "project" "meeting")
                          nil t nil nil "note")))
  (let* ((today (format-time-string "%F"))
         (slug (ms-notes-slug title))
         (file (if (string= type "meeting")
                   (expand-file-name (format "70_journal/%s/%s_mem_%s.md"
                                             (substring today 0 4) today slug)
                                     ms-notes-directory)
                 (expand-file-name (concat slug ".md")
                                   (expand-file-name (cdr (assoc domain ms-notes-folders))
                                                     ms-notes-directory)))))
    (when (string-empty-p slug) (user-error "Title has no usable characters"))
    (when (file-exists-p file) (user-error "Already exists: %s" file))
    (make-directory (file-name-directory file) t)
    (find-file file)
    (insert (format "---\ntype: %s\ndomain: %s\ncreated: %s\nlang: de\n---\n\n# %s\n\n"
                    type domain today title))))

(defun ms-notes-today ()
  "Open today's daily note, creating it from the vault's daily template.
The template's {{date}} and {{title}} placeholders become today's date."
  (interactive)
  (let* ((today (format-time-string "%F"))
         (template (expand-file-name "99_meta/templates/daily.md" ms-notes-directory))
         (file (expand-file-name (format "70_journal/%s/%s.md" (substring today 0 4) today)
                                 ms-notes-directory)))
    (unless (or (file-exists-p file) (file-readable-p template))
      (user-error "Daily template not found: %s" template))
    (make-directory (file-name-directory file) t)
    (find-file file)
    (when (= (buffer-size) 0)
      (insert-file-contents template)
      (goto-char (point-min))
      (while (re-search-forward "{{\\(date\\|title\\)}}" nil t)
        (replace-match today t t)))))

(defun ms-notes--front-matter-bounds ()
  "Return (BEG . END) of the current buffer's YAML front matter, or nil."
  (save-excursion
    (goto-char (point-min))
    (when (looking-at "---[ \t]*\n")
      (let ((beg (match-end 0)))
        (goto-char beg)
        (when (re-search-forward "^---[ \t]*$" nil t)
          (cons beg (match-beginning 0)))))))

(defun ms-notes--front-matter-get (key)
  "Return the non-empty value of KEY in the front matter, or nil."
  (let ((bounds (ms-notes--front-matter-bounds)))
    (when bounds
      (save-excursion
        (goto-char (car bounds))
        (when (re-search-forward (format "^%s:[ \t]*\\(.*?\\)[ \t]*$" (regexp-quote key))
                                 (cdr bounds) t)
          (let ((value (string-trim (match-string-no-properties 1) "[\"']" "[\"']")))
            (unless (string-empty-p value) value)))))))

(defun ms-notes--front-matter-set (key value)
  "Set KEY to VALUE in the front matter, adding the key if it is missing."
  (let ((bounds (or (ms-notes--front-matter-bounds)
                    (user-error "This note has no front matter"))))
    (save-excursion
      (goto-char (car bounds))
      (if (re-search-forward (format "^%s:.*$" (regexp-quote key)) (cdr bounds) t)
          (replace-match (format "%s: %s" key value) t t)
        (goto-char (cdr bounds))
        (insert (format "%s: %s\n" key value))))))

(defun ms-notes--heading ()
  "Return the text of the first level-one heading after the front matter, or nil."
  (save-excursion
    (goto-char (or (cdr (ms-notes--front-matter-bounds)) (point-min)))
    (when (re-search-forward "^# \\(.+\\)$" nil t)
      (string-trim (match-string-no-properties 1)))))

(defun ms-notes--default-title ()
  "Return the note's title: its heading, else its filename unless a timestamp."
  (or (ms-notes--heading)
      (let ((stem (file-name-base buffer-file-name)))
        (unless (string-match-p "\\`[0-9]+\\'" stem) stem))))

(defun ms-notes--linked-from (stem)
  "Return the vault files, other than the current one, containing a link to STEM."
  (let ((link (concat "[[" stem)) (hits nil))
    (dolist (file (directory-files-recursively ms-notes-directory "\\.md\\'") hits)
      (unless (file-equal-p file buffer-file-name)
        (with-temp-buffer
          (insert-file-contents file)
          (goto-char (point-min))
          (while (and (search-forward link nil t)
                      (not (member file hits)))
            (when (memq (char-after) '(?\] ?| ?#))
              (push file hits))))))))

(defun ms-notes-file (title domain)
  "File the current note under TITLE in the folder of DOMAIN.
A meeting goes to the journal as YYYY-MM-DD_mem_description, dated by its
created: value; every other note goes to the domain folder as description.
Refuses when another note links to this one, because the rename would break
that link; rename such a note in an editor that rewrites links instead."
  (interactive
   (progn
     (unless (and buffer-file-name
                  (file-in-directory-p buffer-file-name ms-notes-directory))
       (user-error "Not a note in %s" ms-notes-directory))
     (let ((heading (ms-notes--default-title)))
       (list (read-string (format-prompt "Title" heading) nil nil heading)
             (or (ms-notes--front-matter-get "domain")
                 (completing-read "Domain: " (mapcar #'car ms-notes-folders) nil t))))))
  (let* ((type (or (ms-notes--front-matter-get "type") "note"))
         (created (or (ms-notes--front-matter-get "created") (format-time-string "%F")))
         (folder (cdr (assoc domain ms-notes-folders)))
         (slug (ms-notes-slug (or title "")))
         (old buffer-file-name)
         (stem (file-name-base old))
         (new (cond ((member type '("clipping" "log"))
                     (user-error "A %s is named when it is captured, not filed" type))
                    ((null folder) (user-error "Unknown domain: %s" domain))
                    ((string-empty-p slug) (user-error "Title has no usable characters"))
                    ((string= type "meeting")
                     (expand-file-name (format "70_journal/%s/%s_mem_%s.md"
                                               (substring created 0 4) created slug)
                                       ms-notes-directory))
                    (t (expand-file-name (concat slug ".md")
                                         (expand-file-name folder ms-notes-directory)))))
         (linked (ms-notes--linked-from stem)))
    (when (file-equal-p old new) (user-error "Already filed as %s" (file-name-nondirectory new)))
    (when (file-exists-p new) (user-error "Already exists: %s" new))
    (when linked
      (user-error "%d note(s) link to [[%s]], e.g. %s; rename it in Obsidian instead"
                  (length linked) stem (file-relative-name (car linked) ms-notes-directory)))
    (unless (ms-notes--front-matter-get "domain")
      (ms-notes--front-matter-set "domain" domain))
    (unless (ms-notes--heading)
      (goto-char (or (cdr (ms-notes--front-matter-bounds)) (point-min)))
      (forward-line 1)
      (insert (format "\n# %s\n" title))
      (unless (looking-at "\n") (insert "\n")))
    (save-buffer)
    (make-directory (file-name-directory new) t)
    (if (vc-backend old)
        (vc-rename-file old new)
      (rename-file old new)
      (set-visited-file-name new t t))
    (message "Filed as %s" (file-relative-name new ms-notes-directory))))

(provide 'lib-notes)
