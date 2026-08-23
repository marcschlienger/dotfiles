;;; init-elfeed.el -*- lexical-binding: t -*-

;; Feed subscriptions will be supplied by Feedbin rather than maintained here.
(use-package elfeed
  :ensure t
  :custom
  (elfeed-show-entry-switch 'display-buffer)
  :bind ("C-x w" . elfeed)
  :commands (elfeed))

(provide 'init-elfeed)
