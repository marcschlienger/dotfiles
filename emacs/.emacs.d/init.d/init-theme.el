;;; init-theme.el -*- lexical-binding: t -*-

;;; Set the font.
(if (eq system-type 'darwin)
  (setq height1 160
        height2 180)
  (setq height1 140
        height2 160))

(set-face-attribute 'default nil
                    :family "FiraCode Nerd Font"
                    :height height1
                    :weight 'regular)

(set-face-attribute 'fixed-pitch nil
                    :family "FiraCode Nerd Font"
                    :height height1
                    :weight 'regular)

(set-face-attribute 'variable-pitch nil
                    :family "Linux Libertine O"
                    :height height2
                    :weight 'regular)

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

;; Set the theme - I use the Modus themes created by Prot.
(use-package modus-themes
  :ensure t
  :demand t
  :bind (("<f5>" . modus-themes-toggle)
         ("C-<f5>" . modus-themes-select)
         ("M-<f5>" . modus-themes-rotate))
  :init
  (setq modus-themes-to-toggle '(modus-operandi-tinted modus-vivendi-tinted)
        ;modus-themes-mode-line '(accented borderless)
        ;modus-themes-mode-line '(accented)
        modus-themes-bold-constructs t
        modus-themes-italic-constructs t
        modus-themes-mixed-fonts t
        modus-themes-fringes 'subtle
        modus-themes-tabs-accented t
        modus-themes-paren-match '(bold intense)
        modus-themes-prompts '(bold intense)
        modus-themes-completions
              '((matches . (extrabold background intense))
                (selection . (semibold accented intense))
                (popup . (accented)))
        modus-themes-org-blocks 'tinted-background
        modus-themes-scale-headings t
        modus-themes-region '(bg-only no-extend))
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
          (border-mode-line-active bg-magenta-intense)))
  (setq modus-themes-scale-headings t))

(use-package solar
  :config
  (setq calendar-latitude 48.96
        calendar-longitude 8.58))

(use-package circadian
  :ensure t
  :after solar
  :config
  (setq circadian-themes '((:sunrise . modus-operandi-tinted)
                           (:sunset  . modus-vivendi-tinted)))
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
  (prog-mode-hook . rainbow-mode)
  :config
  (rainbow-mode t))

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
  (Shell-script-mode . display-line-numbers-mode)
  (TeX-mode . display-line-numbers-mode))

;;; Highlight the current line only in the active window and not in the shell.
(use-package emacs
  :custom
  (hl-line-sticky-flag nil)
  (global-hl-line-mode t)
  :hook
  (eshell-mode . (lambda () (setq-local global-hl-line-mode nil)))
  (shell-mode . (lambda () (hl-line-mode -1)))
  (term-mode . (lambda () (setq-local global-hl-line-mode nil))))

;;; Icons
(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-dired
  :ensure t
  :if (display-graphic-p)
  :hook
  (dired-mode . nerd-icons-dired-mode))

(provide 'init-theme)
