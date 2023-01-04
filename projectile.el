;;; package --- Projectile
;;; Commentary:
;;; Projectile
;;; Code:

(projectile-mode)

(setq projectile-completion-system 'ivy)

(counsel-projectile-mode)

(setq projectile-use-git-grep t)
(setq projectile-show-paths-function 'projectile-hashify-with-relative-paths)

(setq projectile-create-missing-test-files t)

;;; Keybinds

(require 'projectile)

(define-key projectile-mode-map [?\s-d] 'projectile-find-dir)
(define-key projectile-mode-map [?\s-p] 'projectile-switch-project)
(define-key projectile-mode-map [?\s-f] 'projectile-find-file)
(define-key projectile-mode-map [?\s-g] 'projectile-grep)
(define-key projectile-mode-map [?\s-G] 'projectile-replace-regexp)
(define-key projectile-mode-map [?\s-T] 'projectile-toggle-between-implementation-and-test)

(defun find-project-file (file)
  (find-file (expand-file-name file (projectile-project-root))))

(global-set-key [f8]
                (lambda () (interactive)
                  (find-project-file "bb.edn")))

(global-set-key [f9]
                (lambda () (interactive)
                  (find-project-file "shadow-cljs.edn")))

(global-set-key [f10]
                (lambda () (interactive)
                  (find-project-file "deps.edn")))

;;; projectile.el ends here
