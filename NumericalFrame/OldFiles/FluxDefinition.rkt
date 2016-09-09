#lang racket

; Index
(define n 100)

; Those functions should be modified for other grid mapping process
(define W
  (lambda (i) (- i 1)))
(define E
  (lambda (i) (+ i 1)))

; The data save format for each parameter and unknown
; n is size, v is the initial value

(define (data n v)
  (let([dat (make-vector n v)])
    (lambda(i)(vector-ref dat i)))) 
(define p_o (data n 5000))


; Unknowns
(define unknowns
  (list 'S_o 
        'p_o))

; Numerical functions are currently not implemented yet
(define coefs
  (list '['kr_o 'func          '(expt S_o 2)] 
        '['k    'const                    '1] 
        '['mu_o 'const                    '1] 
        '['B_o  'const                    '1] 
        '['kr_w 'func  '(- 1 (expt S_o 0.5))] 
        '['mu_w 'const                    '1]
        '['B_w  'const                    '1]
        '['S_w  'func             '(- 1 S_o)]
        '['phi  'const                  '0.5]
        '['p_w  'func    '(+ p_o (* 50 S_w))]
        '['V   'const                     '1]))
(define location 
  (list 'x))
(define time 
  (list 't))
(define DX
  (list '['dx 'const  '1]))

; Flux representation for each cell


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

;Source representation for each cell
;Wells have not been implemented yet

(define Source_eqn1
  '(DIV t 
        (/ (* V (* S_o phi)) 
           B_o)))

(define Source_eqn2
  '(DIV t 
        (/ (* V (* S_w phi)) 
           B_w)))

(define (parser coefs location time DX)
  (lambda(exp) 
    (match exp)))