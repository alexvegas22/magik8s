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
  (transient-define-prefix magik8s-descriptions ()
    "Prefix with descriptions specified with slots."
    ["Let's Give This Transient a Title\n" ; yes the newline works
     ["Group One"
      ("wo" "wave once" tsc-suffix-wave)
      ("wa" "wave again" tsc-suffix-wave)]

     ["Group Two"
      ("ws" "wave some" tsc-suffix-wave)
      ("wb" "wave better" tsc-suffix-wave)]]

    ["Bad title" :description "Group of Groups"
     ["Group Three"
      ("k" "bad desc" tsc-suffix-wave :description "key-value wins")
      ("n" tsc-suffix-wave :description "no desc necessary")]
     [:description "Key Only Def"
                   ("wt" "wave too much" tsc-suffix-wave)
                   ("we" "wave excessively" tsc-suffix-wave)]])

(defun magik8s-general-info ()
  "Get an overview of the namespace ressources."
  (shell-command-to-string "kubectl get all"))

(transient-define-suffix magik8s-suffix-general-info (Magik8s)
  "A suffix that uses `transient-setup' to manually load another transient."
  (interactive)
  ;; note that it's usually during the post-command side of calling the
  ;; command that the actual work to set up the transient will occur.
  ;; This is an implementation detail because it depends if we are calling
  ;; `transient-setup' while already transient or not.
  (transient-setup 'magik8s-general-info))


(transient-define-prefix k8s-information ()
  "Prefix that displays some information."
  ["Overview"
   (:info "Kubectl get all")
   (:info #'magik8s-general-info)
   (:info "Use :format to remove whitespace" :format "%d")
   ("k" magik8s-suffix-general-info)])

;; Tests
  (transient-define-prefix magik8s-hello ()
    "Prefix that is minimal and uses an anonymous command suffix."
    [("k" "Display overview" '(shell-command-to-string "kubectl get all") :transient t)])

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
                              "Configs:\n" config-output)))
    (with-current-buffer (get-buffer-create "*magik8s*")
      (erase-buffer)  ;; Clear previous content
      (insert full-output)
      (goto-char (point-min)) ;; Move to the top of the buffer
      (display-buffer (current-buffer)))))



(provide magik8s)
;;; magik8s.el ends here
