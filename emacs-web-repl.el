;; -*- lexical-binding: t -*-

(dolist (package (file-expand-wildcards "elpa/*" t))
  (add-to-list 'load-path package))
(package-initialize)
(message "packages initialized")


(setq
 elnode-init-port
 (string-to-number (or (getenv "PORT") "8080")))
(setq elnode-init-host "0.0.0.0")
(setq elnode-do-init nil)

(require 'elnode)

(defun handler (httpcon)
  "Demonstration function"
  (elnode-http-start httpcon "200"
                     '("Content-type" . "text/html")
                     `("Server" . ,(concat "GNU Emacs " emacs-version)))
  (elnode-http-return
   httpcon
   (format "<html><body><h1>You said: '%s %s'</h1>%s</body></html>"
           (cdr (assoc "echo_me" (elnode-http-params httpcon)))
           (cdr (assoc "echo_me" (elnode-http-params httpcon)))
           (echo-form)
           )))

(defun echo-form ()
  "
<form method=\"POST\">
  <input type=\"text\" name=\"echo_me\">
  <input type=\"submit\" value=\"Say me!\" name=\"submit\">
</form>
")

(defun heroku-start ()
  (elnode-init)
  (elnode-start 'handler :port elnode-init-port :host elnode-init-host)
  ;; from what I can tell, the following line is required on heroku to
  ;; keep the emacs process live. I think?
  (while t (accept-process-output nil 1)))

(defun development-start ()
  (elnode-init)
  (elnode-start 'handler :port elnode-init-port :host elnode-init-host))

;; End
