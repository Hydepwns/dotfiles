;;; droo-completion.el --- Minibuffer and in-buffer completion -*- lexical-binding: t; -*-

;;; Commentary:

;; The vertico/consult/corfu stack: small, composable packages built on Emacs'
;; own completion machinery rather than a parallel framework.  `orderless' means
;; space-separated fragments match in any order, which is the main ergonomic win.

;;; Code:

(eval-when-compile (require 'use-package))

;;; Minibuffer

(use-package vertico
  :init
  (setq vertico-cycle t
        vertico-count 15)
  (vertico-mode 1))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        ;; `partial-completion' keeps path expansion (/u/s/l -> /usr/share/lib).
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package consult
  :bind (("C-s"     . consult-line)
         ("C-x b"   . consult-buffer)
         ("C-x p b" . consult-project-buffer)
         ("M-y"     . consult-yank-pop)
         ("M-g g"   . consult-goto-line)
         ("M-g i"   . consult-imenu)
         ("M-s r"   . consult-ripgrep)
         ("M-s f"   . consult-find))
  :init
  (setq consult-narrow-key "<"
        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

;;; In-buffer

(use-package corfu
  :init
  (setq corfu-auto t
        corfu-auto-delay 0.15
        corfu-auto-prefix 2
        corfu-cycle t
        corfu-preselect 'prompt
        ;; Let RET insert a newline when nothing was explicitly selected.
        corfu-preview-current 'insert)
  (global-corfu-mode 1)
  (corfu-popupinfo-mode 1))

(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

;;; Actions

(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(provide 'droo-completion)

;;; droo-completion.el ends here
