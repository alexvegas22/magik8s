;;; k8s-commands.el --- k8s commands for magik8s  -*- lexical-binding: t; -*-

;; Author: Your Name <your.email@example.com>
;; Maintainer: Your Name <your.email@example.com>
;; Version: 0.1
;; Homepage: https://github.com/ClubCedille/magik8s

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Provide a brief description of your package here.
;; Explain its purpose, how to use it, etc.

;;; Code:
(defun k8s-get-ns ()
  "Return all namespaces as a list."
  (shell-command-to-string "kubectl get namespaces -ogo-template-file=./templates/namespace-template"))

(defun k8s-get-deployments ()
  "Return all deployments as a list."
  (shell-command-to-string "kubectl get deployments -ogo-template-file=./templates/deployment-template"))

(defun k8s-get-all ()
  "Return all ressources as a list."
  (shell-command-to-string "kubectl get all -n default"))

(provide 'k8s-commands)
;;; k8s-commands.el ends here
