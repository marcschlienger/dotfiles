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
  "Directory holding the notes: Org files named by the Denote convention.
On macOS this is iCloud Drive, which the phone and tablet can reach.  There
is no iCloud client for other systems, so they fall back to a plain home
directory and need their own way of getting the files there.")

(provide 'lib-paths)
