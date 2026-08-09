;; =========================================================
;; Emacs configuration
;; Linux / GUI-first / mouse-friendly setup
;; =========================================================

;; ---------------------------------------------------------
;; Basic GUI / editing behavior
;; ---------------------------------------------------------

(setq-default cursor-type 'bar)

(global-hl-line-mode 1)
(global-display-line-numbers-mode 1)
(blink-cursor-mode 0)

(setq scroll-conservatively 101
scroll-margin 3
mouse-wheel-scroll-amount '(3 ((shift) . 1))
mouse-wheel-progressive-speed nil)

(delete-selection-mode 1)

(setq case-fold-search t)

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

;; ---------------------------------------------------------
;; macOS keyboard behavior
;; ---------------------------------------------------------

;; Command = Super
;; Option  = Meta

(setq mac-command-modifier 'super
      mac-option-modifier 'meta)


;; ---------------------------------------------------------
;; Familiar macOS editing shortcuts
;; ---------------------------------------------------------

(global-set-key (kbd "s-c") #'kill-ring-save)
(global-set-key (kbd "s-v") #'yank)
(global-set-key (kbd "s-x") #'kill-region)
(global-set-key (kbd "s-a") #'mark-whole-buffer)
(global-set-key (kbd "s-f") #'isearch-forward)
(global-set-key (kbd "s-r") #'replace-string)

;; ---------------------------------------------------------
;; Mouse behavior
;; ---------------------------------------------------------

(global-set-key [mouse-3] #'context-menu-open)

;; ---------------------------------------------------------
;; Package management
;; ---------------------------------------------------------

(require 'package)

(setq package-archives
'(("gnu"   . "https://elpa.gnu.org/packages/")
("melpa" . "https://melpa.org/packages/")))

(package-initialize)

(unless package-archive-contents
(package-refresh-contents))

(unless (package-installed-p 'use-package)
(package-install 'use-package))

(eval-when-compile
(require 'use-package))

(setq use-package-always-ensure t)

;; ---------------------------------------------------------
;; File/project sidebar
;; ---------------------------------------------------------
(use-package treemacs
:ensure t
:bind
("C-t" . treemacs)
:config
(setq treemacs-width 60
treemacs-is-never-other-window t))

;; ---------------------------------------------------------
;; Project support
;; ---------------------------------------------------------

(require 'project)

;; ---------------------------------------------------------
;; Appearance
;; ---------------------------------------------------------

;; (load-theme 'wombat t)

;; Linux-friendly monospace font.
;;
;; JetBrains Mono is commonly available and is a good choice
;; for C#/Unity development.
;;
;; If you don't have it, replace this with a font you have
;; installed, e.g. "DejaVu Sans Mono" or "Iosevka".

(use-package doom-themes
  :ensure t
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;; for treemacs users
  (doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  :config
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
;;   (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (nerd-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(set-face-attribute 'default nil
:family "MartianMono Nerd Font"
:height 140)

;; (set-face-attribute 'cursor nil
;; :background "white")
;;
;; (set-face-attribute 'hl-line nil
;; :background "#2a2a2a")

;; ---------------------------------------------------------
;; File tabs
;; ---------------------------------------------------------

(global-tab-line-mode 1)

(setq tab-line-close-button-show t
tab-line-new-button-show t
tab-line-separator " ")

(setq tab-line-exclude-modes
'(treemacs-mode
special-mode))

;; ---------------------------------------------------------
;; Window layout history
;; ---------------------------------------------------------

(winner-mode 1)

;; ---------------------------------------------------------
;; Modern completion UI
;; ---------------------------------------------------------

(use-package vertico
:init
(vertico-mode 1))

(use-package orderless
:custom
(completion-styles '(orderless basic))
(completion-category-defaults nil)
(completion-category-overrides
'((file (styles basic partial-completion)))))

(use-package marginalia
:init
(marginalia-mode 1))

(use-package consult
:bind
(("s-p" . consult-buffer)
("s-o" . consult-find)
("s-g" . consult-ripgrep)))

;; ---------------------------------------------------------
;; Multiple cursors
;; ---------------------------------------------------------

(use-package multiple-cursors
:ensure t)

;; ---------------------------------------------------------
;; Mouse-driven multiple cursors
;; ---------------------------------------------------------

(defun my-mc-middle-drag-start (event)
"Start selecting lines with the middle mouse button."
(interactive "e")
(mouse-drag-region event))

(defun my-mc-middle-drag-end (event)
"Finish selection and schedule multiple cursors."
(interactive "e")
(mouse-set-region event)

;; Run mc/edit-lines after this command has completely
;; finished, so multiple-cursors doesn't mistake the
;; mouse command itself for an MC editing command.
(when (use-region-p)
(run-at-time
0 nil
(lambda ()
(when (use-region-p)
(mc/edit-lines))))))

(with-eval-after-load 'multiple-cursors
(add-to-list 'mc/cmds-to-run-once
#'my-mc-middle-drag-end)

(setq mc/cmds-to-run-for-all
(remove #'my-mc-middle-drag
mc/cmds-to-run-for-all)))

(global-set-key [down-mouse-2] #'my-mc-middle-drag-start)
(global-set-key [drag-mouse-2] #'my-mc-middle-drag-end)

;; ---------------------------------------------------------
;; Cancel multiple cursors with left click
;; ---------------------------------------------------------

(defun my-mouse-drag-region (event)
"Cancel multiple cursors, then perform normal mouse selection."
(interactive "e")

(when (bound-and-true-p multiple-cursors-mode)
(multiple-cursors-mode -1))

(mouse-drag-region event))

(global-set-key [down-mouse-1] #'my-mouse-drag-region)

;; ---------------------------------------------------------
;; C# / Unity language server
;; ---------------------------------------------------------

(require 'eglot)

(add-to-list
'eglot-server-programs
'(csharp-mode . ("csharp-ls")))

(add-hook 'csharp-mode-hook #'eglot-ensure)

;; ---------------------------------------------------------
;; C# completion popup
;; ---------------------------------------------------------

(use-package corfu
:ensure t
:custom
(corfu-auto t)
(corfu-auto-delay 0.2)
(corfu-auto-prefix 1)
:init
(global-corfu-mode))

;; ---------------------------------------------------------
;; C# / Unity editing
;; ---------------------------------------------------------

(electric-pair-mode 1)

;; ---------------------------------------------------------
;; C# Allman braces
;; ---------------------------------------------------------

(defun my-csharp-allman-braces ()
"Configure C# opening braces in Allman style."

;; Make a fresh local copy rather than modifying the global
;; c-hanging-braces-alist.
(setq-local
c-hanging-braces-alist
(copy-tree c-hanging-braces-alist))

;; Remove the existing substatement rule.
(setq-local
c-hanging-braces-alist
(assq-delete-all
'substatement-open
c-hanging-braces-alist))

;; Opening braces go on their own line.
(push '(substatement-open before after)
c-hanging-braces-alist))

(add-hook 'csharp-mode-hook #'my-csharp-allman-braces)

;; ---------------------------------------------------------
;; Custom variables
;; ---------------------------------------------------------

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(doom-monokai-classic))
 '(custom-safe-themes
   '("c9d837f562685309358d8dc7fccb371ed507c0ae19cf3c9ae67875db0c038632"
     default))
 '(package-selected-packages
   '(consult corfu doom-themes marginalia multiple-cursors nerd-icons
	     orderless treemacs vertico)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; ---------------------------------------------------------
;; Git
;; ---------------------------------------------------------
(use-package magit
:ensure t)
