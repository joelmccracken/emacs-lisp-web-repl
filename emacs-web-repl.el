;; -*- lexical-binding: t -*-

(message "after message function definition")
(add-to-list 'load-path (expand-file-name "./cask-library"))
(require 'cask)
(message "required cask")
(message "starting cask initialize")
(cask-initialize "./")
(message "dolist")

(let ((emacs-version "24.3.1"))
  (message "cask elpa dir is %S" (cask-elpa-dir))
  (message "directory files is %S" (directory-files (cask-elpa-dir)))

  (dolist (dir (directory-files (cask-elpa-dir)))
    (add-to-list 'load-path (concat (cask-elpa-dir) "/" dir))))

(setq elnode-do-init nil)

(message "after cask initialize")

(message "requiring elnode")
(require 'elnode)
(message "required elnode")
(require 'xmlgen "xml-gen")
(message "required xmlgen")
(require 'elisp-sandbox)
(message "required sandbox")

(message "required app dependencies")

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
                      ;; (script :src "http://ace.c9.io/build/src-min-noconflict/ace.js" "")
                      (script :src "http://code.jquery.com/jquery-1.10.1.min.js" "")
                      (style "%s")
                      (script "%s")
                      (body
                       (h1 "Emacs Lisp Evaluator")
                       (div :class "evaluation-results"
                            "")
                       ,(echo-form))
                      )))
           (eval-stylesheet)
           (eval-javascript)

           )))




(defun eval-stylesheet ()
  "
* {
  box-sizing: border-box;
}
.evaluation-results {
  border: black solid 1px;
  padding: 1em;
  width: 300px;
  height: 200px;
}

textarea.elisp-entry {
  width: 300px;
  height: 50px;
}

"
  )



(defun evaluate-submission (submission)
  (elisp-sandbox-eval (read (or submission "nil"))))

(defun echo-form ()
  '(form :method "POST"
         (label :for "elisp" "Lisp to Evaluate:")
         (br)
         (textarea :class "elisp-entry" :name "elisp" "")
         (br)
         (input :type "button" :value "Evaluate" :name "submit" :class "evaluate")))

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
      (string-to-number (or (getenv "PORT") "8080")))
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

;;  (while t (accept-process-output nil 1))
  )

(defun development-start ()
  (interactive)
  (message "starting development server")
  (elnode-init)
  (elnode-start 'root-handler)
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
