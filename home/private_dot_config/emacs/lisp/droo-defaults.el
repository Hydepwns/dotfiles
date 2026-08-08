;;; droo-defaults.el --- Sane built-in defaults -*- lexical-binding: t; -*-

;;; Commentary:

;; Built-in behavior only, plus the two packages that exist to keep the rest of
;; the config honest: `no-littering' (state stays out of the managed tree) and
;; `exec-path-from-shell' (a launchd-started daemon inherits almost no PATH, so
;; without it eglot cannot find rust-analyzer, mise shims, or anything else).

;;; Code:

(eval-when-compile (require 'use-package))

;; Defined in early-init.el; declared here to quiet the byte-compiler.
(defvar droo/xdg-data)
(defvar droo/data-dir)
(defvar droo/cache-dir)
(defvar droo/state-dir)

;;; Garbage collection

;; early-init.el raised this to `most-positive-fixnum' for startup. Drop it back
;; to something that does not produce multi-second pauses on a large heap.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 64 1024 1024)
                  gc-cons-percentage 0.1)))

;;; Keep state out of ~/.config/emacs

(use-package no-littering
  :init
  ;; Must be set before the package loads -- it computes paths at load time.
  (setq no-littering-etc-directory (expand-file-name "etc/" droo/data-dir)
        no-littering-var-directory (expand-file-name "var/" droo/state-dir))
  :config
  ;; Redirects backups, auto-saves, and lockfile-adjacent state.
  (no-littering-theme-backups))

;;; Environment

;; A GUI or daemon Emacs on macOS starts from launchd, not from a login shell.
(use-package exec-path-from-shell
  :if (or (daemonp) (memq window-system '(mac ns x)))
  :config
  (setq exec-path-from-shell-arguments '("-l")
        exec-path-from-shell-variables
        '("PATH" "MANPATH" "SSH_AUTH_SOCK" "LANG" "LC_ALL"
          "XDG_DATA_HOME" "XDG_CACHE_HOME" "XDG_STATE_HOME" "XDG_CONFIG_HOME"))
  (exec-path-from-shell-initialize))

;; mise activates from .zshrc, which a login shell never sources, so the step
;; above cannot see its shims -- and most language servers here are mise-managed.
;; Adding the directory explicitly is cheaper and more predictable than paying
;; for an interactive shell just to inherit one PATH entry.
(let ((shims (expand-file-name "mise/shims" droo/xdg-data)))
  (when (file-directory-p shims)
    (add-to-list 'exec-path shims)
    (setenv "PATH" (concat shims path-separator (getenv "PATH")))))

;;; Startup and prompts

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil
      initial-major-mode 'fundamental-mode
      ring-bell-function #'ignore
      use-short-answers t
      confirm-kill-emacs #'yes-or-no-p
      ;; A running daemon should not die because a client said so.
      confirm-kill-processes nil)

;;; Files

(setq create-lockfiles nil
      load-prefer-newer t
      require-final-newline t
      find-file-visit-truename t
      ;; Large minified files should not hang Emacs.
      large-file-warning-threshold (* 32 1024 1024))

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

(save-place-mode 1)
(recentf-mode 1)
(setq recentf-max-saved-items 300)

(savehist-mode 1)
(setq history-length 1000
      savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(global-so-long-mode 1)

;;; Editing

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 100)

(setq sentence-end-double-space nil
      tab-always-indent 'complete
      kill-do-not-save-duplicates t
      mouse-yank-at-point t)

(delete-selection-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(setq show-paren-delay 0
      show-paren-context-when-offscreen 'overlay)

(when (fboundp 'context-menu-mode)
  (context-menu-mode 1))

;;; Scrolling

(setq scroll-conservatively 101
      scroll-margin 3
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

(pixel-scroll-precision-mode 1)

;;; macOS

(when (eq system-type 'darwin)
  (setq ns-command-modifier 'super
        ns-alternate-modifier 'meta
        ;; Leave right-option alone so accented characters still type.
        ns-right-alternate-modifier 'none
        ns-use-native-fullscreen t
        ;; Trash instead of unlinking, matching Finder semantics.
        delete-by-moving-to-trash t
        trash-directory nil))

(provide 'droo-defaults)

;;; droo-defaults.el ends here
