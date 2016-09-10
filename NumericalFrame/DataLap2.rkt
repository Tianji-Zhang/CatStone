#lang racket

(require "Upwd.rkt")
(require "DataStructure.rkt")
(require "trans-matlab.rkt")

; Dimension
(define dim_map (dim_list 1))

; IC
(define var_n0
  (list
   `[p ,(data 10 50)]
   `[s ,(data 10 1)]))

; Upwd: Default using avg scheme
(define upwd-scheme
  (list `[]))


; Variables
(define var_list
  (list 
   `[p    var                      1]
   `[s    var                      2]
   `[x    location                 1]
   `[dx   const                    1]
   `[t    time                     1]
   `[dt   const                    1]))


; zones,flux, source, old term
(define zone1
  (list `[W (1 . 9)]
        `[E (0 . 8)]))
(define Jeqn1_1
  '(/ (DIFF p) dx))
(define Jeqn1_2
  '(/ (DIFF s) dx))

(define zone2
  (list `[W 0]))
(define Jeqn2_1 '(/ (- 100 (p i)) dx))
(define Jeqn2_2 '(/ (- 1 (s i)) dx))

(define zone3
  (list `[E 9]))
(define Jeqn3_1 '(/ (- 0 (p i)) dx))
(define Jeqn3_2 '(/ (- 0 (s i)) dx))

(define szone (cons 0 9))
(define Seqn1 0)
(define Seqn2 0)

(define J-generate (J_info var_list upwd-scheme upwd-avg var_n0))
(define Jinfo1 (J-generate zone1 (list Jeqn1_1 Jeqn1_2)))
(define Jinfo2 (J-generate zone2 (list Jeqn2_1 Jeqn2_2)))
(define Jinfo3 (J-generate zone3 (list Jeqn3_1 Jeqn3_2)))
(define J_list (list Jinfo1 Jinfo2 Jinfo3))



(define S-generate (S_info var_list var_n0))
(define Sinfo0 (S-generate szone (list Seqn1 Seqn2)))
(define S_list (list Sinfo0))

(define O-generate (O_info var_list var_n0))
(define Oinfo0 (O-generate szone (list Seqn1 Seqn2)))
(define O_list (list Oinfo0))

(define J (remove* (list 'quote) (flatten (matlab-conv dim_map J_list "J_info" var_list))))
(define S (remove* (list 'quote) (flatten (matlab-conv dim_map S_list "S_info" var_list))))
(define O (remove* (list 'quote) (flatten (matlab-conv dim_map O_list "O_info" var_list))))

(define text-list (remove* (list 'quote) (flatten (list J S O))))
((output-file "ex3.txt") text-list)