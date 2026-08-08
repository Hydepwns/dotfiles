;;; droo-git.el --- Version control -*- lexical-binding: t; -*-

;;; Commentary:

;; Magit, plus fringe indicators for uncommitted hunks.

;;; Code:

(eval-when-compile (require 'use-package))

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch))
  :init
  (setq magit-diff-refine-hunk 'all
        ;; Full-frame magit, restoring the previous layout on quit.
        magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1
        magit-bury-buffer-function #'magit-restore-window-configuration)
  :config
  ;; The repo signs commits (see gpg_signing_key in chezmoi.toml); make that the
  ;; default in the commit popup rather than something to remember each time.
  (setq magit-commit-arguments '("--gpg-sign")))

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (conf-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode))
  :init
  (setq diff-hl-draw-borders nil)
  :config
  ;; Without these the fringe goes stale after a magit stage/commit.
  (add-hook 'magit-pre-refresh-hook #'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)
  (diff-hl-flydiff-mode 1))

(provide 'droo-git)

;;; droo-git.el ends here
