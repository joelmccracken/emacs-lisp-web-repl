#!/bin/bash
# for development...
server_name=elisp-web-repl
emacs_name=Emacs
exec $emacs_name -Q --eval="(setq server-name \"$server_name\")" --daemon --load emacs-web-repl.el -f development-start
