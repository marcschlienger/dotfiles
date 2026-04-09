;;; lib-org.el -*- lexical-binding: t -*-

;; Change a TODO entry automatically to DONE when all children are DONE 
(defun org-summary-todo (n-done n-not-done)
  "Switch entry to DONE when all subentries are done, to TODO otherwise."
  (let (org-log-done org-todo-log-states)   ; turn off logging
    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

(add-hook 'org-after-todo-statistics-hook #'org-summary-todo)

;; Save all `org-agenda-files' buffers automatically after refiling.
;; For this to work it is necessary to save the full path to the org
;; agenda files in the variable 'org-agenda-files'
(defun ms-org--save-org-agenda-file-buffers ()
  "Save `org-agenda-files' buffers without user confirmation.
See also `org-save-all-org-buffers'"
  (interactive)
  (message "Saving org-agenda-files buffers...")
  (save-some-buffers t (lambda () 
			 (when (member (buffer-file-name) org-agenda-files) 
			   t)))
  (message "Saving org-agenda-files buffers... done"))

(advice-add 'org-refile :after
            (lambda (&rest _)
              (gtd-save-org-buffers)))

(provide 'lib-org)
