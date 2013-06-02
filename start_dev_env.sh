#!/bin/bash
# for development...
server_name=elisp-web-repl
emacs_to_run=`which emacs`
`which emacs` -Q --eval="(setq server-name \"$server_name\")" --daemon --load start-elnode.el &
