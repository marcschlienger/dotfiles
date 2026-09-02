;;-*- lexical-binding: t; -*-

(require 'lib-org)
(require 'lib-paths)                    ; `ms-cache-file'

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
  :demand t
  :config
  (setq appt-display-diary nil
        appt-display-format nil
        appt-display-mode-line t
        appt-display-interval 3
        appt-audible nil)
  ;; Reminders are NOT started at startup.  Org is not used for task
  ;; management here, so waking org-agenda to scan an empty `org-directory'
  ;; would cost most of a second of every session and find nothing.
  ;;
  ;; How to enable them:
  ;;   this session only  ->  M-x ms-org-appt-initialise
  ;;   every session      ->  uncomment the `emacs-startup-hook' line below
  ;;   as things stand    ->  they start if and when you open the agenda
  ;;                          (C-c a), through the form after that.
  ;;
  ;; (add-hook 'emacs-startup-hook #'ms-org-appt-initialise)
  (with-eval-after-load 'org-agenda (ms-org-appt-initialise)))

;; Org mode
(use-package org
  :ensure nil
  :init
  ;; Left at Org's own default.  Where notes should live is undecided --
  ;; if Org ever takes over note-taking it will most likely be a synced
  ;; directory under Nextcloud or iCloud, so this gets set properly then.
  ;; Nothing here creates the directory: an empty ~/org appearing on a
  ;; machine that does not use Org is noise, and Org copes without it.
  (setq org-directory (expand-file-name "~/org"))
  (setq org-imenu-depth 7)
  (add-to-list 'safe-local-variable-values '(org-hide-leading-stars . t))
  (add-to-list 'safe-local-variable-values '(org-hide-macro-markers . t))
  :bind
  ( :map global-map
    ("C-c l" . org-store-link)
    ("C-c o" . org-open-at-point-global)
    :map org-mode-map
    ("C-c M-l" . org-insert-last-stored-link)
    ("C-c C-M-l" . org-toggle-link-display)
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
  (setq org-fold-catch-invisible-edits 'show)
  (setq org-return-follows-link nil)
  (setq org-loop-over-headlines-in-active-region 'start-level)
  ;; Org's default pulls in eleven `ol-' link modules -- bbdb, gnus, irc,
  ;; mhe, rmail, w3m and the rest -- the first time any Org buffer opens,
  ;; and this file is an Org buffer.  None of them are used: notes live in
  ;; Obsidian, so there is nothing to store an Info or eww link into.
  (setq org-modules nil)
  (setq org-use-sub-superscripts '{})
  (setq org-insert-heading-respect-content t)
  (setq org-read-date-prefer-future 'time)
  (setq org-highlight-latex-and-related nil) ; other options affect elisp regexp in src blocks
  (setq org-fontify-quote-and-verse-blocks t)
  (setq org-track-ordered-property-with-tag t)
  (setq org-highest-priority ?A)
  (setq org-lowest-priority ?C)
  (setq org-default-priority ?A)
  :hook
  ((org-mode . org-indent-mode)
   (org-mode . ms-org-enable-appt-refresh-after-save)))

;;; refile, todo
(use-package org
  :ensure nil
  :config
  (setq org-refile-targets
        '(("projects.org" . (:regexp . "\\(?:\\(?:Note\\|Task\\)s\\)"))
          ("someday.org" . (:maxlevel . 2))))
  (setq org-refile-use-outline-path 'file)
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  (setq org-outline-path-complete-in-steps nil)
  ;; The cache does not notice files appearing in `org-agenda-files', which
  ;; is a directory here, so targets go stale until C-0 C-c C-w clears it.
  (setq org-refile-use-cache nil)
  (setq org-reverse-note-order nil)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (setq org-fontify-done-headline nil)
  (setq org-enforce-todo-dependencies t)
  (setq org-enforce-todo-checkbox-dependencies t)
  )

;;; tags
(use-package org
  :ensure nil
  :config
  (setq org-tag-alist
        '(("@home" . ?h)
          ("@work" . ?w)
          ("@comp" . ?c)))
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
  (setq org-confirm-babel-evaluate t)
  (setq org-src-window-setup 'current-window)
  (setq org-edit-src-persistent-message nil)
  (setq org-src-fontify-natively t)
  (setq org-src-preserve-indentation t)
  (setq org-src-tab-acts-natively t)
  ;; Renamed in Org 9.8.  Emacs 31 ships 9.8, Emacs 30 still ships 9.7 where
  ;; only the old name exists.  On 9.8 the old name survives as an alias, so
  ;; setting it works there too but warns when byte-compiling.
  (if (boundp 'org-src-content-indentation)
      (setq org-src-content-indentation 0)
    (setq org-edit-src-content-indentation 0))
  (setq org-babel-python-command "python3")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
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
        `(("i" "Inbox" entry (file "inbox.org")
           ,(concat "* TODO %^{Task} %^g\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n"
                    "%?"))
          ("n" "Note" entry (file "notes.org")
           ,(concat "* %^{Note}\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n"))
          ("N" "Meeting Note (linked)" entry (file "notes.org")
           ,(concat "* Meeting Note (%a)\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n"
                    "%?"))
          ("m" "Meeting Note" entry (file "notes.org")
           ,(concat "* %^{Description} :meeting:\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":END:\n"
                    "%?"))
          ("p" "Project" entry (file "projects.org")
           ,(concat "* %^{Project title} [/] :project:\n"
                    ":PROPERTIES:\n"
                    ":CAPTURED: %U\n"
                    ":VISIBILITY: folded\n"
                    ":COOKIE_DATA: recursive todo\n"
                    ":END:\n"
                    "** Information\n"
                    ":PROPERTIES:\n"
                    ":VISIBILITY: folded\n"
                    ":END:\n"
                    "%^{Info}\n" 
                    "** Notes\n"
                    ":PROPERTIES:\n"
                    ":VISIBILITY: folded\n"
                    ":END:\n"
                    "** Tasks\n"
                    ":PROPERTIES:\n"
                    ":VISIBILITY: content\n"
                    ":END:\n")))
        )
  :hook
  ((org-capture-mode . delete-other-windows) ;; use full window for org-capture
   (org-capture-after-finalize . ms-org-schedule-appt-refresh))
  )

;;; agenda
(use-package org-agenda
  :ensure nil
  :bind
  ( :map global-map
    ("C-c a" . org-agenda))
  :config
  ;; Unused: every capture template names its own target.  A fixed path in
  ;; the cache keeps it out of `org-directory' without leaving a fresh
  ;; temporary file behind on each session.
  (setq org-default-notes-file (ms-cache-file "org-default-notes.org"))
  ;; Directory entries are expanded whenever Org builds an agenda, so newly
  ;; created Org files are picked up without restarting Emacs.
  (setq org-agenda-files (list org-directory))
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
        '(("g" "Getting Things Done (GTD)"
         ((agenda ""
                  ((org-agenda-span 'day)
                   (org-agenda-skip-function
                    '(org-agenda-skip-entry-if 'deadline))
                   (org-deadline-warning-days 0)))
          (todo "NEXT"
                ((org-agenda-skip-function
                  '(org-agenda-skip-entry-if 'deadline))
                 (org-agenda-show-all-dates nil)
                 (org-agenda-prefix-format "  %i %-12:c [%e] ")
                 (org-agenda-overriding-header "\nTasks\n")))
          (tags "DEADLINE<>\"\""
                ((org-agenda-skip-function
                  (lambda ()
                    (org-agenda-skip-entry-if
                     'todo (cons "WAITING" org-done-keywords))))
                 (org-agenda-sorting-strategy '(deadline-up))
                 (org-agenda-overriding-header "\nDeadlines")))
          (tags "DEADLINE<>\"\""
                ((org-agenda-skip-function
                  '(org-agenda-skip-entry-if 'nottodo '("WAITING")))
                 (org-agenda-sorting-strategy '(deadline-up))
                 (org-agenda-overriding-header "\nWaiting deadlines")))
          (todo ""
                ((org-agenda-files
                  (list (expand-file-name "inbox.org" org-directory)))
                 (org-agenda-todo-ignore-with-date nil)
                 (org-agenda-todo-ignore-timestamp nil)
                 (org-agenda-todo-ignore-scheduled nil)
                 (org-agenda-todo-ignore-deadlines nil)
                 (org-agenda-prefix-format "  %?-12t% s")
                 (org-agenda-overriding-header "\nInbox\n")))
          (tags "CLOSED>=\"<today>\""
                ((org-agenda-overriding-header "\nCompleted today\n")))))
          ("h" "List all active tasks that have to be done @home"
           tags-todo "@home")
          ("w" "List all active tasks that have to be done @work"
           tags-todo "@work")
          ("p" "List all active project-related tasks"
           tags "+LEVEL=3+TODO=\"NEXT\"")))
  (setq org-agenda-max-entries nil)
  (setq org-agenda-max-todos nil)
  (setq org-agenda-max-tags nil)
  (setq org-agenda-max-effort nil)

;;;; General agenda view options
  (setq org-agenda-prefix-format
        '((agenda . " %i %-12:c%?-12t% s")
          (todo . " ")
          (tags . " %i %-12:c")
          (search . " %i %-12:c")))
  (setq org-agenda-sorting-strategy
        '((agenda habit-down time-up priority-down category-keep)
          (todo priority-down category-keep)
          (tags priority-down category-keep)
          (search category-keep)))
  (setq org-agenda-remove-times-when-in-prefix nil)
  (setq org-agenda-remove-timeranges-from-blocks nil)
  (setq org-agenda-block-separator ?—)

;;;; Agenda marks
  (setq org-agenda-bulk-mark-char "#")
  (setq org-agenda-persistent-marks nil)

;;;; Agenda diary entries
  (setq org-agenda-insert-diary-strategy 'date-tree)
  (setq org-agenda-insert-diary-extract-time nil)
  (setq org-agenda-include-diary nil)
  (setq diary-file (ms-cache-file "diary")) ;send it to oblivion
  (setq org-agenda-diary-file 'diary-file)

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
  (setq org-deadline-warning-days 7)
  (setq org-agenda-skip-scheduled-if-done nil)
  (setq org-agenda-skip-scheduled-if-deadline-is-shown t)
  (setq org-agenda-skip-timestamp-if-deadline-is-shown t)
  (setq org-agenda-skip-deadline-if-done nil)
  (setq org-agenda-skip-deadline-prewarning-if-scheduled 1)
  (setq org-agenda-skip-scheduled-delay-if-deadline nil)
  (setq org-agenda-skip-additional-timestamps-same-entry nil)
  (setq org-agenda-skip-timestamp-if-done nil)
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
  (setq org-agenda-show-inherited-tags nil)
  (setq org-agenda-use-tag-inheritance
        '(todo search agenda))
  (setq org-agenda-hide-tags-regexp nil)
  (setq org-agenda-remove-tags nil)
  (setq org-agenda-tags-column -100))

(provide 'init-org)
