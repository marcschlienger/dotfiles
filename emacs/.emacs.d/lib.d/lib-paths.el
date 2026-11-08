;;; lib-paths.el -*- lexical-binding: t -*-

(defconst ms-paths-cache-directory
  (expand-file-name
   "emacs/"
   (or (getenv "XDG_CACHE_HOME")
       (if (eq system-type 'darwin)
           (expand-file-name "~/Library/Caches/")
         (expand-file-name "~/.cache/"))))
  "Directory for Emacs state that is disposable and machine-local.")

(defun ms-paths-cache-file (name)
  "Return NAME inside `ms-paths-cache-directory', creating the directory."
  (make-directory ms-paths-cache-directory t)
  (expand-file-name name ms-paths-cache-directory))

(defconst ms-paths-notes-directory
  (if (eq system-type 'darwin)
      (expand-file-name
       "Notes/" "~/Library/Mobile Documents/com~apple~CloudDocs/")
    (expand-file-name "~/Notes/"))
  "Directory holding the notes, named by the Denote convention.
WORKFLOW.md describes how the notes reach each machine.")

(provide 'lib-paths)
