;;; test-kitchen.el --- Run test-kitchen inside of emacs

;; Copyright (C) 2015 JJ Asghar <http://jjasghar.github.io>
;; Author: JJ Asghar
;; URL: http://github.com/jjasghar/test-kitchen-el
;; Created: 2015
;; Version: 0.2.1
;; Keywords: chef ruby test-kitchen

;; This file is NOT part of GNU Emacs.
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; See <http://www.gnu.org/licenses/> for a copy of the GNU General
;; Public License.

;;; Commentary:

;; This minor mode also assumes you have [[https://downloads.chef.io/chef-dk/][ChefDK]] installed.
;;
;; I'd like to thank [[https://twitter.com/camdez][Cameron Desautels]] for the jump start on this project. /me tips my hat to you sir.
;;
;; I'd also like to thank [[http://twitter.com/ionrock][Eric Larson]] for pushing me to keep this alive.
;;
;; This minor mode allows you to run test-kitchen in a seporate buffer
;;
;;  * Run test-kitchen destroy in another buffer
;;  * Run test-kitchen list in another buffer
;;  * Run test-kitchen test in another buffer
;;  * Run test-kitchen verify in another buffer
;;
;; You'll probably want to define some key bindings to run these.
;;
;;   (global-set-key (kbd "C-c C-d") 'test-kitchen-destroy)
;;   (global-set-key (kbd "C-c C-t") 'test-kitchen-test)
;;   (global-set-key (kbd "C-c l") 'test-kitchen-list)
;;   (global-set-key (kbd "C-c C-v") 'test-kitchen-verify)

;; TODO:
;;
;; 1) Have a way to select the only one suite to run
;; 2) Have a way to select only one os to run

;;; Code:

(defcustom test-kitchen-destroy-command "chef exec kitchen destroy"
  "The command used to destroy a kitchen.")

(defcustom test-kitchen-list-command "chef exec kitchen list"
  "The command used to list the kitchen nodes.")

(defcustom test-kitchen-test-command "chef exec kitchen test"
  "The command used to run the tests.")

(defcustom test-kitchen-converge-command "chef exec kitchen converge"
  "The command used for converge project.")

(defcustom test-kitchen-verify-command "chef exec kitchen verify"
  "The command use to verify the kitchen.")

(defun test-kitchen-locate-root-dir ()
  "Return the full path of the directory where .kitchen.yml file was found, else nil."
  (locate-dominating-file (file-name-as-directory
                           (file-name-directory buffer-file-name))
                          ".kitchen.yml"))

;;; test kitchen is very likes colors, so colorize compilation buffer
(require 'ansi-color)

(defun test-kitchen-colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (toggle-read-only))

;; define test kitchen compilation mode
(define-compilation-mode test-kitchen-compilation-mode "Test Kitchen compilation"
  "Compilation mode for RSpec output."
  (add-hook 'compilation-filter-hook 'test-kitchen-colorize-compilation-buffer nil t))

(defun test-kitchen-run (cmd)
  (let ((root-dir (test-kitchen-locate-root-dir)))
    (if root-dir
        (let ((default-directory root-dir))
          (compile cmd 'test-kitchen-compilation-mode))
      (error "Couldn't locate .kitchen.yml!"))))

;;;###autoload
(defun test-kitchen-destroy ()
  "Run chef exec kitchen destroy in a different buffer."
  (interactive)
  (test-kitchen-run test-kitchen-destroy-command))

;;;###autoload
(defun test-kitchen-list ()
  "Run chef exec kitchen list in a different buffer."
  (interactive)
  (test-kitchen-run test-kitchen-list-command))

;;;###autoload
(defun test-kitchen-test ()
  "Run chef exec kitchen test in a different buffer."
  (interactive)
  (test-kitchen-run test-kitchen-test-command))

;;;###autoload
(defun test-kitchen-converge (instance)
  "Run chef exec kitchen converge selected VM in a different buffer."
  (interactive "sKitchen instance to converge: ")
  (test-kitchen-run (concat test-kitchen-converge-command " " instance)))

;;;###autoload
(defun test-kitchen-converge-all ()
  "Run chef exec kitchen converge in a different buffer."
  (interactive)
  (test-kitchen-run test-kitchen-converge-command))

;;;###autoload
(defun test-kitchen-verify (instance)
  "Run chef exec kitchen verify in a different buffer."
  (interactive "sKitchen instance to converge: ")
  (test-kitchen-run (concat test-kitchen-verify-command " " instance)))

;;;###autoload
(defun test-kitchen-verify-all ()
  "Run chef exec kitchen verify in a different buffer."
  (interactive)
  (test-kitchen-run test-kitchen-verify-command))

(provide 'test-kitchen)
;;; test-kitchen.el ends here
