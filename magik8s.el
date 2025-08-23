;;; magik8s.el --- k8s UI in transient  -*- lexical-binding: t; -*-

;; Author: Your Name <your.email@example.com>
;; Maintainer: Your Name <your.email@example.com>
;; Version: 0.1
;; Package-Requires: ((emacs "27.1") (transient))
;; Homepage: https://github.com/ClubCedille/magik8s

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Provide a brief description of your package here.
;; Explain its purpose, how to use it, etc.

;;; Code:

;; Transient commands
(transient-define-prefix magik8s (magik8s)
  "Prefix that displays some information."
  ["Magik8s"
   (:info "Kubectl get all")
   (:info #'magik8s-general-info)
   (:info "Use :format to remove whitespace" :format "%d")
   ("k" magik8s-suffix-general-info :description "kubectl get all")
   ("n" magik8s-suffix-namespace :description "kubectl get namespaces" (magik8s-current-namespace))
   ])

(transient-define-suffix magik8s-suffix-general-info (namespace)
  "View general info"
  (interactive)
  (transient-setup (shell-command-to-string "kubectl get all -n default")))

(transient-define-suffix magik8s-suffix-namespace ()
  "Select Namespace"
  (interactive)
  (transient-setup (shell-command-to-string "kubectl get ns")))

;; Main buffer
(defvar magik8s-current-namespace "default"
  "Current Kubernetes namespace.")

(defun magik8s-display-overview ()
  "Display the Kubernetes overview based on the current namespace."
  (interactive)
  (let* ((current-config-output (shell-command-to-string "kubectl config current-context"))
         (pods-output (shell-command-to-string (format "kubectl get all -n %s" magik8s-current-namespace)))
         (namespaces-output (shell-command-to-string "kubectl get namespaces"))
         (config-output (shell-command-to-string "kubectl config get-contexts"))
         (full-output (concat "Current Namespace: " magik8s-current-namespace "\n"
                              "Current Config: " current-config-output "\n\n"
                              "Pods and Services:\n" pods-output "\n\n"
                              "Namespaces:\n" namespaces-output "\n\n"
                              "Configs:\n" config-output
                              "\n\nPress 'n' to change Namespace.")))
    (with-current-buffer (get-buffer-create "*magik8s*")
      (erase-buffer)  ;; Clear previous content
      (insert full-output)
      (goto-char (point-min))  ;; Move to the top of the buffer
      (display-buffer (current-buffer))
      ;; Set `n` as a command key to invoke namespace transient
      (local-set-key (kbd "n") (lambda () (interactive) (transient-setup 'magik8s-namespace-prefix))))))

(defun magik8s-set-namespace (namespace)
  "Set the current namespace to NAMESPACE and refresh the overview."
  (setq magik8s-current-namespace namespace)
  (magik8s-display-overview)  ;; Refresh overview after changing namespace
  (message "Namespace set to: %s" magik8s-current-namespace))

(defun magik8s-generate-namespace-suffixes ()
  "Generate suffixes for namespaces based on current Kubernetes namespaces."
  (let* ((namespaces-output (shell-command-to-string "kubectl get namespaces -o custom-columns=:metadata.name"))
         (namespaces (split-string namespaces-output "\n" t)))
    (mapcar (lambda (ns)
              `(,(format "Use Namespace: %s" ns)
                (lambda ()
                  (interactive)
                  (magik8s-set-namespace ,ns))))
            namespaces)))

(transient-define-prefix magik8s-namespace-prefix ()
  "Transient prefix for managing Kubernetes namespaces."
  [["Namespaces"
    ,@(magik8s-generate-namespace-suffixes)]])

;; Bind C-x k to run the magik8s-display-overview function directly
(global-set-key (kbd "C-c k") 'magik8s-display-overview)

(provide 'magik8s)
;;; magik8s.el ends here
