;;; init-dired.el -*- lexical-binding: t -*-

(use-package dired
  :ensure nil
  :commands (dired)
  :config
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq delete-by-moving-to-trash t)
  (let ((gnu-ls (and (eq system-type 'darwin)
                     (executable-find "gls"))))
    (if gnu-ls
        (setq insert-directory-program gnu-ls)
      (when (eq system-type 'darwin)
        (setq dired-use-ls-dired nil)))
    (setq dired-listing-switches
          (if (or gnu-ls (eq system-type 'gnu/linux))
              "-AGFhlv --group-directories-first --time-style=long-iso"
            "-AGFhlv")))
  (setq dired-dwim-target t)
  (let ((opener (if (eq system-type 'darwin)
                    (or (executable-find "open") "open")
                  (or (executable-find "xdg-open") "xdg-open"))))
    (setq dired-guess-shell-alist-user ; suggestions for ! and &
          `(("\\.\\(png\\|jpe?g\\|tiff\\)"
             ,@(delete-dups
                (delq nil (list (executable-find "sxiv") opener))))
            ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)"
             ,@(delete-dups
                (delq nil (list (executable-find "mpv") opener))))
            (".*" ,opener))))
  (setq dired-auto-revert-buffer #'dired-directory-changed-p)
  (setq dired-make-directory-clickable t) ; Emacs 29.1
  (setq dired-free-space nil) ; Emacs 29.1
  (setq dired-mouse-drag-files t) ; Emacs 29.1
  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  (add-hook 'dired-mode-hook #'hl-line-mode))

(use-package dired-aux
  :ensure nil
  :after dired
  :bind (:map dired-mode-map
	      ("C-+" . dired-create-empty-file))
  :config
  (setq dired-isearch-filenames 'dwim)
  (setq dired-create-destination-dirs 'ask)
  (setq dired-vc-rename-file t)
  (setq dired-do-revert-buffer (lambda (dir) (not (file-remote-p dir)))))

;(use-package emacs
 ; :ensure nil
  ;:config
;  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
;  (file-name-shadow-mode t))

(use-package dired-x
  :ensure nil
  :after dired
  :bind (:map dired-mode-map
	      ("I" . dired-do-info))
  :config
  (setq dired-clean-up-buffers-too t)
  (setq dired-clean-confirm-killing-deleted-buffers t))

(use-package dired-subtree
  :ensure t
  :after dired
  :bind (:map dired-mode-map
	      ("<tab>" . dired-subtree-toggle)
	      ("<backtab>" . dired-subtree-remove))
  :config
  (setq dired-subtree-use-backgrounds nil))

(defun ms/dired-preview-setup ()
  "Bind the Dired preview toggle after the local keymap is active."
  (keymap-local-set "V" #'dired-preview-mode))

(use-package dired-preview
  :ensure t
  :commands dired-preview-mode
  :hook (dired-mode . ms/dired-preview-setup)
  :custom
  (dired-preview-delay 0.5)
  (dired-preview-max-size (* 10 1024 1024))
  (dired-preview-ignored-extensions-regexp
   (rx "." (or "gz" "zst" "tar" "xz" "rar" "zip"
               "iso" "dmg" "epub")
       string-end)))

(with-eval-after-load 'dired
  (keymap-set dired-mode-map "V" #'dired-preview-mode))

(use-package wdired
  :ensure nil
  :config
  (setq wdired-allow-to-change-permissions t)
  (setq wdired-create-parent-directories t))

(use-package image-dired
  :ensure nil
  :bind (:map image-dired-thumbnail-mode-map
	      ("<return>" . image-dired-thumbnail-display-external))
  :config
  (setq image-dired-external-viewer
        (if (eq system-type 'darwin)
            (or (executable-find "open") "open")
          (or (executable-find "xdg-open") "xdg-open")))
  (setq image-dired-thumb-size 80)
  (setq image-dired-thumb-relief 0)
  (setq image-dired-thumbs-per-row 4))

;; Dired-like mode for the system trash can
(use-package trashed
  :ensure t
  :init
  (setq trashed-action-confirmer 'y-or-n-p)
  (setq trashed-sort-key '("Date deleted" . t))
  (setq trashed-date-format "%Y-%m-%d %H:%M:%S"))

;; Ibuffer is a dired-like advanced replacement for BufferMenu
(use-package ibuffer
  :ensure t
  :init
  (setq ibuffer-expert t)
  (setq ibuffer-display-summary nil)
  (setq ibuffer-use-other-window nil)
  (setq ibuffer-show-empty-filter-groups nil)
  (setq ibuffer-movement-cycle nil)
  (setq ibuffer-default-sorting-mode 'filename/process)
  (setq ibuffer-formats
        '((mark modified read-only locked " "
                (name 40 40 :left :elide)
                " "
                (size 9 -1 :right)
                " "
                (mode 16 16 :left :elide)
                " " filename-and-process)
          (mark " "
                (name 16 -1)
                " " filename)))
  (setq ibuffer-saved-filter-groups nil)
  (setq ibuffer-old-time 48)
  (add-hook 'ibuffer-mode-hook #'hl-line-mode)
  :bind (:map global-map
	      ("C-x C-b" . ibuffer))
  :bind (:map ibuffer-mode-map
	      ("* f" . ibuffer-mark-by-file-name-regexp)
	      ("* g" . ibuffer-mark-by-content-regexp) ; "g" is for "grep"
	      ("* n" . ibuffer-mark-by-name-regexp)
	      ("s n" . ibuffer-do-sort-by-alphabetic)  ; "sort name" mnemonic
	      ("/ g" . ibuffer-filter-by-content)))

;; Hide dotfiles.
(use-package dired
  :hook ((dired-mode . dired-omit-mode))
  :bind (:map dired-mode-map
          ( "."     . dired-omit-mode))
  :custom (dired-omit-files (rx (seq bol "."))))

(provide 'init-dired)
