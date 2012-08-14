;; -*- lexical-binding: t -*-
(add-to-list 'load-path
             (file-name-directory (or load-file-name
                                      (buffer-file-name (current-buffer)))))
(require 'elnode)

(defun handler (httpcon)
  "Demonstration function"
  (elnode-http-start httpcon "200"
                     '("Content-type" . "text/html")
                     `("Server" . ,(concat "GNU Emacs " emacs-version)))
  (elnode-http-return httpcon
                      "<html><body><h1>Hello from EEEMACS.</h1></body></html>"))

(elnode-start 'handler (string-to-number (or (getenv "PORT") "8080")) "0.0.0.0")

(while t
  (accept-process-output nil 1))

