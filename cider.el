;;; package --- CIDER configuration
;;; Commentary:
;;; CIDER configuration
;;; Code:

(require 'cider)
(require 'cider-eval-sexp-fu)

(setq cider-font-lock-reader-conditionals nil)
(setq cider-test-show-report-on-success nil)
(setq cider-repl-use-pretty-printing t)
(setq cider-repl-display-help-banner nil)
(setq cider-save-file-on-load nil)
(setq cider-buffer-name-show-port t)
(setq cider-print-options '(("right-margin" 122)))
(setq cider-show-error-buffer t)

(add-hook 'cider-mode-hook #'eldoc-mode)
(add-hook 'cider-repl-mode-hook 'paredit-mode)

(add-to-list 'same-window-buffer-names "*cider")

(setq cljr-favor-prefix-notation nil)
(setq cljr-favor-private-functions nil)

(require 'lsp)

(setq lsp-idle-delay 0)

(defun find-definition ()
  "Try to find definition of cursor via LSP otherwise fallback to cider."
  (interactive)
  (let ((cursor (point))
        (buffer (current-buffer)))
    (lsp-find-definition)
    (when (and (eq buffer (current-buffer))
               (eq cursor (point)))
      (cider-find-var))))

(define-key clojure-mode-map (kbd "M-.") #'find-definition)
(define-key cider-mode-map (kbd "M-.") #'find-definition)
(define-key clojurec-mode-map (kbd "M-.") #'find-definition)
(define-key clojurescript-mode-map (kbd "M-.") #'find-definition)

(global-set-key [f7]
                (lambda ()
                  (interactive)
                  (cider-eval-print-last-sexp 't)))

;;; Keybinds

(global-set-key [f8] 'cider-connect)
(global-set-key [M-f8] 'cider-quit)

(global-set-key [C-M-f8]
                (lambda () (interactive)
                  (cider-connect '(:host "localhost" :port 7888))))

(global-set-key [C-S-f9]
                (lambda () (interactive)
                  ;(setq cider-shadow-default-options "tools")
                  (cider-connect-clj&cljs
                   (plist-put '(:host "localhost" :cljs-repl-type shadow)
                              :port (cl-second (cl-first (cider-locate-running-nrepl-ports)))))))

(global-set-key [C-S-f8]
                (lambda () (interactive)
                  (cider-connect
                   (plist-put '(:host "localhost")
                              :port (cl-second (cl-first (cider-locate-running-nrepl-ports)))))))

(global-set-key [M-f1] 'cider-repl-clear-buffer)

(global-set-key (kbd "s-T") 'cider-test-run-test)

(global-set-key [M-S-f3] 'cider-format-edn-region)

;;; restart-cognician-system

(defun restart-cognician-system ()
  (interactive)
  (save-buffer)
  (let ((filename
         (buffer-file-name)))
    (when filename
      (cider-interactive-eval
       "(when-some [restart-fn (try
                           (require 'repl.local)
                           (find-var 'repl.local/restart-local-systems!)
                           (catch Throwable e
                             (require 'cognician.system)
                             (find-var 'cognician.system/restart-systems!)))]
    (restart-fn)
:cognician/system-restarted)"))))

(define-key clojure-mode-map (kbd "<M-return>") 'restart-cognician-system)

(defun start-portal-ui ()
  (interactive)
  (save-buffer)
  (let ((filename
         (buffer-file-name)))
    (when filename
      (cider-interactive-eval
       "
  (do
    (require '[portal.api :as p])

    (defn submit [value]
      (p/submit (with-meta value {:portal.viewer/default :portal.viewer/pprint})))

    (def portal (portal.api/open {:theme :portal.colors/solarized-light}))

    (add-tap #'p/submit)

    :portal/launched)"))))

(define-key clojure-mode-map [C-S-f10] 'start-portal-ui)

(defun clerk-show ()
  (interactive)
  (save-buffer)
  (let
      ((filename
        (buffer-file-name)))
    (when filename
      (cider-interactive-eval
       (concat "(nextjournal.clerk/show! \"" filename "\")")))))

(define-key clojure-mode-map (kbd "<M-S-return>") 'clerk-show)

;; ‘C-x r s <register-key>’ save to register
;; 'C-c C-j x <register-key>' to send to repl
(defun cider-insert-register-contents (register)
  (interactive (list (register-read-with-preview "From register")))
  (let ((form (get-register register)))
    ;; could put form into a buffer and check if its parens are
    ;; balanced
    (if form
        (cider-insert-in-repl form (not cider-invert-insert-eval-p))
      (user-error "No saved form in register"))))

(define-key 'cider-insert-commands-map (kbd "x") #'cider-insert-register-contents)
(define-key 'cider-insert-commands-map (kbd "C-x") #'cider-insert-register-contents)
(define-key cider-repl-mode-map (kbd "C-c C-j") 'cider-insert-commands-map)

;;; cider.el ends here
