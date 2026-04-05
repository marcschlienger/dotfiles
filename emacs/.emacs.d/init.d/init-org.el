;;-*- lexical-binding: t; -*-

;; Calendar
(use-package calendar
  :ensure nil
  :commands (calendar)
  :config
  (setq calendar-mark-diary-entries-flag nil)
  (setq calendar-mark-holidays-flag t)
  (setq calendar-mode-line-format nil)
  (setq calendar-time-display-form
        '( 24-hours ":" minutes
           (when time-zone (format "(%s)" time-zone))))
  (setq calendar-week-start-day 1)
  (setq calendar-date-style 'iso)
  (setq calendar-time-zone-style 'numeric)
  (require 'cal-dst)
  (setq calendar-standard-time-zone-name "+0100")
  (setq calendar-daylight-time-zone-name "+0200"))

;; Appt
(use-package appt
  :ensure nil
  :commands (appt-activate)
  :config
  (setq appt-display-diary nil
        appt-display-format nil
        appt-display-mode-line t
        appt-display-interval 3
        appt-audible nil)
  (with-eval-after-load 'org-agenda
    (appt-activate 1)
    (org-agenda-to-appt)))

;; Org mode
(use-package org
  :ensure nil
  :init
  (setq org-directory (expand-file-name "~/Nextcloud/cloud.schlienger.xyz/org"))
  (setq org-imenu-depth 7)

  (add-to-list 'safe-local-variable-values '(org-hide-leading-stars . t))
  (add-to-list 'safe-local-variable-values '(org-hide-macro-markers . t))
  :bind
  ( :map global-map
    ("C-c l" . org-store-link)
    ("C-c o" . org-open-at-point-global)
    :map org-mode-map
    ;; I don't like that Org binds one zillion keys, so if I want one
    ;; for something more important, I disable it from here.
    ("C-'" . nil)
    ("C-," . nil)
    ("M-;" . nil)
    ("<C-return>" . nil)
    ("<C-S-return>" . nil)
    ("C-M-S-<right>" . nil)
    ("C-M-S-<left>" . nil)
    ("C-c ;" . nil)
    ("C-c M-l" . org-insert-last-stored-link)
    ("C-c C-M-l" . org-toggle-link-display)
    ("M-." . org-edit-special) ; alias for C-c ' (mnenomic is global M-. that goes to source)
    :map org-src-mode-map
    ("M-," . org-edit-src-exit) ; see M-. above
    :map narrow-map
    ("b" . org-narrow-to-block)
    ("e" . org-narrow-to-element)
    ("s" . org-narrow-to-subtree))
  :config
  (setq org-ellipsis " ▾")
  (setq org-adapt-indentation nil)
  (setq org-special-ctrl-a/e nil)
  (setq org-special-ctrl-k nil)
  (setq org-M-RET-may-split-line '((default . nil)))
  (setq org-hide-emphasis-markers t)
  (setq org-hide-macro-markers nil)
  (setq org-hide-leading-stars nil)
  (setq org-cycle-separator-lines 0)
  (setq org-structure-template-alist
        '(("s" . "src")
          ("e" . "src emacs-lisp")
          ("E" . "src emacs-lisp :results value code :lexical t")
          ("t" . "src emacs-lisp :tangle FILENAME")
          ("T" . "src emacs-lisp :tangle FILENAME :mkdirp yes")
          ("x" . "example")
          ("X" . "export")
          ("q" . "quote")))
  (setq org-catch-invisible-edits 'show)
  (setq org-return-follows-link nil)
  (setq org-loop-over-headlines-in-active-region 'start-level)
  (setq org-modules '(ol-info ol-eww))
  (setq org-use-sub-superscripts '{})
  (setq org-insert-heading-respect-content t)
  (setq org-read-date-prefer-future 'time)
  (setq org-highlight-latex-and-related nil) ; other options affect elisp regexp in src blocks
  (setq org-fontify-quote-and-verse-blocks t)
  (setq org-fontify-whole-block-delimiter-line t)
  (setq org-track-ordered-property-with-tag t)
  (setq org-highest-priority ?A)
  (setq org-lowest-priority ?C)
  (setq org-default-priority ?A)
  (setq org-priority-faces nil)
  :hook
  (org-mode . org-indent-mode))

;;; refile, todo
(use-package org
  :ensure nil
  :config
  (setq org-refile-targets
        '(("todo.org" :maxlevel . 1)
          ("someday.org" :maxlevel . 1)))
  (setq org-refile-use-outline-path 'file) ; to be able to refile targets to the top level
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  (setq org-refile-use-cache t)
  (setq org-reverse-note-order nil)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
  (setq org-fontify-done-headline nil)
  (setq org-fontify-todo-headline nil)
  (setq org-fontify-whole-heading-line nil)
  (setq org-enforce-todo-dependencies t)
  (setq org-enforce-todo-checkbox-dependencies t))

;;; tags
(use-package org
  :ensure nil
  :config
  (setq org-tag-alist
        '((sequence "home(h)" "school(w)" "@computer(c)" "@phone(p)")))
  (setq org-auto-align-tags nil)
  (setq org-tags-column 0))

;;; log
(use-package org
  :ensure nil
  :config
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-log-note-clock-out nil)
  (setq org-log-redeadline 'time)
  (setq org-log-reschedule 'time))

;;; links
(use-package org
  :ensure nil
  :config
  (setq org-link-context-for-files t)
  (setq org-link-keep-stored-after-insertion nil)
  (setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id))

;;; code blocks
(use-package org
  :ensure nil
  :config
  (setq org-confirm-babel-evaluate nil)
  (setq org-src-window-setup 'current-window)
  (setq org-edit-src-persistent-message nil)
  (setq org-src-fontify-natively t)
  (setq org-src-preserve-indentation t)
  (setq org-src-tab-acts-natively t)
  (setq org-edit-src-content-indentation 0)
  (setq org-babel-python-command 'python3)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
     (clojure . t)
     (python . t)
     (R . t)
     (shell . t))))

;;; export
(use-package org
  :ensure nil
  :init
  ;; This variable needs to be set before org.el ist loaded.
  (setq org-export-backends '(html latex md odt texinfo))
  :config
  (setq org-export-with-toc t)
  (setq org-export-headline-levels 8)
  (setq org-export-dispatch-use-expert-ui nil)
  (setq org-html-htmlize-output-type nil)
  (setq org-html-head-include-default-style nil)
  (setq org-html-head-include-scripts nil))

;;; capture
(use-package org-capture
  :ensure nil
  :bind ("C-c c" . org-capture)
  :config
  (setq org-capture-templates
        `(("c" "Calendar entry" entry
           (file+headline "inbox.org" "Calendar entries")
           ,(concat "* CAL %^{Description} %^g\n%^T\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
                    "%?")
           :prepend t
           :empty-lines-after 1)
          ("m" "Meeting" entry
           (file+olp "notes.org" "Notes" "Meetings")
           ,(concat "* MEET %^{Description} :meeting:%^g\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n")
           :prepend t
           :clock-in t
           :clock-resume t
           :empty-lines-after 1)
          ("n" "Note" entry
           (file+headline "notes.org" "Notes")
           ,(concat "* %^{Note} %^g\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n")
           :prepend t
           :empty-lines-after 1)
          ("N" "Note with annotation" entry
           (file+headline "notes.org" "Notes")
           ,(concat "* %^{Note} %^g\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
                    "%i\n%a")
           :prepend t
           :empty-lines-after 1)
          ("t" "Task" entry
           (file+headline "inbox.org" "Tasks")
           ,(concat "* TODO %^{Title} %^g\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
                    "%?")
           :prepend t
           :empty-lines-after 1)
          ("T" "Task with annotation" entry
           (file+headline "inbox.org" "Tasks")
           ,(concat "* TODO %^{Title} %^g\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
                    "%i\n%a\n%?")
           :prepend t
           :empty-lines-after 1)
          ("w" "Wishlist" entry
           (file+olp "notes.org" "Notes" "Wishlist")
           ,(concat "* WISH %^{Title} :wish:%^g\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n\n"
                    "%a\n%?")
           :prepend t
           :empty-lines-after 1))))

;;; agenda
(use-package org-agenda
  :ensure nil
  :bind
  ( :map global-map
    ("C-c a" . org-agenda))
  :config
  (setq org-default-notes-file (make-temp-file "emacs-org-notes-")) ; send it to oblivion
  (setq org-agenda-files `(,org-directory))
  (setq org-agenda-span 'week)
  (setq org-agenda-start-on-weekday 1)
  (setq org-agenda-confirm-kill t)
  (setq org-agenda-show-all-dates t)
  (setq org-agenda-show-outline-path nil)
  (setq org-agenda-window-setup 'current-window)
  (setq org-agenda-skip-comment-trees t)
  (setq org-agenda-menu-show-matcher t)
  (setq org-agenda-menu-two-columns nil)
  (setq org-agenda-sticky nil)
  (setq org-agenda-custom-commands-contexts nil)
  (setq org-agenda-custom-commands
        '(("s"
           "List all active projects that have to be done @school"
           tags-todo
           "@school+CATEGORY=\"@school\"/TODO|STARTED")
          ("p"
           "List all active projects"
           tags
           "+LEVEL=2+TODO=\"TODO\"")))
  (setq org-agenda-max-entries nil)
  (setq org-agenda-max-entries nil)
  (setq org-agenda-max-todos nil)
  (setq org-agenda-max-tags nil)
  (setq org-agenda-max-effort nil)

;;;; General agenda view options
  (setq org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-12t% s")
          (todo . " %i %-12:c")
          (tags . " %i %-12:c")
          (search . " %i %-12:c")))
  (setq org-agenda-sorting-strategy
        '(((agenda habit-down time-up priority-down category-keep)
           (todo priority-down category-keep)
           (tags priority-down category-keep)
           (search category-keep))))
  (setq org-agenda-breadcrumbs-separator "->")
  (setq org-agenda-todo-keyword-format "%-1s")
  (setq org-agenda-fontify-priorities 'cookies)
  (setq org-agenda-category-icon-alist nil)
  (setq org-agenda-remove-times-when-in-prefix nil)
  (setq org-agenda-remove-timeranges-from-blocks nil)
  (setq org-agenda-compact-blocks nil)
  (setq org-agenda-block-separator ?—)

;;;; Agenda marks
  (setq org-agenda-bulk-mark-char "#")
  (setq org-agenda-persistent-marks nil)

;;;; Agenda diary entries
  (setq org-agenda-insert-diary-strategy 'date-tree)
  (setq org-agenda-insert-diary-extract-time nil)
  (setq org-agenda-include-diary nil)
  ;; I do not want the diary, but there is no way to disable it
  ;; altogether.  This creates a diary file in the /tmp directory.
  (setq diary-file (make-temp-file "emacs-diary-"))
  (setq org-agenda-diary-file 'diary-file) ; TODO 2023-05-20: review Org diary substitute

;;;; Agenda follow mode
  (setq org-agenda-start-with-follow-mode nil)
  (setq org-agenda-follow-indirect t)

;;;; Agenda multi-item tasks
  (setq org-agenda-dim-blocked-tasks t)
  (setq org-agenda-todo-list-sublevels t)

;;;; Agenda filters and restricted views
  (setq org-agenda-persistent-filter nil)
  (setq org-agenda-restriction-lock-highlight-subtree t)

;;;; Agenda items with deadline and scheduled timestamps
  (setq org-agenda-include-deadlines t)
  (setq org-deadline-warning-days 0)
  (setq org-agenda-skip-scheduled-if-done nil)
  (setq org-agenda-skip-scheduled-if-deadline-is-shown t)
  (setq org-agenda-skip-timestamp-if-deadline-is-shown t)
  (setq org-agenda-skip-deadline-if-done nil)
  (setq org-agenda-skip-deadline-prewarning-if-scheduled 1)
  (setq org-agenda-skip-scheduled-delay-if-deadline nil)
  (setq org-agenda-skip-additional-timestamps-same-entry nil)
  (setq org-agenda-skip-timestamp-if-done nil)
  (setq org-agenda-search-headline-for-time nil)
  (setq org-scheduled-past-days 365)
  (setq org-deadline-past-days 365)
  (setq org-agenda-move-date-from-past-immediately-to-today t)
  (setq org-agenda-show-future-repeats t)
  (setq org-agenda-prefer-last-repeat nil)
  (setq org-agenda-timerange-leaders
        '("" "(%d/%d): "))
  (setq org-agenda-scheduled-leaders
        '("Scheduled: " "Sched.%2dx: "))
  (setq org-agenda-inactive-leader "[")
  (setq org-agenda-deadline-leaders
        '("Deadline:  " "In %3d d.: " "%2d d. ago: "))
  ;; Time grid
  (setq org-agenda-time-leading-zero t)
  (setq org-agenda-timegrid-use-ampm nil)
  (setq org-agenda-use-time-grid t)
  (setq org-agenda-show-current-time-in-grid t)
  (setq org-agenda-current-time-string (concat "Now " (make-string 70 ?_)))
  (setq org-agenda-time-grid
        '((daily today require-timed)
          ( 0500 0600 0700 0800 0900 1000
            1100 1200 1300 1400 1500 1600
            1700 1800 1900 2000 2100 2200)
          "" ""))
  (setq org-agenda-default-appointment-duration nil)

;;;; Agenda global to-do list
  (setq org-agenda-todo-ignore-with-date t)
  (setq org-agenda-todo-ignore-timestamp t)
  (setq org-agenda-todo-ignore-scheduled t)
  (setq org-agenda-todo-ignore-deadlines t)
  (setq org-agenda-todo-ignore-time-comparison-use-seconds t)
  (setq org-agenda-tags-todo-honor-ignore-options nil)

;;;; Agenda tagged items
  (setq org-agenda-show-inherited-tags t)
  (setq org-agenda-use-tag-inheritance
        '(todo search agenda))
  (setq org-agenda-hide-tags-regexp nil)
  (setq org-agenda-remove-tags nil)
  (setq org-agenda-tags-column -100)

;;;; Agenda entry
  ;; NOTE: I do not use this right now.  Leaving everything to its
  ;; default value.
  (setq org-agenda-start-with-entry-text-mode nil)
  (setq org-agenda-entry-text-maxlines 5)
  (setq org-agenda-entry-text-exclude-regexps nil)
  (setq org-agenda-entry-text-leaders "    > ")

;;;; Agenda logging and clocking
  ;; NOTE: I do not use these yet, though I plan to.  Leaving everything
  ;; to its default value for the time being.
  (setq org-agenda-log-mode-items '(closed clock))
  (setq org-agenda-clock-consistency-checks
        '((:max-duration "10:00" :min-duration 0 :max-gap "0:05" :gap-ok-around
                         ("4:00")
                         :default-face ; This should definitely be reviewed
                         ((:background "DarkRed")
                          (:foreground "white"))
                         :overlap-face nil :gap-face nil :no-end-time-face nil
                         :long-face nil :short-face nil)))
  (setq org-agenda-log-mode-add-notes t)
  (setq org-agenda-start-with-log-mode nil)
  (setq org-agenda-start-with-clockreport-mode nil)
  (setq org-agenda-clockreport-parameter-plist '(:link t :maxlevel 2))
  (setq org-agenda-search-view-always-boolean nil)
  (setq org-agenda-search-view-force-full-words nil)
  (setq org-agenda-search-view-max-outline-level 0)
  (setq org-agenda-search-headline-for-time t)
  (setq org-agenda-use-time-grid t)
  (setq org-agenda-cmp-user-defined nil)
  (setq org-agenda-sort-notime-is-late t) ; Org 9.4
  (setq org-agenda-sort-noeffort-is-high t) ; Org 9.4

;;;; Agenda column view
  ;; NOTE I do not use these, but may need them in the future.
  (setq org-agenda-view-columns-initially nil)
  (setq org-agenda-columns-show-summaries t)
  (setq org-agenda-columns-compute-summary-properties t)
  (setq org-agenda-columns-add-appointments-to-effort-sum nil)
  (setq org-agenda-auto-exclude-function nil)
  (setq org-agenda-bulk-custom-functions nil))

;;; Sync the org agenda with a Nextcloud calendar
(use-package org-caldav
  :ensure t
  :init
  (setq org-caldav-url "https://cloud.schlienger.xyz/remote.php/dav/calendars/marc/")
  (setq org-caldav-calendar-id "org")
  (setq org-caldav-files nil)
  (setq org-caldav-inbox "~/Nextcloud/cloud.schlienger.xyz/org/calendar.org")
  (setq org-caldav-save-directory "~/Nextcloud/cloud.schlienger.xyz/org/.caldav-backups")
  (setq org-icalendar-timezone "Europe/Berlin"))
  ;:config
  ;(add-hook 'org-agenda-mode-hook 'org-caldav-sync))
(provide 'init-org)
