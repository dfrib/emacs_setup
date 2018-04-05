;;; init.el --- dfrib:s Emacs init
;;; Commentary:
;;; ------------------------------------------------------------------------ ;;;
;;; Code:

;; -------------------------------------------------------------------------- ;;
;; MELPA
(require 'package)
(add-to-list 'package-archives
             ;'("melpa" . "https://melpa.org/packages/") t)
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; -------------------------------------------------------------------------- ;;
;; cask - packet management
(require 'cask "~/.cask/cask.el")
(cask-initialize)

;; -------------------------------------------------------------------------- ;;
;; use-package
(require 'use-package)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic behaviour and appearance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; show trailing spaces
(setq-default show-trailing-whitespace t)

;; set tabs to indent as white spaces and set default tab width to 4 white spaces
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
;(setq-default indent-line-function 'insert-tab)

;; setup: M-y saves the new yank to the clipboard.
(setq yank-pop-change-selection t)

(show-paren-mode 1)
(setq column-number-mode t)

;; minimalistic Emacs at startup
(menu-bar-mode 0)
(tool-bar-mode 0)
(set-scroll-bar-mode nil)

;; don't use global line highlight mode
(global-hl-line-mode 0)

;; supress welcome screen
(setq inhibit-startup-message t)

;; Bind other-window (and custom prev-window) to more accessible keys.
(defun prev-window ()
  (interactive)
  (other-window -1))
(global-set-key (kbd "C-'") 'other-window)
(global-set-key (kbd "C-;") 'prev-window)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; major modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cask
(use-package cask-mode
  :mode "Cask"
  )

;; C++
(use-package c++-mode
  :after rtags
  :mode (("\\.h\\'" . c++-mode)
         ("\\.cc\\'" . c++-mode)
         ("\\.cpp\\'" . c++-mode))
  :bind (:map c++-mode-map
              ("<home>" . 'rtags-find-symbol-at-point)
              ("<prior>" . 'rtags-location-stack-back)
              ("<next>" . 'rtags-location-stack-forward))
  )

;; CMake
(use-package cmake-mode
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode))
  :init (setq cmake-tab-width 4)
  )

;; Docker
(use-package dockerfile-mode
  :mode "Dockerfile.*\\'"
  )

;; PlantUML
(use-package plantuml-mode
  :mode "\\.plantuml\\'"
  :config (setq plantuml-jar-path
                (expand-file-name "~/opensource/plantuml/plantuml.jar"))
  )

;; Protobuf
(use-package protobuf-mode
  :mode "\\.proto\\'"
  )

;; Swift
(use-package swift-mode
  :mode "\\.swift\\'"
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rtags & cmake ide
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package rtags
  :config
  ;; Set path to rtag executables.
  (setq rtags-path
        (expand-file-name "~/opensource/rtags/build"))
  ;;
  ;; Start the rdm process unless the process is already running.
  ;; --> Launch rdm externally and prior to Emacs instead.
  ;; (rtags-start-process-unless-running)
  ;;
  ;; Enable rtags-diagnostics.
  (setq rtags-autostart-diagnostics t)
  (rtags-diagnostics)
  ;;
  ;; Timeout for reparse on onsaved buffers.
  (rtags-set-periodic-reparse-timeout 0.5)
  ;;
  ;; Rtags standard keybindings ([M-. on symbol to go to bindings]).
  (rtags-enable-standard-keybindings)
  ;;
  ;; Enable completions in with rtags & company mode
  ;; -> use irony for completions
  ;;(setq rtags-completions-enabled t)
  ;;(require 'company)
  ;;(global-company-mode)
  ;;(push 'company-rtags company-backends) ; Add company-rtags to company-backends
  ;;
  )

(use-package cmake-ide
  :after rtags
  :config
  ;; set path to project build directory
  (setq cmake-ide-build-dir
        (expand-file-name "~/src/stringent/build"))
  ;; CURRENTLY: hardcode to build dir of default project
  ;; TODO: fix via .dir-locals.el
  ;;
  ;; invoke cmake-ide setup
  (cmake-ide-setup)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; flycheck-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package flycheck
  :init (global-flycheck-mode)
  )

;; Color mode line for errors.
(use-package flycheck-color-mode-line
  :after flycheck
  :config '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode)
  )

;; Show pos-tip popups for errors.
(use-package flycheck-pos-tip
  :after flycheck
  :config (flycheck-pos-tip-mode)
  )

;; Flycheck rtags.
(use-package flycheck-rtags
  :after rtags
  :config
  (defun my-flycheck-rtags-setup ()
    (flycheck-select-checker 'rtags)
    (setq-local flycheck-highlighting-mode nil) ;; RTags creates more accurate overlays.
    (setq-local flycheck-check-syntax-automatically nil))
  (add-hook 'c-mode-hook #'my-flycheck-rtags-setup)
  (add-hook 'c++-mode-hook #'my-flycheck-rtags-setup)
  (add-hook 'objc-mode-hook #'my-flycheck-rtags-setup))

;; Flycheck-plantuml/
(use-package flycheck-plantuml
  :after flycheck
  :config (flycheck-plantuml-setup)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; irony (C/C++ minor mode powered by libclang) and company for completions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package irony
  :config
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  (defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  )

;; Company mode.
(use-package company
  :config (global-company-mode)
  )

;; company-irony.
(use-package company-irony
  :after company
  :config (global-company-mode)
  ;; (optional) adds CC special commands to `company-begin-commands' in order to
  ;; trigger completion at interesting places, such as after scope operator
  ;;     std::|
  (add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
  )

;; Company-mode backend for C/C++ header files that works with irony-mode.
;; Complementary to company-irony by offering completion suggestions to header files.
(use-package company-irony-c-headers
  :after company-irony
  :config
  ;; Load with `irony-mode` as a grouped backend
  (eval-after-load 'company
  '(add-to-list
    'company-backends '(company-irony-c-headers company-irony)))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clang-format
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clang-format can be triggered using C-M-tab
(use-package clang-format
  :config (global-set-key [C-M-tab] 'clang-format-region)
  )

;; If the repo does not have a .clang-format files, one can
;; be created using google style:
;; clang-format -style=google -dump-config > .clang-format
;; In this, default indent is 2 (see 'IndentWidth' key in generated file).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C/C++ mode modifications
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'c-mode-common-hook 'google-set-c-style)

;; use google style but modify offset to 4 (default for google is 2)
(c-add-style "my-style"
	     '("google"
	       (c-basic-offset . 4)            ; indent by four spaces
	       ))

;; also toggle on auto-newline and hungry delete minor modes
(defun my-c++-mode-hook ()
  (c-set-style "my-style")        ; use my-style defined above
  (auto-fill-mode))

(add-hook 'c++-mode-hook 'my-c++-mode-hook)

;; Autoindent using google style guide
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; elpy (python IDE-ish features)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package elpy
  :after company flycheck
  :init (defun goto-def-or-rgrep ()
          "Go to definition of thing at point or do an rgrep in project if that fails"
          (interactive)
          (condition-case nil (elpy-goto-definition)
            (error (elpy-rgrep-symbol (thing-at-point 'symbol)))))
  ;; Custom keybindings.
  :bind (:map elpy-mode-map
              ("<home>" . 'goto-def-or-rgrep)
              ("<prior>" . 'pop-tag-mark)
              ("<next>" . 'elpy-goto-definition))
  :config
  (elpy-enable)
  ;; Use flycheck not flymake with elpy.
  (when (require 'flycheck nil t)
    (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
    (add-hook 'elpy-mode-hook 'flycheck-mode))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ivy-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ivy
  :config
  (ivy-mode)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  ;; Ivy integration with rtags.
  ;;(setq rtags-display-result-backend 'ivy)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; counsel keyboard mappings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ag)
(use-package magit)
(use-package git-commit
  ;; Limit commit message summary to 50 columns, and wrap content after 72 columns.
  :init (add-hook 'git-commit-mode-hook
                  '(lambda ()
                     (setq-local git-commit-summary-max-length 50)
                     (setq-local fill-column 72)))
  )
(use-package counsel
  :after ag ivy magit
  :bind (("<f9>" . 'counsel-load-theme)
         ("\C-s" . 'swiper)
         ("C-c C-r" . 'ivy-resume)
         ("<f6>" . 'ivy-resume)
         ("M-x" . 'counsel-M-x)
         ("C-x C-f" . 'counsel-find-file)
         ("<f1> f" . 'counsel-describe-function)
         ("<f1> v" . 'counsel-describe-variable)
         ("<f1> l" . 'counsel-find-library)
         ("<f2> i" . 'counsel-info-lookup-symbol)
         ("<f2> u" . 'counsel-unicode-char)
         ("C-c g" . 'counsel-git)
         ("C-c j" . 'counsel-git-grep)
         ("C-c k" . 'counsel-ag)
         ("C-x l" . 'counsel-locate)
         ("C-x g" . 'magit-status)
         ("C-r" . 'counsel-minibuffer-history))
  :init (setq counsel-git-grep-skip-counting-lines t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; drag stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package drag-stuff
  :config
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; expand region
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package expand-region
  ;; Overwrite binding to insert non-graphic characters (I never use that).
  :bind ("C-q" . 'er/expand-region)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; idle highlight mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package idle-highlight-mode
  :config
  (defun idle-highlight-mode-hook ()
    (make-local-variable 'column-number-mode)
    (column-number-mode t)
    (idle-highlight-mode t))
  (add-hook 'emacs-lisp-mode-hook 'idle-highlight-mode-hook)
  (add-hook 'c-mode-common-hook 'idle-highlight-mode-hook)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package org
  :config
  ;; babel & PlantUML
  ;; Activate Org-babel languages.
  (org-babel-do-load-languages
   'org-babel-load-languages
   '(;; other Babel languages
     (plantuml . t)))
  ;; Point to plantuml jar.
  (setq org-plantuml-jar-path
        (expand-file-name "~/opensource/plantuml/plantuml.jar"))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; smart mode line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package smart-mode-line)
(use-package smart-mode-line-powerline-theme
  :after smart-mode-line
  :config
  (setq sml/theme 'powerline)
  (setq sml/no-confirm-load-theme t)
  (sml/setup)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IBuffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; http://martinowen.net/blog/2010/02/03/tips-for-emacs-ibuffer.html
; http://ergoemacs.org/emacs/emacs_buffer_management.html
; http://stackoverflow.com/questions/1231188/emacs-list-buffers-behavior
(use-package ibuffer
  :bind ("C-x C-b" . 'ibuffer)
  :config
  ;; Define IBuffer filter modes.
  (setq ibuffer-saved-filter-groups
        '(("home"
           ("emacs-config" (or (filename . ".emacs.d")
                               (filename . "emacs-config")))
           ("Org" (or (mode . org-mode)
                      (filename . "OrgMode")))
           ("code" (filename . "src"))
           ("Magit" (name . "\*magit\*"))
           ("Help" (or (name . "\*Help\*")
                       (name . "\*Apropos\*")
                       (name . "\*info\*"))))))

  ;; Load filter.
  (add-hook 'ibuffer-mode-hook
            '(lambda ()
               (ibuffer-switch-to-saved-filter-groups "home")))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; comint-mode & shell-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Changed a default colour to "dodger blue" to make ls colours easier to see.
;; (setq ansi-color-faces-vector [default bold default italic underline success warning error])
(setq ansi-color-names-vector ["black" "red3" "green3" "yellow3" "dodger blue" "olive drab" "cyan3" "gray90"])

;; Prevent inheriting of minibuffer-prompt's face. Gives better shell prompt colors.
(set-face-attribute 'comint-highlight-prompt nil ':inherit 'unspecified)

;; Prevent having to enter passwords in plain text.
(setq comint-password-prompt-regexp
      (concat comint-password-prompt-regexp
              "\\|^Password .*:\\s *\\'"))

;; track shell directory when using shell in emacs (by inspecting procfs)
;; https://www.emacswiki.org/emacs/ShellDirtrackByProcfs
(defun track-shell-directory/procfs ()
  "Write docstring here."
  (shell-dirtrack-mode 0)
  (add-hook 'comint-preoutput-filter-functions
            (lambda (str)
              (prog1 str
                (when (string-match comint-prompt-regexp str)
                  (cd (file-symlink-p
                       (format "/proc/%s/cwd" (process-id
                                               (get-buffer-process
                                                (current-buffer)))))))))
            nil t))

(add-hook 'shell-mode-hook (lambda () (setq show-trailing-whitespace nil)))
(add-hook 'shell-mode-hook 'track-shell-directory/procfs)

;; set scroll behaviour similar to linux shell
;; http://stackoverflow.com/questions/6780468/emacs-m-x-shell-and-the-overriding-of-bash-keyboard-bindings
(remove-hook 'comint-output-filter-functions
             'comint-postoutput-scroll-to-bottom)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Themes & visual behaviour
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package sublime-themes
  :config
  (load-theme 'spolsky t)
  (set-frame-font "Meslo LG M DZ for Powerline-10" nil t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The End
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'init)
;;; init.el ends here
