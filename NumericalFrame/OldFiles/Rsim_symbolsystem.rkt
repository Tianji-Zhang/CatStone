#lang racket

;;Discretization for 1D 
;;syntax tree: 
;;BasicOps:=|op expr expr
;;


(define eqn1
  '(- 
    (* dx 
       (DIV x 
            (* 
             (/ (* kr_o k) 
                (* A 
                   (* mu_o B_o)))
             (DIV x p_o)))) 
    (DIV t 
         (/ (* V (* S_o phi)) 
            B_o))))

(define eqn2
  '(- 
    (* dx 
       (DIV x         
            (*
             (/ (* kr_w k) 
                (* A 
                   (* mu_w B_w))) 
             (DIV x p_w)))) 
    (DIV t 
         (/ (* V (* S_w phi)) 
            B_w))))

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

; B.C lists $ upwd schemes
; Each column: index,boundary-location, variable, BCtype, value
; Purpose: creating a map from variable to i in each equation of each cell
; Yet it means: the eqns on the boundary should be specially treated.
(define BC_i_info
  (list '[0  'left  'p_o 'Dirich 100]
        '[99 'right 'p_o 'Dirich   0]))
;make average if not specified.
(define upwd_i_info
  (list '['kr_o '(vector-ref k_ro (get-index-upwd Po direction))]  
        '['kr_w '(vector-ref k_ro (get-index-upwd Pw direction))]))


;;Discretization for FD,1D system

(define (parser coefs location time)
  (lambda(exp) 
    (match exp)))
