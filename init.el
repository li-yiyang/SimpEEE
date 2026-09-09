;;;; init.el --- Emacs Configure  -*- lexical-binding: t; -*-

;;;; Commentary:

;; Tips: in emacs-lisp (.el) file, things after
;; semicon (;) is called comments.

;; Tips: press key (C-x ]) jumps to next section.
;; if you don't want to read these messy comments
;; and codes, just skip them for init theme.

;;;; Code:

;;; GC
;; the GC threshold is increased at start time
;; to avoid GC invoked in start time (for accelerate)
;; you can modify the `run-time-gc-threshold' below
;; to change the GC threshold for normal emacs
;; running time.

(setq gc-cons-threshold  most-positive-fixnum
      gc-cons-percentage 0.6)
(let ((run-time-gc-threshold 800000))
  (add-hook 'emacs-startup-hook
            (lambda ()
              (setq gc-cons-threshold run-time-gc-threshold))))

;;; Disable UI
;; the GUI components (if you're using GUI emacs) is
;; disabled at start time to avoid flashing

(when (display-graphic-p)
  (menu-bar-mode   -1)
  (tool-bar-mode   -1)
  (scroll-bar-mode -1))

;;; Disable warning
;; normally this is fine,
;; you can set `warning-minimum-level' to `:error' or `:warning'

(setq warning-minimum-level :emergency)


;;;; emacs theme

;; Custom init theme here if you like.

;; Tips: to insert the `^L' like mark in emacs buffer,
;; press (C-q C-l) \\{quoted-insert}.

