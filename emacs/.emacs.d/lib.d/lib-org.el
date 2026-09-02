;;; lib-org.el -*- lexical-binding: t -*-

;; Change a TODO entry automatically to DONE when all children are DONE.
(defconst ms-org-summary-managed-states '("TODO" "DONE")
  "Parent states `ms-org-summary-todo' may rewrite automatically.
Anything else -- WAITING, NEXT, CANCELLED -- carries a decision that a
child's checkbox has no business overturning.")

(defun ms-org-summary-todo (n-done n-not-done)
  "Update a TODO parent from the state of its child entries.
Leave ordinary headings, such as project containers, unchanged, and leave
any state not in `ms-org-summary-managed-states' alone: rewriting those to
TODO discards information.  A parent marked WAITING is waiting on
something external, NEXT is a deliberate choice of what to do next, and
CANCELLED means the work is not happening -- none of which follow from a
child still being open."
  (when (and (member (org-get-todo-state) ms-org-summary-managed-states)
             (> (+ n-done n-not-done) 0))
    (let (org-log-done org-todo-log-states) ; turn off logging
      (org-todo (if (= n-not-done 0) "DONE" "TODO")))))

(add-hook 'org-after-todo-statistics-hook #'ms-org-summary-todo)

;; Keep `appt' synchronized with Org captures, saves, and external changes.
(defvar ms-org-appt-refresh-timer nil)
(defvar ms-org-appt-periodic-refresh-timer nil)

(defun ms-org-refresh-appt ()
  "Rebuild appointments from the current Org agenda files."
  (when (featurep 'org-agenda)
    (org-agenda-to-appt t)))

(defun ms-org-schedule-appt-refresh ()
  "Debounce an appointment refresh after an Org change."
  (when (timerp ms-org-appt-refresh-timer)
    (cancel-timer ms-org-appt-refresh-timer))
  (setq ms-org-appt-refresh-timer
        (run-with-idle-timer
         2 nil
         (lambda ()
           (setq ms-org-appt-refresh-timer nil)
           (ms-org-refresh-appt)))))

(defun ms-org-schedule-appt-refresh-after-save ()
  "Schedule an appointment refresh after saving an agenda file."
  (when (and buffer-file-name
             (member (file-truename buffer-file-name)
                     (mapcar #'file-truename (org-agenda-files t))))
    (ms-org-schedule-appt-refresh)))

(defun ms-org-enable-appt-refresh-after-save ()
  "Refresh Org appointments after saving the current agenda file."
  (add-hook 'after-save-hook
            #'ms-org-schedule-appt-refresh-after-save nil t))

(defun ms-org-start-appt-refresh-timer ()
  "Refresh Org appointments every fifteen minutes."
  (unless (timerp ms-org-appt-periodic-refresh-timer)
    (setq ms-org-appt-periodic-refresh-timer
          (run-at-time (* 15 60) (* 15 60) #'ms-org-refresh-appt))))

(defun ms-org-appt-initialise ()
  "Switch on Org appointment reminders and keep them up to date.

Nothing calls this at startup: `org-agenda' is not loaded then, and Org
is not used for task management in this configuration.  Run it with
\\[execute-extended-command] ms-org-appt-initialise for the current
session, or add it to `emacs-startup-hook' from init-org.el to get
reminders in every session.  Loading `org-agenda' is what makes
`org-agenda-to-appt' available, so it is required here rather than
waited for."
  (interactive)
  (condition-case error-data
      (progn
        (require 'org-agenda)
        (appt-activate 1)
        (ms-org-refresh-appt)
        (ms-org-start-appt-refresh-timer)
        (message "Org appointment reminders on (%d entries from %d agenda file(s))"
                 (length appt-time-msg-list)
                 (length (org-agenda-files t))))
    (error
     (display-warning
      'appt
      (format "Could not start Org appointment reminders: %s"
              (error-message-string error-data))
      :warning))))

;; Save all `org-agenda-files' buffers automatically after refiling.
(defun ms-org--save-org-agenda-file-buffers (&rest _)
  "Save `org-agenda-files' buffers without user confirmation.
See also `org-save-all-org-buffers'"
  (interactive)
  (message "Saving org-agenda-files buffers...")
  (let ((agenda-files (mapcar #'file-truename (org-agenda-files t))))
    (save-some-buffers
     t
     (lambda ()
       (when-let* ((file (buffer-file-name)))
         (member (file-truename file) agenda-files)))))
  (message "Saving org-agenda-files buffers... done"))

(advice-add 'org-refile :after #'ms-org--save-org-agenda-file-buffers)

(provide 'lib-org)
