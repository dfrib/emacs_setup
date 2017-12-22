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
;; cask
(require 'cask "~/.cask/cask.el")
(cask-initialize)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-mode-alist adjustments
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cask
(add-to-list 'auto-mode-alist '("Cask" . cask-mode))

;; C++
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cc\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cpp\\'" . c++-mode))

;; CMake
(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-mode))
(add-to-list 'auto-mode-alist '("\\.cmake\\'" . cmake-mode))

;; Docker
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

;; PlantUML
(add-to-list 'auto-mode-alist '("\\.plantuml\\'" . plantuml-mode))

;; Protobuf
(add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-mode))

;; Protobuf
(add-to-list 'auto-mode-alist '("\\.swift\\'" . swift-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cmake ide & rtags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'rtags)

;; set path to project build directory
(setq cmake-ide-build-dir
      (expand-file-name "~/opensource/rtags/build"))
;; CURRENTLY: hardcode to build dir of default project
;; TODO: fix via .dir-locals.el

;; set path to rtag executables
(setq rtags-path
      (expand-file-name "~/opensource/rtags/build"))

;; invoke cmake-ide setup
(cmake-ide-setup)

;; start the rdm process unless the process is already running.
;; (I prefer to launch rdm externally and prior to Emacs)
;(rtags-start-process-unless-running)

;; Enable rtags-diagnostics.
(setq rtags-autostart-diagnostics t)
(rtags-diagnostics)

;; Enable code completion in Emacs with rtags & company mode.
;-> use irony for completions

;; Enable completions in rtags.
;(setq rtags-completions-enabled t)
;-> use irony for completions

;; Enable company mode
;(require 'company)
;(global-company-mode)
;-> use irony for completions

;; Add company-rtags to company-backends
;(push 'company-rtags company-backends)
;-> use irony for completions

;; Timeout for reparse on onsaved buffers
(rtags-set-periodic-reparse-timeout 0.5)

;; Rtags standard keybindings ([M-. on symbol to go to bindings])
(rtags-enable-standard-keybindings)

;; Custom keybindings
(global-set-key (kbd "<home>") 'rtags-find-symbol-at-point)
(global-set-key (kbd "<prior>") 'rtags-location-stack-back)
(global-set-key (kbd "<next>") 'rtags-location-stack-forward)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; flycheck-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; color model line
(require 'flycheck-color-mode-line)
(with-eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))

;; show pos-tip popups for errors
(with-eval-after-load 'flycheck
  (flycheck-pos-tip-mode))

;; rtags with Flycheck (syntax checking)
(require 'flycheck-rtags)
(defun my-flycheck-rtags-setup ()
  (flycheck-select-checker 'rtags)
  (setq-local flycheck-highlighting-mode nil) ;; RTags creates more accurate overlays.
  (setq-local flycheck-check-syntax-automatically nil))
(add-hook 'c-mode-hook #'my-flycheck-rtags-setup)
(add-hook 'c++-mode-hook #'my-flycheck-rtags-setup)
(add-hook 'objc-mode-hook #'my-flycheck-rtags-setup)

;; flycheck-plantuml
(with-eval-after-load 'flycheck
  (require 'flycheck-plantuml)
  (flycheck-plantuml-setup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; irony (C/C++ minor mode powered by libclang) and company for completions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
;(add-hook 'objc-mode-hook 'irony-mode)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;; Enable company mode
(require 'company)
(global-company-mode)

;; company-irony
(require 'company-irony-c-headers)
;; Load with `irony-mode` as a grouped backend
(eval-after-load 'company
  '(add-to-list
    'company-backends '(company-irony-c-headers company-irony)))

;; (eval-after-load 'company
;;   '(add-to-list 'company-backends 'company-irony))

;; (optional) adds CC special commands to `company-begin-commands' in order to
;; trigger completion at interesting places, such as after scope operator
;;     std::|
(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clang-format
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clang-format can be triggered using C-M-tab
(require 'clang-format)
(global-set-key [C-M-tab] 'clang-format-region)
;; If the repo does not have a .clang-format files, one can
;; be created using google style:
;; clang-format -style=google -dump-config > .clang-format
;; In this, default indent is 2 (see 'IndentWidth' key in generated file).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C/C++ mode
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

;; ;; also toggle on auto-newline and hungry delete minor modes
;; (defun my-c++-mode-hook ()
;;   (c-set-style "my-style")        ; use my-style defined above
;;   (auto-fill-mode)
;;   (c-toggle-auto-hungry-state 1))


(add-hook 'c++-mode-hook 'my-c++-mode-hook)

;; Autoindent using google style guide
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ivy-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(ivy-mode)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)

;; Ivy integration with rtags
;(setq rtags-display-result-backend 'ivy)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; counsel keyboard mappings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'ag)
(global-set-key (kbd "<f9>") 'counsel-load-theme) ;; Quick theme selection.
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "<f6>") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-x g") 'magit-status)
(define-key read-expression-map (kbd "C-r") 'counsel-expression-history)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; drag stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(drag-stuff-global-mode 1)
(drag-stuff-define-keys)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; expand region
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'expand-region)
(global-set-key (kbd "C-q") 'er/expand-region)
; overwrite binding to insert non-graphic characters (I never use that)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; idle highlight mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun idle-highlight-mode-hook ()
  (make-local-variable 'column-number-mode)
  (column-number-mode t)
  (idle-highlight-mode t))

(add-hook 'emacs-lisp-mode-hook 'idle-highlight-mode-hook)
(add-hook 'c-mode-common-hook 'idle-highlight-mode-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; babel & PlantUML
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; active Org-babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '(;; other Babel languages
   (plantuml . t)))

;; point to plantuml jar
(setq org-plantuml-jar-path
      (expand-file-name "~/opensource/plantuml/plantuml.jar"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; smart mode line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(setq sml/theme 'dark)
(setq sml/theme 'powerline)
(setq sml/no-confirm-load-theme t)
(sml/setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IBuffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; http://martinowen.net/blog/2010/02/03/tips-for-emacs-ibuffer.html
; http://ergoemacs.org/emacs/emacs_buffer_management.html
; http://stackoverflow.com/questions/1231188/emacs-list-buffers-behavior

; Use IBuffer instead for buffer list
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Bind other-window (and custom prev-window) to more accessible keys
;; -----------------
(global-set-key (kbd "C-'") 'other-window)
(global-set-key (kbd "C-;") 'prev-window)
(defun prev-window ()
  (interactive)
  (other-window -1))

;; define IBuffer filter modes
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

;; load filter
(add-hook 'ibuffer-mode-hook
	  '(lambda ()
	     (ibuffer-switch-to-saved-filter-groups "home")))

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
;;; theme
(load-theme 'spolsky t)

;;; font
(set-frame-font "Meslo LG M DZ for Powerline-10" nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The End
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
