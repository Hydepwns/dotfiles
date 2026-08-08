;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

;; Managed by chezmoi: home/private_dot_config/emacs/init.el

;;; Commentary:

;; Vanilla Emacs 30 with package.el and the built-in use-package.  Runtime state
;; lives under XDG directories (see early-init.el); this tree stays read-only as
;; far as Emacs is concerned.
;;
;; The theme loads before any module so that a broken package still leaves a
;; correctly themed Emacs.  `custom-theme-set-faces' records specs for faces that
;; do not exist yet, so magit/corfu/eglot faces are themed when those load later.

;;; Code:

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))

(load-theme 'synthwave84-soft t)

;;; Packages

(require 'package)

(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/"))
      ;; Prefer the curated archives; fall back to MELPA for everything else.
      package-archive-priorities
      '(("gnu" . 3) ("nongnu" . 2) ("melpa" . 1)))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)

(setq use-package-always-ensure t
      use-package-expand-minimally t
      ;; `M-x use-package-report' to find slow packages.
      use-package-compute-statistics t)

;;; Modules

(require 'droo-defaults)
(require 'droo-ui)
(require 'droo-completion)
(require 'droo-git)
(require 'droo-lang)
(require 'droo-lsp)

;; Written by `customize'; kept out of the chezmoi-managed tree. Nothing here is
;; authoritative -- prefer editing the modules above.
(when (file-exists-p custom-file)
  (load custom-file nil t))

;;; init.el ends here
