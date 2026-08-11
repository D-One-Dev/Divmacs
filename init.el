;; =========================================================
;; Emacs configuration
;; Linux / GUI-first / mouse-friendly setup
;; =========================================================

;; ---------------------------------------------------------
;; Basic GUI / editing behavior
;; ---------------------------------------------------------

(when (daemonp)
  (setq desktop-save t))

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
  ;;(setq x-super-keysym 'super))
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
;; (global-set-key (kbd "s-r") #'replace-string)

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

(setq window-divider-default-right-width 4)  ; visible, grabbable divider bar
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

(use-package eglot
  :ensure nil
  :bind (:map eglot-mode-map)
  ;; ("M-r" . eglot-rename))
  ("C-r" . eglot-rename))

(add-hook 'csharp-mode-hook #'eglot-ensure)

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
(add-hook 'csharp-mode-hook (lambda () (setq c-basic-offset 4)))

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
   '(centaur-tabs consult corfu doom-themes drag-stuff
		  exec-path-from-shell magit marginalia
		  multiple-cursors nerd-icons orderless treemacs
		  vertico)))

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
;; Correct session restoration
;; ---------------------------------------------------------
(when (daemonp)
  (defun my-daemon-quit (&optional _event)
    (interactive)
    (if (daemonp)
        (delete-frame)
      (save-buffers-kill-emacs)))
  (define-key global-map [ns-power-off] #'my-daemon-quit)
  (with-eval-after-load 'ns-win
    (define-key global-map [ns-power-off] #'my-daemon-quit))

  (defvar my-daemon-saved-window-config nil)

  (defun my-daemon-maybe-save-window-config (frame)
    (when (cl-every (lambda (f) (not (and (window-system f)
                                          (frame-visible-p f))))
                    (delq frame (frame-list)))
      (setq my-daemon-saved-window-config (current-window-configuration))))

  (defun my-daemon-maybe-restore-window-config ()
    (when (and my-daemon-saved-window-config (frame-live-p (selected-frame)))
      (let ((frame (selected-frame))
            (config my-daemon-saved-window-config))
        (setq my-daemon-saved-window-config nil)
        (select-frame-set-input-focus frame)
        (set-window-configuration config))))

  (defvar my-daemon-desktop-read-done nil)

  (defun my-daemon-desktop-read-on-first-frame ()
    (unless my-daemon-desktop-read-done
      (setq my-daemon-desktop-read-done t)
      (desktop-save-mode 1)
      (setq desktop-restore-reuses-frames 'keep)
      (let ((before (frame-list)))
        (desktop-read)
        (when (cl-some (lambda (f) (not (memq f before))) (frame-list))
          (dolist (f before)
            (when (and (frame-live-p f)
                       (frame-parameter f 'client)
                       (> (length (frame-list)) 1))
              (delete-frame f t)))))
      (when (and (fboundp 'treemacs) (fboundp 'treemacs-current-visibility))
        (run-with-idle-timer 1 nil
          (lambda ()
            (when (frame-live-p (selected-frame))
              (unless (eq (treemacs-current-visibility) 'visible)
                (treemacs))))))))

  (defun my-daemon-mark-desktop-dont-save (frame)
    (when (and (frame-live-p frame) (not (window-system frame)))
      (set-frame-parameter frame 'desktop-dont-save t)))

  (dolist (f (frame-list))
    (my-daemon-mark-desktop-dont-save f))
  (add-hook 'after-make-frame-functions #'my-daemon-mark-desktop-dont-save)

  (add-hook 'delete-frame-functions #'my-daemon-maybe-save-window-config)
  (add-hook 'server-after-make-frame-hook #'my-daemon-maybe-restore-window-config)
  (add-hook 'server-after-make-frame-hook #'my-daemon-desktop-read-on-first-frame))
