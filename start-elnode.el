;; -*- lexical-binding: t -*-
(add-to-list package-archives "http://marmalade-repo.org/packages/")
(package-initialize)
(package-refresh-contents)
(setq
 elnode-init-port
 (string-to-number (or (getenv "PORT") "8080")))
(setq elnode-init-host "0.0.0.0")
(setq elnode-do-init nil)
(package-install 'elnode)
(require 'elnode)

(defun handler (httpcon)
  "Demonstration function"
  (elnode-http-start httpcon "200"
                     '("Content-type" . "text/html")
                     `("Server" . ,(concat "GNU Emacs " emacs-version)))
  (elnode-http-return httpcon
                      "<html><body><h1>Hello from EEEMACS.</h1></body></html>"))

(elnode-start
 'handler
 :port elnode-init-port
 :host elnode-init-host)

(while t
  (accept-process-output nil 1))

;; End
