
(texmacs-module (vim-mode))

(define-public vim-active #t)
(define-public normal-active #t)
(define-public visual-active #f)

(tm-define (vim-mode?) vim-active)
(tm-define (normal-mode?) normal-active)
(tm-define (visual-mode?) visual-active)

(tm-define (toggle-vim) 
           (:check-mark "v" vim-mode?)
           (set! vim-active (not vim-active))
           )

(tm-define (toggle-normal) 
           (set! normal-active (not normal-active))
           )

(tm-define (exit-normal)
           (set! normal-active #f)
           (set-message "Insert" "")
           )

(tm-define (enter-normal)
           (set! normal-active #t)
           (set-message "Normal" "")
           )

(tm-define (exit-visual)
           (set! visual-active #f)
           (set-message "Normal" "")
           )

(tm-define (enter-visual)
           (set! visual-active #t)
           (set-message "Visual" "")
           )

(texmacs-modes
 (in-vim% (vim-mode?)) 
 (in-normal% (normal-mode?) in-vim%)
 (in-visual% (visual-mode?) in-normal%)
 ) 


(tm-define (vim-move movement)
           (if (visual-mode?) 
             (kbd-select movement)
             (movement)
             )
           )

;; :w
(tm-define (write-to-tm file-name)
  (let* ((this (current-buffer))
	 (to-file-name
	  (if (== '() file-name)
	      this
	      (url-relative this (car file-name)))))
    (if (or (url-scratch? this)
	    (== '() file-name)
	    (== (car file-name) this))
	(save-buffer this)
	(save-buffer-as to-file-name (list)))))

;; wq
(tm-define (write-and-quit file-name)
  (write-to-tm file-name)
  (quit-TeXmacs))

(tm-define (enter-command)
           (user-ask "Command:" execute-command))

(tm-define (execute-command cmd)
           (define cmd_list (string-split cmd #\space))
           (cond ((in? (car cmd_list) '("w" "write")) 
                      (begin 
                        (set-message "Save" "")
                        (write-to-tm (cdr cmd_list))
                      )
                  )
                 (else (set-message (string-append cmd " is not a valid command!") ""))
           )
)


(kbd-map
  (:mode in-vim?)
  ("C-[" (enter-normal))
  ;; for easy movement without switching to normal mode
  ("A-j" (kbd-down))
  ("A-k" (kbd-up))
  ("A-h" (kbd-left))
  ("A-l" (kbd-right))
  )

(kbd-map
  (:mode in-normal?)
  ("h" (vim-move kbd-left))
  ("j" (vim-move kbd-down))
  ("k" (vim-move kbd-up))
  ("l" (vim-move kbd-right))
  ("$" (vim-move kbd-end-line))
  ("0" (vim-move kbd-start-line))
  ("g" (noop)) ; HACK: avoid shoing "g" when using "gg"
  ("g g" (vim-move go-start))
  ("G" (vim-move go-end))
  ("w" (vim-move go-to-next-word))
  ("b" (vim-move go-to-previous-word))

  ("i" (exit-normal))
  ("I" (begin 
         (kbd-start-line)
         (exit-normal)
         ))
  ("o" (begin 
         (kbd-end-line)
         (kbd-return)
         (exit-normal)
         ))
  ("O" (begin 
         (kbd-start-line)
         (kbd-return)
         (exit-normal)
         (kbd-left)
         (kbd-left)
         )) ; TODO: this does not work yet...
  ("a" (begin 
         (kbd-right) 
         (exit-normal)
         ))
  ("A" (begin 
         (kbd-end-line) 
         (exit-normal)
         ))

  ("x" (begin
         (kbd-select kbd-right)
         (kbd-cut)
         ))
  ("d" (noop)) ; TODO: make this word with movements...
  ("d d" (begin 
           (kbd-start-line) 
           (kbd-select kbd-end-line) 
           (kbd-cut)
           (kbd-backspace)
         ))
  ("D" (begin
         (kbd-select kbd-end-line)
         (kbd-cut)
         ))

  ("p" (kbd-paste))
  ("P" (begin
         (kbd-start-line)
         (kbd-return)
         (kbd-left)
         (kbd-paste)
         ))

  ("u" (undo 0))
  ("C-r" (redo 0))

  (":" (enter-command))
  ("/" (interactive-search))
  ("v" (enter-visual))

  )

(kbd-map
  (:mode in-visual?)
  ("C-[" (exit-visual))
  ("y" (begin 
         (kbd-copy) 
         (exit-visual)
         ))
  ("d" (begin 
         (kbd-cut) 
         (exit-visual)
         ))
  )
; T
; HACK: I would like to put the menu entry into the Tools menu, but for some 
; reson only insert-menu works...
(menu-bind insert-menu
  (former)
  ---
  ("Vim mode" (toggle-vim))
  )




