#lang racket

; The data type for variables
(define (data n v)
  (let*([dat (make-vector n v)])
    (lambda(i)(vector-ref dat i)))) 
; IC
(define p_o (data 100 5000))
(define S_o (data 100 0.9))

; Variables
(define var_list
  (list 
   `[p_o  var                      1]
   `[S_o  var                      2]
   `[kr_o func          (expt S_o 2)] 
   `[k    const                    1] 
   `[mu_o const                    1] 
   `[B_o  const                    1] 
   `[kr_w func  (- 1 (expt S_o 0.5))] 
   `[mu_w const                    1]
   `[B_w  const                    1]
   `[S_w  func             (- 1 S_o)]
   `[phi  const                 0.35]
   `[p_w  func    (+ p_o (* 50 S_w))]
   `[V    const                    1]
   `[A    const                    1]
   `[x    location                 1]
   `[dx   const                    1]
   `[t    time                     1]
   `[dt   const                    1]))

; B.C
(define special-faces-eqn1
  (list `[0  W (/ (- 100 (p_o i)) (dx i))]
        `[99 E (/ (- 0 (p_o i)) (dx i))]))




(define Source_eqn1
  '(d/dt 
      (/ (* V (* S_o phi)) 
         B_o)))
(define Source_eqn2
  '(d/dt 
      (/ (* V (* S_w phi)) 
         B_w)))
(define Flux_eqn1
  '(* 
    (/ (* kr_o k) 
       (* A 
          (* mu_o B_o)))
    (/ (DIFF p_o) dx)))
(define Flux_eqn2
  '(* 
    (/ (* kr_w k) 
       (* A 
          (* mu_w B_w)))
    (/ (DIFF p_w) dx)))

;Flux, source and
;Input in matlab format
(define J_info)