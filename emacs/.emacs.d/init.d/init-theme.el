;;; init-theme.el -*- lexical-binding: t -*-

;;; Choose installed fonts separately for each graphical frame.  This also
;;; handles frames created later by an Emacs daemon.
(defconst ms/fixed-pitch-font-height
  (if (eq system-type 'darwin) 160 140)
  "Default and fixed-pitch font height in tenths of a point.")

(defconst ms/variable-pitch-font-height
  (if (eq system-type 'darwin) 180 160)
  "Variable-pitch font height in tenths of a point.")

(defconst ms/fixed-pitch-font-candidates
  (if (eq system-type 'darwin)
      '("FiraCode Nerd Font" "Fira Code" "Menlo" "Monaco")
    '("FiraCode Nerd Font" "Fira Code" "DejaVu Sans Mono" "Liberation Mono"))
  "Preferred fixed-pitch font families for the current platform.")

(defconst ms/variable-pitch-font-candidates
  (if (eq system-type 'darwin)
      '("Linux Libertine O" "Linux Libertine" "Avenir Next" "Helvetica Neue" "Arial")
    '("Linux Libertine O" "Linux Libertine" "Noto Serif" "Liberation Serif" "DejaVu Serif"))
  "Preferred variable-pitch font families for the current platform.")

(defun ms/first-available-font-family (families frame)
  "Return the first installed member of FAMILIES for FRAME."
  (seq-find (lambda (family)
              (find-font (font-spec :family family) frame))
            families))

(defun ms/configure-frame-fonts (frame)
  "Apply preferred installed fonts to graphical FRAME."
  (when (display-graphic-p frame)
    (let ((fixed-family
           (ms/first-available-font-family
            ms/fixed-pitch-font-candidates frame))
          (variable-family
           (ms/first-available-font-family
            ms/variable-pitch-font-candidates frame)))
      (set-face-attribute 'default frame
                          :height ms/fixed-pitch-font-height
                          :weight 'regular)
      (set-face-attribute 'fixed-pitch frame
                          :height ms/fixed-pitch-font-height
                          :weight 'regular)
      (set-face-attribute 'variable-pitch frame
                          :height ms/variable-pitch-font-height
                          :weight 'regular)
      (when fixed-family
        (set-face-attribute 'default frame :family fixed-family)
        (set-face-attribute 'fixed-pitch frame :family fixed-family))
      (when variable-family
        (set-face-attribute 'variable-pitch frame :family variable-family)))))

(add-hook 'after-make-frame-functions #'ms/configure-frame-fonts)
(ms/configure-frame-fonts (selected-frame))

;;; Fontaine (font configurations)
;(use-package fontaine
;  :ensure t
;  :hook
;  ;; Persist the latest font preset when closing/starting Emacs.
;  ((after-init . fontaine-mode)
;   (after-init . (lambda ()
;                   ;; Set last preset or fall back to desired style from `fontaine-presets'.
;                   (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular)))))
;  :bind
;  (("C-c f" . fontaine-set-preset)
;   ("C-c F" . fontaine-toggle-preset))
;  :config
;  (setq-default text-scale-remap-header-line t)
;  (setq fontaine-presets
;        '((small
;           :default-height 80)
;          (regular)
;          (medium
;           :default-weight semilight
;           :default-height 115
;           :bold-weight extrabold)
;          (large
;           :inherit medium
;           :default-height 150)
;          (jumbo
;           :default-height 260)
;          (t
;           :default-family "FiraCode Nerd Font"
;           :default-weight regular
;           :default-slant normal
;           :default-width normal
;           :default-height 130
;
;           :fixed-pitch-family "FiraCode Nerd Font"
;           :fixed-pitch-weight nil
;           :fixed-pitch-slant nil
;           :fixed-pitch-width nil
;           :fixed-pitch-height 1.0
;
;           :variable-pitch-family "Linux Libertine O"
;           :variable-pitch-weight nil
;           :variable-pitch-slant nil
;           :variable-pitch-width nil
;           :variable-pitch-height 1.5
;
;           :bold-fmily nil
;           :bold-slant nil
;           :bold-weight bold
;           :bold-width nil
;           :bold-height 1.0
;
;           :italic-family nil
;           :italic-weight nil
;           :italic-slant italic
;           :italic-width nil
;           :italic-height 1.0
;
;           :line-spacing nil))))

;;; `variable-pitch-mode' setup
(use-package face-remap
  :ensure nil
  :functions ms/enable-variable-pitch-mode
  :bind ( :map ctl-x-x-map
          ("v" . variable-pitch-mode))
  :hook ((text-mode notmuch-show-mode elfeed-show-mode) . ms/enable-variable-pitch-mode)
  :config
  (defun ms/enable-variable-pitch-mode ()
    (unless (derived-mode-p 'mhtml-mode 'nxml-mode 'yaml-mode)
      (variable-pitch-mode 1))))

;; Theme packages.  Ef inherits the comprehensive Modus theme machinery.
(use-package modus-themes
  :ensure t
  :demand t
  :init
  (setq modus-themes-to-toggle '(modus-operandi-tinted modus-vivendi-tinted)
        ;modus-themes-mode-line '(accented borderless)
        ;modus-themes-mode-line '(accented)
        modus-themes-bold-constructs t
        modus-themes-italic-constructs t
        modus-themes-mixed-fonts t)
  (setq modus-themes-headings
        '((0 . (variable-pitch light 1.4))
          (1 . (variable-pitch light 1.3))
          (2 . (variable-pitch regular 1.25))
          (3 . (variable-pitch regular 1.2))
          (4 . (variable-pitch regular 1.15))
          (5 . (variable-pitch 1.1))
          (agenda-date . (semilight 1.2))
          (agenda-structure . (variable-pitch light 1.3))
          (t . (variable-pitch 1.1))))
  (setq modus-themes-common-palette-overrides
        '((fg-heading-1 blue-warmer)
          (bg-heading-1 bg-blue-nuanced)
          (fg-heading-2 yellow-cooler)
          (bg-heading-2 bg-yellow-nuanced)
          (fg-heading-3 green-cooler)
          (bg-heading-3 bg-green-nuanced)
          (fg-heading-4 cyan-cooler)
          (bg-heading-4 bg-cyan-nuanced)
          (prose-done green-faint)
          (prose-todo red-faint)
          ;(bg-mode-line-active bg-sage)
          ;(fg-mode-line-active fg-main)
          ;(border-mode-line-active bg-green-intense)
          ;(bg-mode-line-active bg-blue-intense)
          ;(fg-mode-line-active fg-main)
          ;(border-mode-line-active blue-intense)
          (bg-mode-line-active bg-lavender)
          (fg-mode-line-active fg-main)
          (border-mode-line-active bg-magenta-intense))))

(use-package ef-themes
  :ensure t
  :demand t)

;; Bozhidar Batsov's Catppuccin port provides one real Emacs theme per flavour,
;; which means it works correctly with Circadian and standard theme commands.
(use-package batppuccin
  :ensure t
  :demand t
  :init
  (setq batppuccin-flat-mode-line t
        batppuccin-use-variable-pitch t))

(use-package solarized-theme
  :ensure t
  :demand t)

(require 'subr-x)

(defconst ms/theme-families
  '((ef-maris
     :label "Ef Maris"
     :light ef-maris-light
     :dark ef-maris-dark)
    (modus-tinted
     :label "Modus Tinted"
     :light modus-operandi-tinted
     :dark modus-vivendi-tinted)
    (catppuccin
     :label "Catppuccin"
     :light batppuccin-latte
     :dark batppuccin-macchiato)
    (solarized
     :label "Solarized"
     :light solarized-light
     :dark solarized-dark))
  "Theme families available to Emacs.")

(defconst ms/theme-family-state-file
  (expand-file-name
   "dotfiles/emacs-theme-family"
   (or (getenv "XDG_STATE_HOME")
       (expand-file-name ".local/state" "~")))
  "File containing the Emacs theme family selected on this machine.")

(defun ms/theme-family--entry (family)
  "Return the configuration entry for FAMILY."
  (or (assq family ms/theme-families)
      (error "Unknown theme family: %s" family)))

(defun ms/theme-family--property (family property)
  "Return PROPERTY from the configuration for FAMILY."
  (plist-get (cdr (ms/theme-family--entry family)) property))

(defun ms/theme-family--read-state ()
  "Read and validate the locally selected theme family."
  (condition-case error-data
      (when (file-readable-p ms/theme-family-state-file)
        (let* ((name
                (with-temp-buffer
                  (insert-file-contents ms/theme-family-state-file)
                  (string-trim (buffer-string))))
               (family (and (not (string-empty-p name)) (intern name))))
          (if (assq family ms/theme-families)
              family
            (display-warning
             'theme
             (format "Ignoring invalid theme family in %s: %S"
                     ms/theme-family-state-file name)
             :warning)
            nil)))
    (file-error
     (display-warning
      'theme
      (format "Could not read theme family state %s: %s"
              ms/theme-family-state-file
              (error-message-string error-data))
      :warning)
     nil)))

(defvar ms/theme-family
  (or (ms/theme-family--read-state) 'ef-maris)
  "The theme family used for automatic light and dark switching.")

(defun ms/theme-family--pair (&optional family)
  "Return the light and dark themes for FAMILY.
Use `ms/theme-family' when FAMILY is nil."
  (let ((family (or family ms/theme-family)))
    (list (ms/theme-family--property family :light)
          (ms/theme-family--property family :dark))))

(defun ms/theme-family--appearance (theme)
  "Return the light or dark appearance associated with THEME."
  (cond
   ((memq theme
          (mapcar (lambda (entry) (plist-get (cdr entry) :light))
                  ms/theme-families))
    'light)
   ((memq theme
          (mapcar (lambda (entry) (plist-get (cdr entry) :dark))
                  ms/theme-families))
    'dark)))

(defun ms/theme-family--write-state ()
  "Persist `ms/theme-family' outside the dotfiles repository."
  (condition-case error-data
      (progn
        (make-directory (file-name-directory ms/theme-family-state-file) t)
        (with-temp-file ms/theme-family-state-file
          (insert (symbol-name ms/theme-family) "\n"))
        t)
    (file-error
     (display-warning
      'theme
      (format "Could not persist theme family to %s: %s"
              ms/theme-family-state-file
              (error-message-string error-data))
      :warning)
     nil)))

(defun ms/theme-family--ensure-available (family)
  "Signal a user error unless both themes for FAMILY are installed."
  (dolist (theme (ms/theme-family--pair family))
    (unless (memq theme (custom-available-themes))
      (user-error "Theme %s is unavailable; install or update its package"
                  theme))))

(defun ms/theme-family--configure-circadian ()
  "Configure Circadian for the selected theme family."
  (pcase-let ((`(,light ,dark) (ms/theme-family--pair)))
    (setq circadian-themes `((:sunrise . ,light)
                             (:sunset  . ,dark)))))

(defun ms/theme-update-macos-appearance (theme)
  "Keep native macOS frame chrome consistent with THEME."
  (when (eq system-type 'darwin)
    (when-let ((appearance (ms/theme-family--appearance theme)))
      (setf (alist-get 'ns-appearance default-frame-alist) appearance)
      (dolist (frame (frame-list))
        (when (with-selected-frame frame (eq window-system 'ns))
          (set-frame-parameter frame 'ns-appearance appearance))))))

(add-hook 'enable-theme-functions #'ms/theme-update-macos-appearance)

(defun ms/theme-pair-toggle ()
  "Toggle between the light and dark themes in the selected family.
The next sunrise or sunset event restores automatic switching."
  (interactive)
  (pcase-let ((`(,light ,dark) (ms/theme-family--pair)))
    (let ((theme (if (custom-theme-enabled-p light) dark light)))
      (unless (memq theme (custom-available-themes))
        (user-error "Theme %s is unavailable; install or update its package"
                    theme))
      (circadian-enable-theme theme))))

(defun ms/theme-family-select (family)
  "Select FAMILY for automatic Emacs theme switching."
  (interactive
   (let* ((choices
           (mapcar
            (lambda (entry)
              (cons (plist-get (cdr entry) :label) (car entry)))
            ms/theme-families))
          (default
           (car (rassoc ms/theme-family choices))))
     (list
      (cdr
       (assoc
        (completing-read "Automatic theme family: "
                         choices nil t nil nil default)
        choices)))))
  (ms/theme-family--ensure-available family)
  (let ((previous-family ms/theme-family))
    (setq ms/theme-family family)
    (ms/theme-family--configure-circadian)
    (condition-case error-data
        (progn
          (circadian-setup)
          ;; A read-only state directory must not prevent the visible switch.
          (ms/theme-family--write-state)
          (message "Automatic theme family: %s"
                   (ms/theme-family--property family :label)))
      (error
       ;; Restore the previous working schedule if the new theme cannot load.
       (setq ms/theme-family previous-family)
       (ms/theme-family--configure-circadian)
       (condition-case nil
           (circadian-setup)
         (error nil))
       (signal (car error-data) (cdr error-data))))))

(global-set-key (kbd "<f5>") #'ms/theme-pair-toggle)
(global-set-key (kbd "C-<f5>") #'ms/theme-family-select)
(global-set-key (kbd "M-<f5>") #'consult-theme)

(use-package solar
  :ensure nil
  :config
  (setq calendar-latitude 48.96
        calendar-longitude 8.58))

(use-package circadian
  :ensure t
  :after solar
  :config
  (ms/theme-family--configure-circadian)
  (circadian-setup))

;; Increase padding of windows and frames.
(use-package spacious-padding
  :ensure t
  :hook (after-init . spacious-padding-mode)
  :bind ("<f8>" . spacious-padding-mode)
  :init
  (setq spacious-padding-widths
        '( :internal-border-width 30
           :header-line-width 4
           :mode-line-width 4
           :tab-width 4
           :right-divider-width 30
           :scroll-bar-width 8
           :left-fringe-width 20
           :right-fringe-width 20)))

;; Rainbow mode for colour previewing.
(use-package rainbow-mode
  :ensure t
  :init
  (setq rainbow-ansi-colors nil)
  (setq rainbow-x-colors nil)
  :hook
  (prog-mode . rainbow-mode))

;;; Rainbow delimiters makes nested delimiters easier to understand.
(use-package rainbow-delimiters
    :ensure t
    :hook ((prog-mode . rainbow-delimiters-mode)))

;;; Modeline settings.
(column-number-mode t)
(setq mode-line-compact nil)

(use-package minions
  :ensure t
  :hook (after-init . minions-mode)
  :custom (minions-mode-line-lighter "--"))

;;; Show the current line number.
(use-package display-line-numbers
  :defer
  :custom
  ; Compute the width of the line numbers based on the actual number of
  ; lines in the file.
  ; TODO Determine whether this will slow down operation especially in large files.
  (display-line-numbers-width-start t)
  (display-line-numbers-type 'relative)
  :hook
  (conf-mode . display-line-numbers-mode)
  (markdown-mode . display-line-numbers-mode)
  (prog-mode . display-line-numbers-mode)
  (sh-mode . display-line-numbers-mode)
  (TeX-mode . display-line-numbers-mode))

;;; Highlight the current line only in the active window and not in the shell.
(use-package emacs
  :custom
  (hl-line-sticky-flag nil)
  (global-hl-line-mode t)
  :hook
  (eshell-mode . (lambda () (hl-line-mode -1)))
  (shell-mode . (lambda () (hl-line-mode -1)))
  (term-mode . (lambda () (hl-line-mode -1))))

;;; Icons
(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-dired
  :ensure t
  :if (or (daemonp) (display-graphic-p))
  :hook
  (dired-mode . nerd-icons-dired-mode))

(provide 'init-theme)
