;; -*- lexical-binding: t; -*-

;; =========================================================
;; Emacs configuration
;; Linux/MacOS / GUI-first / mouse-friendly setup
;; =========================================================

;; ---------------------------------------------------------
;; Basic GUI / editing behavior
;; ---------------------------------------------------------

(desktop-save-mode 1)
(setq desktop-restore-eager 5)
(setq desktop-restore-freames nil)
(savehist-mode 1)
(add-to-list 'savehist-additional-variables 'kill-ring)

(setq desktop-load-locked-desktop t)

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
    ((derived-mode-p 'csharp-mode) "C#")
    ((derived-mode-p 'shader-mode) "Shader")
    ((derived-mode-p 'yaml-mode) "YAML")
    ((string-match-p "\\*unity" (buffer-name)) "Unity")
    ((string-match-p "\\*dap\\|\\*Debug" (buffer-name)) "Debug")
    ((string-match-p "*Messages*" (buffer-name)) "Messages")
    ((string-match-p "*scratch*" (buffer-name)) "Scratch")
    ((string-match-p "*Warnings*" (buffer-name)) "Warnings")
    ((string-match-p ".*eglot.*events.*" (buffer-name)) "Eglot")
    ((string-match-p "*lsp-log*\\|*csharp-ls\\|*LSP" (buffer-name)) "LSP")
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
;; C# / Unity — Roslyn LSP (csharp-ls) and IDE integration
;; ---------------------------------------------------------
;;
;; csharp-ls is the Microsoft-Roslyn-based C# language server
;; (https://github.com/razzmatazz/csharp-language-server),
;; installed as a global .NET tool:
;;     dotnet tool install --global csharp-ls
;; It works on both Linux and macOS (dotnet tools install to
;; ~/.dotnet/tools, which exec-path-from-shell adds to PATH).

(electric-pair-mode 1)

(defun my-electric-pair-inhibit (char)
  (and (not (eobp))
       (not (memq (char-after) '(?\s ?\t ?\n ?\r)))))

(setq-default electric-pair-inhibit-predicate
              #'my-electric-pair-inhibit)

;; --- LSP core (lsp-mode) ----------------------------------

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred lsp-install-server)
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-enable-snippet t)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-idle-delay 0.5)
  (lsp-keep-workspace-alive t)
  (lsp-completion-provider :capf)
  (lsp-auto-guess-root t)
  (lsp-guess-root-without-session t))

(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-delay 0.25)
  (lsp-ui-doc-use-childframe (display-graphic-p))
  (lsp-ui-doc-header t)
  (lsp-ui-sideline-enable t)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-sideline-ignore-duplicate t))

(use-package lsp-treemacs
  :ensure t
  :after (lsp-mode treemacs)
  :config
  (define-key lsp-command-map (kbd "gs") #'lsp-treemacs-symbols)
  (lsp-treemacs-sync-mode 1))

;; --- Completion (company + LSP capf) ----------------------

(use-package company
  :ensure t
  :hook ((csharp-mode shader-mode) . company-mode)
  :custom
  (company-idle-delay 0.2)
  (company-minimum-prefix-length 1)
  (company-tooltip-limit 12)
  (company-tooltip-align-annotations t)
  :config
  (setq company-backends '(company-capf))
  (setq completion-ignore-case t)
  (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") #'company-complete-selection))

(use-package yasnippet
  :ensure t
  :hook (csharp-mode . yas-minor-mode)
  :config
  (yas-reload-all))

;; --- Unity helpers (cross-platform) ------------------------

(defcustom my/unity-editor-version nil
  "Unity editor version to use (e.g. \"6000.4.10f1\").
When nil, the newest editor installed via Unity Hub is used."
  :type '(choice (string :tag "Version")
                 (const :tag "Newest installed" nil)))

(defun my/unity-hub-editors-directory ()
  "Return the Unity Hub editors directory for this OS, or nil."
  (cond ((eq system-type 'darwin)
         "/Applications/Unity/Hub/Editor")
        ((eq system-type 'gnu/linux)
         (expand-file-name "Unity/Hub/Editor"
                           (or (getenv "HOME") "~")))
        (t nil)))

(defun my/unity-editor-path ()
  "Return the Unity editor executable path, or nil.
Honours the UNITY_EDITOR environment variable first."
  (or (getenv "UNITY_EDITOR")
      (let* ((dir (my/unity-hub-editors-directory))
             (versions (and dir (directory-files dir t "^[0-9]")))
             (chosen (cond (my/unity-editor-version my/unity-editor-version)
                           (versions (car (sort versions #'string>)))))
             (base (and dir chosen (expand-file-name chosen dir))))
        (and base (file-directory-p base)
             (if (eq system-type 'darwin)
                 (expand-file-name "Unity.app/Contents/MacOS/Unity" base)
               (expand-file-name "Editor/Unity" base))))))

(defun my/unity-project-root (&optional file)
  "Return the Unity project root for FILE (default: current buffer), or nil.
A Unity project is recognized by its Assets/ or ProjectSettings/ folder."
  (let ((dir (file-name-directory
              (or (buffer-file-name) file default-directory))))
    (when dir
      (or (locate-dominating-file dir "Assets")
          (locate-dominating-file dir "ProjectSettings")))))

(defun my/unity-solution-file (root)
  "Return the Unity .sln file at the top level of ROOT, or nil."
  (seq-find (lambda (f)
              (and (string-suffix-p ".sln" f)
                   (not (file-directory-p f))))
            (directory-files root t)))

(defun my/unity-project-try (dir)
  "Tell project.el that a directory with Assets/ is a Unity project."
  (when-let* ((root (or (locate-dominating-file dir "Assets")
                        (locate-dominating-file dir "ProjectSettings"))))
    (cons 'transient root)))

(add-to-list 'project-find-functions #'my/unity-project-try)

(defun my/unity-open-in-editor ()
  "Open the current Unity project in the Unity editor."
  (interactive)
  (let* ((root (my/unity-project-root))
         (editor (my/unity-editor-path)))
    (unless root (user-error "Not inside a Unity project"))
    (unless editor
      (user-error "Unity editor not found (set UNITY_EDITOR or install one via Unity Hub)"))
    (start-process "unity-editor" nil editor "-projectPath" root)
    (message "Opening %s in Unity editor..." root)))

(defun my/unity-regenerate-project-files ()
  "Regenerate Unity .sln/.csproj files in batch mode."
  (interactive)
  (let* ((root (my/unity-project-root))
         (editor (my/unity-editor-path)))
    (unless root (user-error "Not inside a Unity project"))
    (unless editor
      (user-error "Unity editor not found (set UNITY_EDITOR or install one via Unity Hub)"))
    (let ((buf (get-buffer-create "*unity-regenerate*")))
      (with-current-buffer buf (erase-buffer))
      (display-buffer buf)
      (message "Regenerating project files for %s..." root)
      (start-process "unity-regenerate" buf editor
                     "-quit" "-batchmode" "-projectPath" root
                     "-executeMethod" "UnityEditor.SyncVS.SyncSolution"))))

(defun my/unity-new-mono-behaviour (name)
  "Create a Unity MonoBehaviour script NAME in the current Assets folder."
  (interactive "sScript name: ")
  (let* ((root (my/unity-project-root))
         (assets (and root (expand-file-name "Assets" root)))
         (dir (or (and buffer-file-name (file-name-directory buffer-file-name))
                  default-directory)))
    (unless root (user-error "Not inside a Unity project"))
    (unless (and assets (file-in-directory-p dir assets))
      (setq dir assets))
    (let ((file (expand-file-name (concat name ".cs") dir)))
      (when (file-exists-p file) (user-error "%s already exists" file))
      (with-temp-file file
        (insert
         (format "using System.Collections;\nusing System.Collections.Generic;\nusing UnityEngine;\n\npublic class %s : MonoBehaviour\n{\n    // Start is called before the first frame update\n    void Start()\n    {\n    }\n\n    // Update is called once per frame\n    void Update()\n    {\n    }\n}\n" name)))
      (find-file file))))

(defun my/unity-open-meta-file ()
  "Open the .meta file accompanying the current buffer's file."
  (interactive)
  (let ((meta (and buffer-file-name (concat buffer-file-name ".meta"))))
    (if (and meta (file-exists-p meta))
        (find-file meta)
      (user-error "No .meta file here"))))

(defun my/unity-dap-debug ()
  "Start a Unity debugging session (loads dap-mode if needed).
Run `dap-unity-setup' once beforehand to download Unity's debug adapter."
  (interactive)
  (require 'dap-mode)
  (require 'dap-unity nil t)
  (dap-debug))

(defvar my/unity-map
  (let ((map (make-sparse-keymap)))
    (define-key map "u" #'my/unity-open-in-editor)
    (define-key map "p" #'my/unity-regenerate-project-files)
    (define-key map "n" #'my/unity-new-mono-behaviour)
    (define-key map "m" #'my/unity-open-meta-file)
    (define-key map "d" #'my/unity-dap-debug)
    map)
  "Keymap for Unity commands, bound to C-c u.")

(global-set-key (kbd "C-c u") my/unity-map)

;; --- Unity .meta file handling (unity.el) ------------------
;; From https://github.com/elizagamedev/unity.el -- makes
;; rename-file/delete-file keep .meta files in sync. Unity's
;; \"External Script Editor\" should be set to:
;;   emacsclient -n +$(Line):$(Column) $(File)

(use-package unity
  :vc (:url "https://github.com/elizagamedev/unity.el" :rev :newest)
  :demand t
  :config
  (unity-mode 1))

;; --- C# editing / Roslyn LSP activation -------------------

(defun my/csharp-mode-setup ()
  "Set up a C# buffer for Unity development with Roslyn (csharp-ls)."
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
          (statement-case-open before after)))
  (when-let* ((root (my/unity-project-root)))
    (require 'lsp-csharp nil t)
    (if-let* ((sln (my/unity-solution-file root)))
        (setq-local lsp-csharp-solution-file sln)
      (message "Unity project found but no .sln yet -- run C-c u p to regenerate project files.")))
  (add-hook 'before-save-hook #'lsp-format-buffer nil t)
  (lsp-deferred))

(use-package csharp-mode
  :ensure t
  :defer t
  :mode ("\\.cs\\'" . csharp-mode)
  :hook (csharp-mode . my/csharp-mode-setup))

;; --- ShaderLab support -------------------------------------

(use-package shader-mode
  :ensure t
  :defer t
  :mode ("\\.shader\\'" . shader-mode))

;; --- Unity YAML assets (.unity/.prefab/.asset) -------------

(use-package yaml-mode
  :ensure t
  :defer t
  :mode ("\\.\\(yml\\|yaml\\|unity\\|prefab\\|asset\\)\\'" . yaml-mode))

;; --- Debugging (DAP + Unity debug adapter) -----------------
;; M-x dap-debug -> pick the \"Unity Editor\" template.
;; Run M-x dap-unity-setup first to download Unity's debug adapter.

(use-package dap-mode
  :ensure t
  :after lsp-mode
  :config
  (dap-mode 1)
  (dap-ui-mode 1)
  (dap-ui-controls-mode 1))

;; --- Treemacs: hide Unity transient/build directories ------

(defun my/treemacs-ignore-unity-transients-p (filename path)
  "Hide Unity transient/build directories in treemacs."
  (and (file-directory-p path)
       (string-match-p "\\`\\(Library\\|Temp\\|Logs\\|obj\\|Build\\|Builds\\)\\'"
                       filename)))

(with-eval-after-load 'treemacs
  (add-to-list 'treemacs-ignored-file-predicates
               #'my/treemacs-ignore-unity-transients-p))

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
   '(centaur-tabs company consult csharp-mode dap-mode dap-unity
		  doom-themes drag-stuff exec-path-from-shell
		  lsp-mode lsp-treemacs lsp-ui magit marginalia
		  multiple-cursors nerd-icons orderless shader-mode
		  treemacs unity vertico yaml-mode yasnippet)))

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
