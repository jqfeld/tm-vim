(plugin-configure vim 
  (:require #t))

(when (supports-vim?)
  (import-from (vim-mode)))
