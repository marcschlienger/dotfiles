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

(provide 'lib-paths)
