#!/bin/bash
# for development...
server_name=elisp-web-repl
emacs_name=Emacs
$emacs_name -Q --eval="(setq server-name \"$server_name\")" --daemon --load development-start.el

exec emacsclient -c -s $server_name .
