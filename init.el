;; -*- lexical-binding: t; -*-

;; =========================================================
;; Emacs configuration
;; Linux/MacOS / GUI-first / mouse-friendly setup
;; =========================================================

;; ---------------------------------------------------------
;; Basic GUI / editing behavior
;; ---------------------------------------------------------

(setq desktop-save t)
(setq desktop-load-locked-desktop 'check-pid)

(tool-bar-mode -1)

(setq-default cursor-type 'bar)

(global-hl-line-mode 1)
(global-display-line-numbers-mode 1)
(blink-cursor-mode 0)

(setq scroll-conservatively 101
  scroll-margin 3
  mouse-wheel-scroll-amount '(3 ((shift) . hscroll))
  mouse-wheel-progressive-speed nil)

(setq mouse-wheel-tilt-scroll t)

(setq-default truncate-lines t)

(setq mouse-wheel-scroll-amount-horizontal 4)

(delete-selection-mode 1)

(setq case-fold-search t)

(global-auto-revert-mode 1)

(column-number-mode 1)

;; ---------------------------------------------------------
;; configuring keybinds depending on current OS
;; ---------------------------------------------------------

(when (eq system-type 'darwin)
  ;;macOS
  (setq mac-command-modifier 'super
      mac-option-modifier 'meta)
  )

(when (eq system-type 'gnu/linux)
  ;;linux
  (setq x-super-keysym 'meta)
  (setq x-meta-keysym 'super))

;; ---------------------------------------------------------
;; Familiar editing shortcuts
;; ---------------------------------------------------------

(global-set-key (kbd "s-c") #'kill-ring-save)
(global-set-key (kbd "s-v") #'yank)
(global-set-key (kbd "s-x") #'kill-region)
(global-set-key (kbd "s-a") #'mark-whole-buffer)
(global-set-key (kbd "s-f") #'isearch-forward)
(global-set-key (kbd "s-r") #'query-replace)
(global-set-key (kbd "s-z") #'undo)
(global-set-key (kbd "s-s") #'save-buffer)

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
  (setq treemacs-is-never-other-window t
      treemacs-width-is-initially-locked nil
      treemacs-width 20
      treemacs-position 'left)
  (require 'treemacs-mouse-interface)
  (add-hook 'treemacs-post-buffer-init-hook
          (lambda ()
            (let ((win (treemacs-get-local-window)))
              (when (and win (window-live-p win))
                (set-window-scroll-bars win nil nil)))))
  
  (defun my-treemacs-ignore-meta-files-p (filename _path)
    (string-suffix-p ".meta" filename))

  (add-to-list 'treemacs-ignored-file-predicates #'my-treemacs-ignore-meta-files-p)

  (defun my-treemacs-toggle-meta-files ()
  (interactive)
    (if (memq #'my-treemacs-ignore-meta-files-p treemacs-ignored-file-predicates)
      (setq treemacs-ignored-file-predicates
            (delq #'my-treemacs-ignore-meta-files-p treemacs-ignored-file-predicates))
    (add-to-list 'treemacs-ignored-file-predicates #'my-treemacs-ignore-meta-files-p))
  (dolist (buf (buffer-list))
    (when (with-current-buffer buf (derived-mode-p 'treemacs-mode))
      (with-current-buffer buf
        (treemacs--do-refresh (current-buffer) 'all))))
  (message "Unity .meta files are now %s in treemacs."
           (if (memq #'my-treemacs-ignore-meta-files-p treemacs-ignored-file-predicates)
               "hidden" "visible")))
  (add-hook 'treemacs-mode-hook
          (lambda ()
            (display-line-numbers-mode -1)))
  
  :hook (emacs-startup . treemacs))

;; ---------------------------------------------------------
;; Project support
;; ---------------------------------------------------------

(require 'project)

;; ---------------------------------------------------------
;; Appearance
;; ---------------------------------------------------------

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(set-face-attribute 'default nil
:family "MartianMono Nerd Font"
:height 140)

(setq window-divider-default-right-width 4)
(window-divider-mode 1)

;; ---------------------------------------------------------
;; File tabs
;; ---------------------------------------------------------

(use-package centaur-tabs
  :demand
  :config
  (centaur-tabs-mode t)
  :bind
  ("C-<tab>" . centaur-tabs-forward)
  ("s-w" . kill-current-buffer)
  :hook
  (treemacs-mode . centaur-tabs-local-mode))

(centaur-tabs-headline-match)
(setq centaur-tabs-style "bar")
(setq centaur-tabs-icon-type 'nerd-icons)
(setq centaur-tabs-set-icons t)
(setq centaur-tabs-set-modified-marker t)

(defun my-centaur-tabs-buffer-groups ()
  (list
   (cond    ((derived-mode-p 'magit-mode) "Magit")
    ((string-match-p "magit" (buffer-name)) "Magit")
    ((derived-mode-p 'treemacs-mode) "Treemacs")
    ((string-match-p "Treemacs" (buffer-name)) "Treemacs")
    ((string-match-p "*Messages*" (buffer-name)) "Messages")
    ((string-match-p "*scratch*" (buffer-name)) "Scratch")
    ((string-match-p "*Warnings*" (buffer-name)) "Warnigs")
    ((string-match-p ".*eglot.*events.*" (buffer-name)) "Eglot")
    ((string-match-p "*lsp-log*" (buffer-name)) "LSP")
    ((string-match-p "*csharp-ls::stderr*" (buffer-name)) "LSP")
    ((string-match-p "*csharp-ls*" (buffer-name)) "LSP")
    ((string-match-p "*xref*" (buffer-name)) "LSP")
    (t "General"))))

(setq centaur-tabs-buffer-groups-function #'my-centaur-tabs-buffer-groups)

(setq centaur-tabs-cycle-scope 'tabs)

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
(interactive "e")
(mouse-drag-region event))

(defun my-mc-middle-drag-end (event)
(interactive "e")
(mouse-set-region event)

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
(interactive "e")

(when (bound-and-true-p multiple-cursors-mode)
(multiple-cursors-mode -1))

(mouse-drag-region event))

(global-set-key [down-mouse-1] #'my-mouse-drag-region)

;; ---------------------------------------------------------
;; C# / Unity language server
;; ---------------------------------------------------------

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-csharp-server 'roslyn)
  (setq lsp-semantic-tokens-enable t)

  :hook
  ((csharp-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration))

  :commands lsp

  :config
  (defun my-lsp-lens-click-find-references (orig-fn command? &rest args)
    (let* ((cmd (lsp:command-command command?))
           (cmd-args (lsp:command-arguments? command?)))
      (if (and (string-equal cmd "textDocument/references")
               (>= (length cmd-args) 1))
          (lambda ()
            (interactive)
            (let ((params (aref cmd-args 0)))
              (lsp-show-xrefs
               (lsp--locations-to-xref-items
                (lsp-request "textDocument/references" params))
               nil t)))
        (apply orig-fn command? args))))

  (advice-add 'lsp-lens--create-interactive-command
              :around
              #'my-lsp-lens-click-find-references))

(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
(use-package dap-mode)

(use-package which-key
    :config
    (which-key-mode))

(add-to-list 'load-path (expand-file-name "lib/lsp-mode" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lib/lsp-mode/clients" user-emacs-directory))


;; ---------------------------------------------------------
;; C# completion popup
;; ---------------------------------------------------------

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0)
  (corfu-auto-prefix 1)
  :init
  (global-corfu-mode))

;; ---------------------------------------------------------
;; C# / Unity editing
;; ---------------------------------------------------------

(electric-pair-mode 1)

(defun my-electric-pair-inhibit (char)
  (and (not (eobp))
       (not (memq (char-after) '(?\s ?\t ?\n ?\r)))))

(setq-default electric-pair-inhibit-predicate
              #'my-electric-pair-inhibit)

(add-hook 'csharp-mode-hook
          (lambda ()
            (setq c-basic-offset 4)
            (setq c-auto-newline t)
            (c-set-offset 'defun-open 0)
            (c-set-offset 'block-open 0)
            (c-set-offset 'inline-open 0)
            (c-set-offset 'substatement-open 0)
            (setq c-hanging-braces-alist
                  '((defun-open before after)
                    (defun-close before)
                    (block-open before after)
                    (block-close before)
                    (inline-open before after)
                    (substatement-open before after)
                    (statement-case-open before after)))))

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
 '(minimap-dedicated-window nil)
 '(minimap-mode t)
 '(package-selected-packages
   '(centaur-tabs consult corfu dap-mode doom-themes drag-stuff
		  exec-path-from-shell lsp-mode lsp-treemacs lsp-ui
		  magit marginalia multiple-cursors nerd-icons
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
  :ensure t
  :bind ("C-x g" . magit-status))

;; ---------------------------------------------------------
;; Nerd Icons
;; ---------------------------------------------------------

(use-package nerd-icons
:ensure t)

;; ---------------------------------------------------------
;; Commenting lines with M-/
;; ---------------------------------------------------------

(global-set-key (kbd "s-/") #'comment-line)

;; ---------------------------------------------------------
;; Reload config (evaluate-buffer) with M-S-r
;; ---------------------------------------------------------

(global-set-key (kbd "M-~") #'eval-buffer)

;; ---------------------------------------------------------
;; Loading PATH config from shell on launch
;; ---------------------------------------------------------

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (or (daemonp) (memq window-system '(mac ns x pgtk)))
    (setq exec-path-from-shell-shell-name
          (or (getenv "SHELL")
              (executable-find "fish")
              (executable-find "zsh")
              shell-file-name))
    (exec-path-from-shell-initialize)))

;; ---------------------------------------------------------
;; Moving lines/regions up/down with s-<up>/s-<down>
;; ---------------------------------------------------------

(use-package drag-stuff
  :ensure t
  :bind (("s-<up>" . drag-stuff-up)
	 ("s-<down>" . drag-stuff-down)))

;; ---------------------------------------------------------
;; Buffer snapping (s-\ toggle)
;; ---------------------------------------------------------

(defvar my-snapped-window nil
  "Window created by `my-snap-buffer', if any.")

(defun my-snap-buffer ()
  (interactive)
  (if (and my-snapped-window (window-live-p my-snapped-window))
      (let ((buf (window-buffer my-snapped-window)))
        (delete-window my-snapped-window)
        (set-window-buffer (selected-window) buf)
        (setq my-snapped-window nil))
    (let* ((buf (current-buffer))
           (win (selected-window)))
      (setq my-snapped-window (split-window-right))
      (set-window-buffer my-snapped-window buf)
      (let ((prev (switch-to-prev-buffer win)))
        (unless (and prev (not (eq prev buf)))
          (set-window-buffer win (other-buffer buf)))))))

(global-set-key (kbd "s-\\") #'my-snap-buffer)

;; ---------------------------------------------------------
;; Correct trackpad horizontal scroll direction
;; (swap wheel-left/right vs mwheel default)
;; ---------------------------------------------------------

(defun my-trackpad-hscroll (event left)
  (let* ((win (posn-window (event-start event))))
    (when (window-minibuffer-p win)
      (setq win (minibuffer-selected-window)))
    (with-selected-window (if (window-live-p win) win (selected-window))
      (funcall (if left 'scroll-right 'scroll-left)
               mouse-wheel-scroll-amount-horizontal))))

(defun my-wheel-left (event)
  (interactive "e")
  (my-trackpad-hscroll event t))

(defun my-wheel-right (event)
  (interactive "e")
  (my-trackpad-hscroll event nil))

(define-key global-map [wheel-left] #'my-wheel-left)
(define-key global-map [wheel-right] #'my-wheel-right)

;; ---------------------------------------------------------
;; Session restoration (daemon and standalone)
;; ---------------------------------------------------------
(desktop-save-mode 1)
(setq desktop-load-locked-desktop 'check-pid)
(setq desktop-restore-frames t)
(setq desktop-restore-reuses-frames t)
(setq desktop-restore-in-current-display t)
(setq desktop-auto-save-timeout 60)

(setq desktop-dirname (file-name-as-directory user-emacs-directory))

(defun my-desktop-write-guard (fn &rest args)
  (if (cl-some (lambda (f) (window-system f)) (frame-list))
      (apply fn args)
    (ignore args)))
(advice-add 'desktop-auto-save :around #'my-desktop-write-guard)

(defun my-desktop-read-on-startup ()
  "Restore the session on standalone (non-daemon) launches."
  (when (and (not (daemonp)) (display-graphic-p))
    (condition-case nil
        (delete-file (concat desktop-dirname desktop-base-file-name ".lock"))
      (error nil))
    (desktop-read)))
(add-hook 'emacs-startup-hook #'my-desktop-read-on-startup)

(when (daemonp)
  (defun my-daemon-quit (&optional _event)
    (interactive)
    (if (daemonp)
        (delete-frame)
      (save-buffers-kill-emacs)))
  (define-key global-map [ns-power-off] #'my-daemon-quit)
  (with-eval-after-load 'ns-win
    (define-key global-map [ns-power-off] #'my-daemon-quit))

  (defun my-daemon-save-on-last-frame (frame)
    (when (cl-every (lambda (f) (not (and (window-system f)
                                          (frame-visible-p f))))
                    (delq frame (frame-list)))
      (when (and (window-system frame) (frame-visible-p frame))
        (condition-case err
            (let ((desktop-save t)
                  (desktop-load-locked-desktop 'check-pid))
              (desktop-save desktop-dirname nil nil))
          (error (message "my-daemon-save-on-last-frame failed: %S" err))))))

  (defvar my-daemon-reload-frame nil)

  (defun my-daemon-do-force-read-desktop ()
    "Actually re-read the desktop (defeats the same-pid reload guard)."
    (when (and (frame-live-p my-daemon-reload-frame)
               (frame-parameter my-daemon-reload-frame 'client))
      (with-selected-frame my-daemon-reload-frame
        (condition-case nil
            (delete-file (concat desktop-dirname desktop-base-file-name ".lock"))
          (error nil))
        (desktop-read)
        (when (require 'treemacs nil t)
          (treemacs)))
      (setq my-daemon-reload-frame nil)))

  (defun my-daemon-force-read-desktop (frame)
    (when (and (frame-live-p frame)
               (frame-parameter frame 'client)
               (cl-every (lambda (f) (not (and (window-system f)
                                               (frame-visible-p f)
                                               (not (eq f frame)))))
                         (frame-list)))
      (setq my-daemon-reload-frame frame)
      (run-with-idle-timer 1.0 nil #'my-daemon-do-force-read-desktop)))

  (defun my-daemon-mark-desktop-dont-save (frame)
    (when (and (frame-live-p frame) (not (window-system frame)))
      (set-frame-parameter frame 'desktop-dont-save t)))

  (dolist (f (frame-list))
    (my-daemon-mark-desktop-dont-save f))
  (add-hook 'after-make-frame-functions #'my-daemon-mark-desktop-dont-save)
  
  (add-hook 'after-make-frame-functions #'my-daemon-force-read-desktop)
  (add-hook 'after-make-frame-functions #'my-daemon-mark-desktop-dont-save)
  (add-hook 'delete-frame-functions #'my-daemon-save-on-last-frame))
