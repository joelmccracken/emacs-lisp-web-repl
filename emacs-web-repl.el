;; -*- lexical-binding: t -*-

(add-to-list 'load-path (expand-file-name "./cask-library"))
(require 'cask)
(cask-initialize "./")

(let ((emacs-version "24.3.1"))
  (dolist (dir (directory-files (cask-elpa-dir)))
    (add-to-list 'load-path (concat (cask-elpa-dir) "/" dir))))

;; disable the default elnode services
(setq elnode-do-init nil)
(setq elnode-init-port nil)


(require 'elnode)
(require 'xmlgen "xml-gen")
(require 'elisp-sandbox)

(setq emacs-web-repl-routes
      '(
        ("^.*eval$" . eval-handler)
        ("^.*$" . repl-interface-handler)
        ))

(defun handler (httpcon)
  (elnode-hostpath-dispatcher httpcon emacs-web-repl-routes))

(defalias 'root-handler 'handler)

(defun eval-handler (httpcon)
  (elnode-http-start httpcon "200"
                     '("Content-type" . "text/html")
                     `("Server" . ,(concat "GNU Emacs " emacs-version)))

  (let ((submission-to-evaluate (cdr (assoc "lisp" (elnode-http-params httpcon))))
        results)
    (message "about to evaluate: %S" submission-to-evaluate)
    (setq results (evaluate-submission submission-to-evaluate))
    (message "evaluated; returning: %S" results)
    (elnode-http-return httpcon (format "%S" results))))

(defun repl-interface-handler (httpcon)
  "Demonstration function"
  (elnode-http-start httpcon "200"
                     '("Content-type" . "text/html")
                     `("Server" . ,(concat "GNU Emacs " emacs-version)))
  (elnode-http-return
   httpcon
   (format (xmlgen `(html
                     (head
                      (style "%s")

                      (body
                       (div :class "body"
                            (h1 "Emacs Lisp")
                            (h2 "Interactive REPL")

                            (div :class "evaluation-results" "")
                            ,(echo-form))

                       ;; (script :src "http://ace.c9.io/build/src-min-noconflict/ace.js" "")
                       (script :src "http://code.jquery.com/jquery-1.10.1.min.js" "")
                       (script "%s")
                       ))))
           (eval-stylesheet)
           (eval-javascript))))

(defun eval-stylesheet ()
  "
* {
  -moz-box-sizing: border-box;
  box-sizing: border-box;
  color: #D2D6FF;
  font-family: sans-serif;
}

body {
  background-color: #FFF5D2;
}

div.body {
  padding: 2em;
  background-color: #8186B2;
  width: 50%;
  min-width: 500px;
  margin: auto;
}



h1 {
  color: #D2D6FF;
  font-size: 2em;
}

h2 {
  color: #D2D6FF;
  font-style: italic;
  font-size: 1em;
}

.evaluation-results {
  border: #B2A46F solid 3px;
  padding: 1em;
  width: 100%;
  height: 200px;
}

form {
  height: 100%;
  width: 100%;
}

label {
  margin-top: 2em;
  display: block;
  margin-bottom: 1em;
}

textarea.elisp-entry {
  float: left;
  height: 65px;
  width: 70%;
  display: inline-block;
  padding: 4px;
  background-color: #EBEDFF;
  border: #B2A46F solid 3px;
  color: #8186B2;
}

input.evaluate {
  float: right;
  display: inline-block;
  height: 65px;
  width: 25%;
  padding: 0px;
  margin-top: 1px;
  background-color: #EBEDFF;
  border: #B2A46F solid 3px;
  color: #8186B2;
  font-size: 1em;
}

")



(defun evaluate-submission (submission)
  (elisp-sandbox-eval (read (or submission "nil"))))

(defun echo-form ()
  '(form :method "POST"
         (div :class "elisp-entry-wrapper"
              (label :for "elisp" "Lisp to Evaluate:")
              (textarea :class "elisp-entry" :name "elisp" "")
              (input :type "button" :value "Run!" :name "submit" :class "evaluate"))))

(defun eval-javascript ()
  "
$(function(){
  $('input.evaluate[type=button]').on('click', function(event){
    event.preventDefault();

    function appendResults(results, entry)
    {
        $('.evaluation-results').append($('<div>'+entry+' => '+results[0]+'</div>'));
    }
    var button = $(this);
    var entryFinder = function() { return button.parent().find('.elisp-entry').val() };

    $.post('/eval',
           { lisp: $(this).parent().find('.elisp-entry').val() },
           function(){
             console.log(arguments, entryFinder());
             appendResults(arguments, entryFinder());
           });
  });
});
")



(setq heroku-elnode-init-port
      (string-to-number (or (getenv "PORT") "8000")))
(setq heroku-elnode-init-host "0.0.0.0")

(defun heroku-start ()
  (interactive)
  (message "top of heroku-start")
  (elnode-init)
  (message "about to elnode-start")
  (elnode-start 'root-handler :port heroku-elnode-init-port :host heroku-elnode-init-host)
  ;; from what I can tell, the following line is required on heroku to
  ;; keep the emacs process live. I think?
  (message "about to start infinite loop")

  (while t (accept-process-output nil 1)))

(defun development-start ()
  (interactive)
  (message "starting development server")
  (elnode-init)
  (elnode-start 'root-handler :port "8000" :host "0.0.0.0")
  (load-development-settings))


(defun load-development-settings ()
  (if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
  (if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
  (ido-mode 1)
  (let ((load-path (cons "~/emacs/" load-path)))
    (require 'functions-dotfile)
    (require 'coding-dotfile)
    (require 'lisp-dotfile)))


;; End
