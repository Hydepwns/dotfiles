;;; droo-ui.el --- Fonts and visual chrome -*- lexical-binding: t; -*-

;;; Commentary:

;; Fonts and UI affordances.  Colors live entirely in the theme
;; (themes/synthwave84-soft-theme.el) -- nothing here names one.
;;
;; Font settings match Ghostty and Zed: Monaspace Neon at 14pt.  Zed uses a 1.4
;; line height; Emacs expresses that as `line-spacing' extra leading, so 0.2 of
;; the default ~1.2 line box lands in the same place.

;;; Code:

(eval-when-compile (require 'use-package))

;;; Fonts

(defconst droo/font-family "Monaspace Neon"
  "Primary typeface, shared with Ghostty and Zed.")

(defconst droo/font-height 140
  "Default font height in 1/10 pt, i.e. 14pt.")

(defun droo/apply-fonts (&optional frame)
  "Apply the configured font to FRAME.
Does nothing when the family is unavailable, so a machine without
Monaspace installed still gets a usable Emacs rather than a broken one."
  (when (and (display-graphic-p frame)
             (member droo/font-family (font-family-list frame)))
    (dolist (face '(default fixed-pitch variable-pitch))
      (set-face-attribute face frame
                          :family droo/font-family
                          :height droo/font-height))))

;; Under a daemon there is no frame at startup, so `font-family-list' is empty
;; and fonts must be applied per-frame as clients connect.
(if (daemonp)
    (add-hook 'after-make-frame-functions #'droo/apply-fonts)
  (droo/apply-fonts))

;; Fractional value = that fraction of the default line height, added as leading.
(setq-default line-spacing 0.2)

;;; Chrome

(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(column-number-mode 1)
(setq display-line-numbers-width 3
      display-line-numbers-widen t)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'hl-line-mode)

;; Soft wrap prose, never code.
(add-hook 'text-mode-hook #'visual-line-mode)

(setq window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(window-divider-mode 1)

;; Frame title: project-relative path, or the buffer name when there is no file.
(setq frame-title-format
      '(:eval (if buffer-file-name
                  (abbreviate-file-name buffer-file-name)
                "%b")))

;;; Built-in discoverability

(use-package which-key
  :ensure nil                           ; built in since Emacs 30
  :init
  (setq which-key-idle-delay 0.5
        which-key-sort-order #'which-key-key-order-alpha)
  (which-key-mode 1))

;;; Packages

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package pulsar
  :init
  (setq pulsar-pulse t
        pulsar-delay 0.05
        pulsar-iterations 8
        pulsar-face 'pulsar-magenta)
  :config
  (pulsar-global-mode 1)
  ;; Flash the landing line after a jump, so the cursor is never lost.
  (add-hook 'next-error-hook #'pulsar-pulse-line)
  (add-hook 'xref-after-jump-hook #'pulsar-pulse-line))

(provide 'droo-ui)

;;; droo-ui.el ends here
