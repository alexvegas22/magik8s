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

(provide magik8s)
;;; magik8s.el ends here
