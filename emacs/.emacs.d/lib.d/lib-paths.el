;;; lib-paths.el -*- lexical-binding: t -*-

(defconst ms-cache-directory
  (expand-file-name
   "emacs/"
   (or (getenv "XDG_CACHE_HOME")
       (if (eq system-type 'darwin)
           (expand-file-name "~/Library/Caches/")
         (expand-file-name "~/.cache/"))))
  "Directory for Emacs state that is disposable and machine-local.")

(defun ms-cache-file (name)
  "Return NAME inside `ms-cache-directory', creating the directory."
  (make-directory ms-cache-directory t)
  (expand-file-name name ms-cache-directory))

(provide 'lib-paths)
