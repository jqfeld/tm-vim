(plugin-configure evil
  (:require #t))

(when (supports-evil?)
  (display* "Welcome to the Evil side of TeXmacs!")
  (import-from (evil-mode)))
