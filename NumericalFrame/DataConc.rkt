#lang racket

(require "Upwd.rkt")
(require "DataStructure.rkt")
(require "trans-matlab.rkt")

; Dimension
(define dim_map (dim_list 1))

; IC
(define var_n0
  (list
   `[p ,(data 100 1)]))

; Upwd: Default using avg scheme
(define upwd-scheme
   `[])


; Variables
(define var_list
  (list 
   `[p    var                      1]
   `[x    location                 1]
   `[dx   const                    1]
   `[t    time                     1]
   `[dt   const                    1]))


; zones,flux, source, old term
(define zone1
  (list `[W (1 . 9)]))
(define Jeqn1
  '(p (F i)))

(define zone2
  (list `[E (0 . 8)]))
(define Jeqn2
  '(- 0 (p i)))

(define zone3
  (list `[W 0]))
(define Jeqn3 0.1)

(define zone4
  (list `[E 9]))
(define Jeqn4 0)

(define szone (cons 0 9))
(define Seqn 'p)

(define J-generate (J_info var_list upwd-scheme upwd-avg var_n0))
(define Jinfo1 (J-generate zone1 (list Jeqn1)))
(define Jinfo2 (J-generate zone2 (list Jeqn2)))
(define Jinfo3 (J-generate zone3 (list Jeqn3)))
(define Jinfo4 (J-generate zone4 (list Jeqn4)))
(define J_list (list Jinfo1 Jinfo2 Jinfo3 Jinfo4))



(define S-generate (S_info var_list var_n0))
(define Sinfo0 (S-generate szone (list Seqn)))
(define S_list (list Sinfo0))

(define O-generate (O_info var_list var_n0))
(define Oinfo0 (O-generate szone (list Seqn)))
(define O_list (list Oinfo0))

(define J (remove* (list 'quote) (flatten (matlab-conv dim_map J_list "J_info" var_list))))
(define S (remove* (list 'quote) (flatten (matlab-conv dim_map S_list "S_info" var_list))))
(define O (remove* (list 'quote) (flatten (matlab-conv dim_map O_list "O_info" var_list))))

(define text-list (remove* (list 'quote) (flatten (list J S O))))
((output-file "ex4.txt") text-list)