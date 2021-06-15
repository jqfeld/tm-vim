
(texmacs-module (evil-mode))

(define-public evil-active #t)
(define-public normal-active #t)
(define-public visual-active #f)

(tm-define (evil-mode?) evil-active)
(tm-define (normal-mode?) normal-active)
(tm-define (visual-mode?) visual-active)

(tm-define (toggle-evil) 
           (:check-mark "v" evil-mode?)
           (set! evil-active (not evil-active))
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
 (in-evil% (evil-mode?)) 
 (in-normal% (normal-mode?) in-evil%)
 (in-visual% (visual-mode?) in-normal%)
 ) 


(tm-define (evil-move movement)
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
  (:mode in-evil?)
  ("C-[" (enter-normal))
  ;; for easy movement without switching to normal mode
  ("A-j" (kbd-down))
  ("A-k" (kbd-up))
  ("A-h" (kbd-left))
  ("A-l" (kbd-right))
  )

(kbd-map
  (:mode in-normal?)
  ("h" (evil-move kbd-left))
  ("j" (evil-move kbd-down))
  ("k" (evil-move kbd-up))
  ("l" (evil-move kbd-right))
  ("$" (evil-move kbd-end-line))
  ("0" (evil-move kbd-start-line))
  (":" (enter-command))
  ("v" (enter-visual))

  ("i" (exit-normal))
  ("I" (begin (kbd-start-line)(exit-normal)))
  ("o" (begin (kbd-end-line)(kbd-return)(exit-normal)))
  ("O" (begin (kbd-start-line)(kbd-return)(exit-normal)(kbd-left)(kbd-left))) ; TODO: this does not work yet...

  ("p" (clipboard-paste "primary"))

  )

(kbd-map
  (:mode in-visual?)
  ("C-[" (exit-visual))
  ("y" (begin (clipboard-copy "primary")(exit-visual)))
  )

; HACK: I would like to put the menu entry into the Tools menu, but for some 
; reson only insert-menu works...
(menu-bind insert-menu
  (former)
  ---
  ("Evil" (toggle-evil))
  )




