#!/bin/bash
# for development...
server_name=elisp-web-repl
emacs -Q --eval="(setq server-name \"$server_name\")" --daemon --load start-elnode.el

