;;; droo-lsp.el --- Eglot and diagnostics -*- lexical-binding: t; -*-

;;; Commentary:

;; Eglot (built in since Emacs 29) over lsp-mode: it reuses xref, flymake,
;; eldoc, and completion-at-point instead of replacing them.
;;
;; Every language is configured, but `eglot-ensure' is only hooked when the
;; server binary is actually on PATH.  Missing servers therefore cost nothing --
;; the buffer opens in its normal major mode with no error -- and installing a
;; server later needs only a restart, no config change.

;;; Code:

(eval-when-compile (require 'use-package))

(defconst droo/eglot-servers
  '((elixir-ts-mode-hook     . "elixir-ls")
    (heex-ts-mode-hook       . "elixir-ls")
    (rust-ts-mode-hook       . "rust-analyzer")
    (go-ts-mode-hook         . "gopls")
    (typescript-ts-mode-hook . "typescript-language-server")
    (tsx-ts-mode-hook        . "typescript-language-server")
    (js-ts-mode-hook         . "typescript-language-server")
    (python-ts-mode-hook     . "ruff")
    (lua-ts-mode-hook        . "lua-language-server")
    (nix-ts-mode-hook        . "nixd")
    (solidity-mode-hook      . "solc")
    (bash-ts-mode-hook       . "bash-language-server")
    (yaml-ts-mode-hook       . "yaml-language-server")
    (json-ts-mode-hook       . "vscode-json-language-server"))
  "Map of major-mode hook to the executable that provides its language server.")

(defun droo/eglot-available-servers ()
  "Return the subset of `droo/eglot-servers' whose executable is installed."
  (seq-filter (lambda (spec) (executable-find (cdr spec))) droo/eglot-servers))

(use-package eglot
  :ensure nil                           ; built in since Emacs 29
  :bind (:map eglot-mode-map
         ("C-c l r" . eglot-rename)
         ("C-c l a" . eglot-code-actions)
         ("C-c l f" . eglot-format-buffer)
         ("C-c l d" . eldoc-doc-buffer))
  :init
  (setq eglot-autoshutdown t
        eglot-sync-connect 1
        ;; Eglot logs every LSP message by default; that dominates memory on a
        ;; long-lived daemon and is only useful when actively debugging a server.
        eglot-events-buffer-config '(:size 0 :format full)
        eglot-extend-to-xref t)

  (dolist (spec (droo/eglot-available-servers))
    (add-hook (car spec) #'eglot-ensure))

  :config
  ;; ruff is a linter/formatter server, not a type checker; prefer basedpyright
  ;; when it is installed and fall back to ruff, which still gives diagnostics.
  (add-to-list 'eglot-server-programs
               (cons '(python-ts-mode python-mode)
                     (if (executable-find "basedpyright-langserver")
                         '("basedpyright-langserver" "--stdio")
                       '("ruff" "server")))))

;;; Diagnostics

(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  ;; Scoped to the mode map -- M-n/M-p stay free for history elsewhere.
  :bind (:map flymake-mode-map
         ("M-n" . flymake-goto-next-error)
         ("M-p" . flymake-goto-prev-error))
  :init
  (setq flymake-no-changes-timeout 0.5
        flymake-fringe-indicator-position 'right-fringe))

;;; Docs

(setq eldoc-echo-area-use-multiline-p 2
      eldoc-idle-delay 0.2)

;;; Projects

(setq project-vc-extra-root-markers
      '("mix.exs" "Cargo.toml" "go.mod" "package.json"
        "pyproject.toml" "flake.nix" "foundry.toml" "Nargo.toml"))

(provide 'droo-lsp)

;;; droo-lsp.el ends here