;; (load-theme 'tsdh-light)


;;;; basic editing

(setq version-control     t)
(setq delete-old-versions nil)
(setq kept-new-versions   5)
(setq make-backup-files   t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width        2)


;;;; Custom

;; Tips: custom, see C-h r Custom section for how to use
;; custom to customize emacs behavior. 
;;
;; your custom emacs configure can also goes into custom.el
;; if you don't want it to be synced with git.
;;
;; the global custom configuratoins should be kept here,
;; shared accross the whole repo.

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Tips: use `define-key' to define keymap to trigger function.
;; here C-c C-c means to press Ctrl and c, release, then press
;; Ctrl and c.
;;
;; and `eval-defun' is used to evaluate S-expression at point.
;;
;; the `emacs-lisp-mode-map' means that the key binding is
;; avaliable in emacs-lisp mode.

(define-key emacs-lisp-mode-map (kbd "C-c C-c") 'eval-defun)


;;;; basic packages

(require 'package)
(require 'use-package)

;; Tips: you can customize the melpa mirror to accelerate
;; the network access.
;;
;; as for melpa-stable, it is providing pimacs (pi agent in emacs)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             t)

(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/")
             t)

;;;; Agents

;; Tips: pimacs provides pi agent access in emacs
;; URL https://pi.dev
;;
;; to use pimacs, press M-x pimacs-chat

(use-package pimacs
  :ensure t
  :custom ((pimacs-header-line-format
            '(:context_usage
              " (" :compaction_mode ")"
              :spacer
              :model " • " :thinking_level))))

;;;; Auto-complete

;; Tips: company is a helpful tool for completion. 

;; Tips: emacs use hook (C-h r Hooks) to trigger events.
;; you can consider it as a list of functions triggered
;; at specific time at once. For example, the `after-init-hook'
;; here triggers function `global-company-mode' after emacs
;; initialized.

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  ;; when in TUI mode, minibuffer eval expression
  ;; should disable company for better experience
  (unless (display-graphic-p)
    (add-hook 'minibuffer-setup-hook
              (lambda ()
                (when (eq this-command 'eval-expression)
                  (company-mode -1))))))

;;;; Git

;; Tips: magit is a git client in emacs,
;; you could use C-x g or M-x magit to invoke it.

(use-package magit
  :ensure t
  :bind (("C-x g" . magit))
  :config
  (magit-auto-revert-mode t))

;;;; Edit

;; Large file editing support
;; Ref: https://emacs-china.org/t/topic/25811/9

(setq-default bidi-display-reordering nil)
(setq bidi-inhibit-bpa        t
      long-line-threshold     1000
      large-hscroll-threshold 1000
      syntax-wholeline-max    1000)

;; Coding System
;; use UTF-8 as default coding system,
;; this should be no question on most unix-like system.
;; just in case.

(prefer-coding-system       'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

;; Tips: no need to manually save your code.
;; `auto-save-delete-trailing-whitespace-except-current-line' deletes trailing
;; whitespaces to format the code.

(use-package auto-save
  :ensure t
  :vc (:url "https://github.com/manateelazycat/auto-save.git"
            :rev :newest) 
  :custom ((auto-save-silent                                         t)
           (auto-save-delete-trailing-whitespace-except-current-line t))
  :config
  (auto-save-enable))

;; manual-save is used

(defvar before-manual-save-hook ()
  "Hooks to call before `manual-save'. ")

(defvar after-manual-save-hook ()
  "Hooks to call after `manual-save'. ")

(defun manual-save ()
  "Manual save.

This should be triggered by \\<global-map>\\[manual-save]. "
  (interactive)
  (run-hooks 'before-manual-save-hook)
  (save-buffer)
  (run-hooks 'after-manual-save-hook))

(global-set-key (kbd "C-x C-s") 'manual-save)
(add-hook 'after-manual-save-hook 'backup-buffer)

;; untabfy

(add-hook 'before-manual-save-hook
          (lambda () (untabify (point-min) (point-max))))

;; Tips: multiple-cursors allows you to edit multiple lines at once.
;; it is helpful if:
;; + insert index into tabluar configure files
;; + adjust indent, tabluar files

(use-package multiple-cursors
  :ensure t
  :bind (("C-c m" . mc/edit-lines)))

;; Tips: yasnippet provides template input,
;; you can M-x yas-new-snippet to create your own snippet.
;;
;; you should kept private snippets under custom-snippets and
;; not upload to git repo. 

(use-package yasnippet
  :ensure t
  :custom ((yas-snippet-dirs
            (list (expand-file-name "snippets"        user-emacs-directory)
                  (expand-file-name "custom-snippets" user-emacs-directory))))
  :config (yas-global-mode 1))

;;;; Lisp

;; Tips: paredit is handy for S-expression. 

;; Tips: emacs use mode (C-h r Modes) to toggle abilities.
;; the hook `lisp-mode-hook', `emacs-lisp-mode-hook' triggers
;; `paredit-mode' function, which is about to say:
;; enable paredit-mode at lisp-mode and emacs-lisp-mode.

;; Tips: C-c C-f means to press Ctrl key and c key at once,
;; then release, then press Ctrl and f.

;; Tips: here C-c C-f is binded to `hs-toggle-hiding', which
;; is used to fold the code structurally. (you can test it
;; with the codes).

(use-package paredit
  :ensure t
  :hook ((lisp-mode       . paredit-mode)
         (emacs-lisp-mode . paredit-mode)
         (paredit-mode    . hs-minor-mode))
  :bind ((:map lisp-mode-map
               ("C-c C-f" . hs-toggle-hiding)
               ("M-h v"   . sly-describe-symbol)
               ("M-h f"   . sly-describe-function)
               ("M-h c"   . sly-who-calls)
               ("M-h b"   . sly-who-binds)
               ("M-h d"   . sly-edit-definition)
               ("M-h h"   . sly-documentation-lookup)
               ("M-h l"   . sly-hyperspec-lookup))
         (:map emacs-lisp-mode-map
               ("C-c C-f" . hs-toggle-hiding)
               ("M-h v"   . describe-variable)
               ("M-h f"   . describe-function)
               ("M-h d"   . xref-find-definitions))))

(use-package sly
  :ensure t
  :custom ((inferior-lisp-program "sbcl --dynamic-space-size 40960"))
  :config

  (defun sly-mrepl-smart-return ()
    "Run `sly-mrepl-return' according to cursor position.

If at the end of buffer, call `sly-mrepl-return';
otherwise, call `newline'. "
    (interactive)
    (if (eq (point) (point-max))
        (sly-mrepl-return)
      (newline)))

  (defun try-open-url-at-point ()
    "Try to get URL and then open it at point. "
    (interactive)
    (let ((url (thing-at-point 'url)))
      (when url (browse-url url))))

  (defun lisp-fold-all ()
    "Fold All Lisp lists. "
    (interactive)
    (save-excursion
      (goto-char (point-max))
      (cl-loop for point = (forward-list -1)
               while (/= point 1)
               do (hs-hide-block)
               do (move-beginning-of-line 1))))

  ;; support in org
  (eval-after-load 'org
    (setq org-babel-lisp-eval-fn 'sly-eval
          org-babel-lisp-dir-fmt "(uiop:with-current-directory (#P%S)\n %%s\n)"))

  ;; CLHS using eww
  ;; hypersec-lookup--hyperspec-lookup-eww
  ;; see: http://dnaeon.github.io/common-lisp-hyperspec-lookup-using-w3m/
  ;; should set common-lisp-hyperspec-root to /path/to/your/local/HyperSpec

  (defun hyperspec-lookup--hyperspec-lookup-eww (orig-fun &rest args)
    (let ((browse-url-browser-function 'eww-open-file))
      (apply orig-fun args)))
  (advice-add 'hyperspec-lookup :around #'hyperspec-lookup--hyperspec-lookup-eww)
  )

;;;; Eshell

;; eshell is very powerful in emacs, most of the operations could be
;; done in eshell easily, for example, you can write lisp and shell
;; commands together like:
;;
;;    convert $file $(file-name-with-extension file "out")
;;
;; and eshell for loop:
;;
;;    for f in */*.in {
;;      convert $f $(file-name-with-extension f "out")
;;    }
;;

;; cache password to avoid sudo every time

(setq password-cache        t
      password-cache-expiry 600) ; 10min

(use-package emojishell
  :ensure t
  :vc (:url "https://github.com/li-yiyang/emojishell.git"
            :rev :newest)
  :custom ((eshell-prompt-function 'emojishell-emoji-prompt)))

;; Tips: eat is a terminal emulator in emacs 

(use-package eat
  :ensure t
  :hook ((eshell-mode . eat-eshell-mode)))

;;; below are some eshell commands

(defun eshell--buffer-name-p ()
  "Test if current buffer follows *eshell*[DIR]<> file pattern. "
  (string-match-p (rx (seq bol
                           "*eshell*[" (* (any ascii nonascii "/" ":")) "]"
                           (? "<" (any digit) ">")
                           eol))
                  (buffer-name)))

(defun eshell--generate-buffer-name ()
  "Generate eshell buffer name.
Return a string as buffer name like *eshell*[DIR]<> "
  (rename-buffer
   (if (emojishell-remote-p)
       (format "*eshell*[ssh:%s]"
               (file-name-nondirectory (directory-file-name default-directory)))
     (format "*eshell*[%s]"
             (file-name-nondirectory (directory-file-name default-directory))))
   t))

;;; eshell:
;; by default name eshell buffer with `eshell--generate-buffer-name',
;; and able to open multiple eshell buffer
(defun eshell--advice (fn &optional arg)
  "Make a new eshell buffer or switch to eshell buffer of same dir. "
  (if arg (funcall fn arg)
    (let* ((cwd  (file-truename default-directory))
           (buf  (cl-find-if (lambda (buf)
                               (with-current-buffer buf
                                 (and (derived-mode-p 'eshell-mode)
                                      (string= cwd (file-truename default-directory)))))
                             (buffer-list))))
      (if buf (switch-to-buffer buf)
        (funcall fn 'N)
        (rename-buffer (eshell--generate-buffer-name))))))
(advice-add 'eshell :around 'eshell--advice)

;;; eshell/cd:
;; kept eshell buffer updated with new name
(advice-add 'eshell/cd :after
            (lambda (&rest r)
              (when (eshell--buffer-name-p)
                (rename-buffer (eshell--generate-buffer-name)))))

;;; eshell/clear:
;; add filter-args (eshell/clear &optional CLEAR-SCROLLBACK),
;; make sure CLEAR-SCROLLBACK is by default `t' 
(advice-add 'eshell/clear :filter-args
            (lambda (args) (if (null args) '(t) args)))

;;; eshell/em:
;; em in eshell


;;; eshell/imgcat:
;; display image(s) in eshell, this makes emacs an image viewer
;; TODO: fix image display in TUI
(defun eshell/imgcat (&rest args)
  "Display IMAGES in eshell.

Ref: https://emacs-china.org/t/imgcat-eshell/3439"
  (if eshell-in-pipeline-p
      (error "Elisp function does not support piped input. ")
    (eshell-eval-using-options
     "imgcat" args
     '((nil "width"      t   width      "width of image(s)")
       (nil "height"     t   height     "height of image(s)")
       (nil "max-width"  t   max-width  "max width of image(s) [default 400]")
       (nil "max-height" t   max-height "max height of image(s)")
       (?h  "help"       nil nil        "show this usage screen")
       :show-usage
       :usage "[OPTION] IMAGE...
Show IMAGE(s) file in eshell. ")
     (let ((property ()))
       (setf (cl-getf property :max-width) (string-to-number (or max-width "400")))
       (when max-height (push-plist :max-height (string-to-number max-height) property))
       (when width      (push-plist :width      (string-to-number width)      property))
       (when height     (push-plist :height     (string-to-number height)     property))
       (if (null args)
           (eshell-show-usage "image" nil)
         (dolist (img (eshell-flatten-list args))
           (eshell-printn
            (propertize img 'display (apply #'create-image (expand-file-name img)
                                            nil nil property)))))))))

;;;; Pyim

(use-package pyim
  :ensure t
  :custom ((default-input-method                 "pyim")
           (pyim-punctuation-dict                 nil)
           (pyim-punctuation-translate-p        '(no auto yes))
           (pyim-english-input-switch-functions '(pyim-probe-program-mode))
           (pyim-page-length                     5)
           (pyim-page-tooltip                   'posframe))
  :config
  ;; use pyim in isearch
  (pyim-isearch-mode 1))

;;;; Prettify

(use-package posframe
  :ensure t)

;; Tips: used to popup a child frame at mouse

(use-package minibuffer-frame
  :ensure t
  :custom ((minibuffer-frame-width 0.8))
  :config

  ;; overwrite minibuffer-frame--init default frame init
  (defun minibuffer-frame--init ()
    "Create and center the minibuffer child frame."
    (setq minibuffer-frame--frame
          (make-frame
           `((parent-frame             . ,(selected-frame))
             (undecorated              . t)
             (z-group                  . above)
             (minibuffer               . only)
             (width                    . ,minibuffer-frame-width)
             (height                   . 1)
             (left-fringe              . 15)
             (right-fringe             . 5)
             (child-frame-border-width . 2)
             (foreground-color         . ,(face-foreground 'default))
             (background-color         . ,(face-background 'company-tooltip)))))
    (let ((pf (frame-parent minibuffer-frame--frame)))
      (set-frame-position
       minibuffer-frame--frame
       (floor (- (frame-pixel-width pf) (frame-pixel-width minibuffer-frame--frame)) 2)
       (floor (* (frame-text-height pf) minibuffer-frame-top)))))

  (fido-vertical-mode 1)
  (minibuffer-frame-mode 1))

;; minimal modeline

;; Tips: C-h r Mode Line will teach you how to use modeline
;; `describe-variable' of `mode-line-format' will tell you
;; how to customize mode line.

(setq mode-line-right-align-edge 'window)
(setq-default mode-line-format
              `("%e "
                mode-line-buffer-identification
                mode-line-format-right-align
                " L%l "
                (sly-mode ("[" sly--mode-line-format "]"))
                "["
                (:propertize ("" mode-name)
                             help-echo "Major mode
mouse-1: Display major mode menu 
mouse-2: Show help for major mode 
mouse-3: Toggle minor modes"
                             mouse-face mode-line-highlight
                             local-map ,mode-line-major-mode-keymap)
                "]"))

;;;; Org

;; Tips: org-mode is a good thing

(defvar latex-prettify-symbols-alist
  '(("\\alpha" . ?α)
    ("\\beta"  . ?β)
    ("\\gamma" . ?γ)
    ("\\delta" . ?δ)
    ("\\vdots" . ?⋮)
    ("\\ddots" . ?⋱)
    ("\\begin"  . ?▼)
    ("\\end"    . ?▲)
    ("\\gtrsim" . ?≳)
    ("\\lesssim" . ?≲)
    ("\\mapsto" . ?↦)
    ("\\multimap" . ?⊸)
    ("\\hookrightarrow" . ?↪)
    ("\\hookleftarrow" . ?↩)
    ("\\rightarrow"    . ?→)
    ("\\leftarrow"     . ?←)
    ("\\Rightarrow"    . ?⇒)
    ("\\Leftarrow"     . ?⇐)
    ;; \xrightarrow and \xleftarrow should differ from
    ;; normal \rightarrow and \leftarrow
    ;;
    ;; unicode from http://xahlee.info/comp/unicode_math_operators.html
    ("\\xrightarrow" . ?⥅)
    ("\\xleftarrow" . ?⥆)
    ("\\frac"   . ?𝐟)
    ("\\sqrt"   . ?√)
    ("\\updownarrow" . ?↕)
    ("\\boldsymbol" . ?𝐛)
    ("\\mathbb" . ?𝐁)
    ("\\mathrm" . ?𝐫)
    ("\\mathcal" . ?𝐜)
    ("\\Vert" . ?‖)
    ("\\Vert" . ?‖)
    ("\\left\\Vert" . ?‖)    ("\\right\\Vert" . ?‖)
    ("\\left\\lfloor" . ?⌊)  ("\\right\\rfloor" . ?⌋)
    ("\\left\\lceil"  . ?⌈)  ("\\right\\rceil" . ?⌉)
    ("\\left\\langle" . ?⟨)  ("\\right\\rangle" . ?⟩))
  "Prettify symbol for LaTeX. ")

(defun setup-latex-prettify-symbol-mode ()
  "Setup LaTeX prettify symbol. "
  (setq-local prettify-symbols-alist
              (append prettify-symbols-alist
                      latex-prettify-symbols-alist))
  (prettify-symbols-mode 1))

(use-package tex
  :ensure auctex)

(use-package cdlatex
  :ensure t
  :hook   ((org-mode . turn-on-org-cdlatex))
  :custom ((cdlatex-math-modify-alist
            '((?b "\\boldsymbol" "\\textbf" t nil nil)
              (?B "\\mathbb"     "\\textbf" t nil nil))))
  :config
  ;; overwrite default \longleftarrow and \longrightarrow
  ;; to \xleftarrow and \xrightarrow (need amsmath package)

  (add-to-list 'cdlatex-math-symbol-alist '(?< ("\\leftarrow"  "\\xleftarrow"  "\\min")))
  (add-to-list 'cdlatex-math-symbol-alist '(?> ("\\rightarrow" "\\xrightarrow" "\\max")))
  (add-to-list 'cdlatex-math-symbol-alist '(?* ("\\times"      "\\circ"        "\\otimes"))))

(defun pyim-probe-math-environment ()
  "Within LaTeX environment, should switch to Chinese. "
  (and (derived-mode-p 'org-mode)
       (org-inside-LaTeX-fragment-p)))

(defun setup-org-pyim-probe ()
  (setq-local pyim-english-input-switch-functions
              `(pyim-probe-previous-azAZ
                pyim-probe-math-environment
                pyim-probe-org-src-block
                ,@pyim-english-input-switch-functions)))

(defvar org-prettify-symbols-alist
  '(("#+BEGIN_SRC" . "┏")
    ("#+END_SRC"   . "┗")
    ("#+begin_src" . "┏")
    ("#+end_src"   . "┗")
    ("->"          . "→")
    ("<-"          . "←"))
  "`prettify-symbols-alist' for org mode. ")

(defun setup-org-prettify-symbol-mode ()
  "Setup Org prettify symbol. "
  (setq-local prettify-symbols-alist
              (append prettify-symbols-alist
                      org-prettify-symbols-alist))
  (prettify-symbols-mode 1))

(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode))

(use-package org
  :ensure t
  :custom (;; Ref: https://sophiebos.io/posts/prettifying-emacs-org-mode/
           ;; Ref: https://mstempl.netlify.app/post/beautify-org-mode/
           ;; Ref: https://emacs-china.org/t/org/19458/
           (org-pretty-entities                          t)
           (org-pretty-entities-include-sub-superscripts nil)
           (prettify-symbols-unprettify-at-point        'right-edge)
           (org-hide-emphasis-markers                   t)

           (org-src-fontify-natively          t)
           (org-src-tab-acts-natively         t)
           (org-edit-src-content-indentation  2)
           (org-image-actual-width            nil)
           
           (org-latex-compiler                "xelatex")
           (org-preview-latex-default-process 'xelatex)
           (org-latex-pdf-process
            '("xelatex -interaction nonstopmode -output-directory %o %f"
              "bibtex %f"
              "xelatex -interaction nonstopmode -output-directory %o %f"
              "xelatex -interaction nonstopmode -output-directory %o %f")))
  :hook   ((org-babel-after-execute . org-display-inline-images)
           (org-mode                . setup-latex-prettify-symbol-mode)
           (org-mode                . setup-org-prettify-symbol-mode)
           (org-mode                . setup-org-pyim-probe)
           (org-mode                . org-num-mode)))


;;;; custom file

(load custom-file t) ;; no error

(provide 'init)

;;;; init.el ends here
