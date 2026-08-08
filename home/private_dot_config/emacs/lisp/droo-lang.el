;;; droo-lang.el --- Language modes and tree-sitter -*- lexical-binding: t; -*-

;;; Commentary:

;; Emacs 30 ships tree-sitter modes for nearly the whole stack -- including
;; elixir-ts-mode, heex-ts-mode, and lua-ts-mode -- so only nix, markdown, and
;; solidity need packages.
;;
;; Grammars are not bundled.  `droo/treesit-install-grammars' compiles the
;; missing ones; `make emacs-grammars' calls it in batch.  Modes are remapped
;; only when their grammar is actually present, so a fresh machine falls back to
;; the classic major mode instead of erroring on every file open.

;;; Code:

(eval-when-compile (require 'use-package))
(require 'treesit)

;; Defined in early-init.el.
(defvar droo/data-dir)

;;; Grammars

(setq treesit-language-source-alist
      '((bash       . ("https://github.com/tree-sitter/tree-sitter-bash"))
        (c          . ("https://github.com/tree-sitter/tree-sitter-c"))
        (css        . ("https://github.com/tree-sitter/tree-sitter-css"))
        (elixir     . ("https://github.com/elixir-lang/tree-sitter-elixir"))
        (go         . ("https://github.com/tree-sitter/tree-sitter-go"))
        (gomod      . ("https://github.com/camdencheek/tree-sitter-go-mod"))
        (heex       . ("https://github.com/phoenixframework/tree-sitter-heex"))
        (html       . ("https://github.com/tree-sitter/tree-sitter-html"))
        (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
        (json       . ("https://github.com/tree-sitter/tree-sitter-json"))
        (lua        . ("https://github.com/tree-sitter-grammars/tree-sitter-lua"))
        (nix        . ("https://github.com/nix-community/tree-sitter-nix"))
        (python     . ("https://github.com/tree-sitter/tree-sitter-python"))
        (rust       . ("https://github.com/tree-sitter/tree-sitter-rust"))
        (toml       . ("https://github.com/tree-sitter/tree-sitter-toml"))
        (tsx        . ("https://github.com/tree-sitter/tree-sitter-typescript"
                       "master" "tsx/src"))
        (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript"
                       "master" "typescript/src"))
        (yaml       . ("https://github.com/ikatyang/tree-sitter-yaml"))))

;; Keep compiled grammars beside the packages, not in the managed config tree.
(defvar droo/treesit-grammar-dir (expand-file-name "tree-sitter" droo/data-dir)
  "Directory holding compiled tree-sitter grammars.")

(add-to-list 'treesit-extra-load-path droo/treesit-grammar-dir)

(defun droo/treesit-install-grammars (&optional force)
  "Compile any tree-sitter grammar that is not already available.
With FORCE non-nil, reinstall every configured grammar.
Requires a C compiler and git on PATH."
  (interactive "P")
  (let ((out-dir droo/treesit-grammar-dir))
    (make-directory out-dir t)
    (dolist (entry treesit-language-source-alist)
      (let ((lang (car entry)))
        (if (and (not force) (treesit-language-available-p lang))
            (message "treesit: %s already available" lang)
          (message "treesit: installing %s..." lang)
          (condition-case err
              (treesit-install-language-grammar lang out-dir)
            ;; One unreachable upstream should not abort the whole run.
            (error (message "treesit: FAILED %s -- %s"
                            lang (error-message-string err)))))))))

;;; Major mode remapping

;; Only remap when the grammar exists, so files still open on a fresh checkout.
(dolist (entry '((sh-mode         . bash-ts-mode)
                 (css-mode        . css-ts-mode)
                 (js-mode         . js-ts-mode)
                 (javascript-mode . js-ts-mode)
                 (json-mode       . json-ts-mode)
                 (js-json-mode    . json-ts-mode)
                 (python-mode     . python-ts-mode)
                 (conf-toml-mode  . toml-ts-mode)))
  (let* ((ts-mode (cdr entry))
         (lang (intern (string-remove-suffix "-ts-mode" (symbol-name ts-mode)))))
    (when (treesit-language-available-p (if (eq lang 'js) 'javascript lang))
      (add-to-list 'major-mode-remap-alist entry))))

;;; File associations

;; These modes have no classic counterpart to remap from.
(dolist (entry '(("\\.ex\\'"    . elixir-ts-mode)
                 ("\\.exs\\'"   . elixir-ts-mode)
                 ("mix\\.lock\\'" . elixir-ts-mode)
                 ("\\.heex\\'"  . heex-ts-mode)
                 ("\\.rs\\'"    . rust-ts-mode)
                 ("\\.go\\'"    . go-ts-mode)
                 ("/go\\.mod\\'" . go-mod-ts-mode)
                 ("\\.lua\\'"   . lua-ts-mode)
                 ("\\.ts\\'"    . typescript-ts-mode)
                 ("\\.tsx\\'"   . tsx-ts-mode)
                 ("\\.ya?ml\\'" . yaml-ts-mode)))
  (add-to-list 'auto-mode-alist entry))

;;; Packages

(use-package nix-ts-mode
  :mode "\\.nix\\'")

(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode)
  :init (setq markdown-fontify-code-blocks-natively t))

(use-package solidity-mode
  :mode "\\.sol\\'"
  :init (setq solidity-comment-style 'slash))

;;; Indentation

(setq typescript-ts-mode-indent-offset 2
      js-indent-level 2
      css-indent-offset 2
      lua-ts-indent-offset 2)

(provide 'droo-lang)

;;; droo-lang.el ends here
