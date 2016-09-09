#lang racket

(require "Dataops.rkt")

; First Pass: add index to each face regarding to upwd scheme
(define (p-b-upwd var_list upwd_list upwd_default face_direction)
  (define (DIFF sym)
    (lambda(F)
      `(- (,sym (,F i)) (,sym i))))
  (define parse 
    (lambda(exp) 
      (match exp
        ;Deal with second-order difference term
        ;In this case it only occurs once
        [`(DIFF ,x)
         (match x
           [(? symbol? x) ((DIFF x) face_direction)]
           [else (error "Sorry, only support variables for DIFF currently meow TvT" x)])]
        [(? number? x) x]
        [`(,op ,e1 ,e2)
         `(,op ,(parse e1) ,(parse e2))]
        [`(,x ,ind) `(,x ,ind)]
        [(? symbol? x)
         (let ([var (lookup x var_list)])
           (cond
             [(not var)
              (error "undefined variable" var)]
             [else
              (let([type (get-type var)]
                   [value (get-value var)])
                (case type
                  ['const value]
                  ['location `(,x i)]
                  ['time `(,x i)]
                  ['func
                   ;Deal with upwind schemes here
                   (let ([upwd (lookup x upwd_list)])
                     (if (not upwd)
                         ((upwd_default x) face_direction)
                         ((get-value upwd) face_direction)))]))]))]    
        [else 
         (error "wrong syntax: " exp)])))
  parse)

;;pass2: substitute the variables with unknowns, if possible
; It can also be used to treat source-sink term
(define (p-s-i var_list)
  ; used to preserve the index for function expansion
  (define (parse index)
    (lambda(exp)
      (match exp
        ; Time term for source-sink, now only support 1st-order time
        ; This is not elegant, need to be modified!
        [`(d/dt ,e)
         `(/ ,((parse index) e) ,((parse index) `dt))]
        [`(if ,a ,e1 ,e2);upwd scheme
         `(if ,((parse index) a) ,((parse index) e1) ,((parse index) e2))]
        [`(,op ,e1 ,e2)
         `(,op ,((parse index) e1) ,((parse index) e2))] 
        [(? number? x) x]
        [`(,x ,ind)
         (let* ([var (lookup x var_list)]
                [type (get-type var)]
                [func (get-value var)])
           (if (eq? type 'var); an unknown
               `(,x ,ind)
               ((parse ind) func)))]; preserve the current symbol
        ;deal with the untreated symbols in variables
        ;Some parameters may further apply intermediate parameters
        [(? symbol? x)
         (let* ([var (lookup x var_list)]
                [type (get-type var)]
                [func (get-value var)])
           (case type
             ['var `(,x ,index)]; an unknown
             ['const func]
             ['func ((parse index) func)]
             [else (error "No match for: " exp)]))])))
  (parse 'i));initial index as center for source-sink term


; The derivator for Newton-Rampson solver
; Still need to be optimized along with pass-2
; the way of optimize: 
; 1. eliminate 0 for +,-,*,/,^ and 1 for *,/,^
; 2. calculate the constants
; 3. (for div only) treat other param in *,/ as constant

(define (NR-div var_list div_var cell_direction)
  (define (eq-index? a b)
    (or
     (and
      (and (list? a) (list? b))
      (eq? (car a) (car b)))
     (and
      (and (symbol? a) (symbol? b))
      (eq? a b))))
  (define div
    (lambda(exp)
      (match exp
        ; Time term for source-sink, now only support 1st-order time
        ; The old time term is eliminated meow!
        [`(d/dt ,e)
         (div e)]
        [`(if ,a ,e1 ,e2);upwd scheme, the control term should be preserved
         `(if ,a ,(div e1) ,(div e2))]
        [`(,op ,e1 ,e2)
         (cond 
           [(memq op '(+ -))
            (let([a1 (div e1)]
                 [a2 (div e2)])
              `(,op ,a1 ,a2))]
           [(eq? op '*)
            (let* ([a1 (div e1)]
                   [a2 (div e2)])
              `(+ (* ,e2 ,a1) 
                  (* ,e1 ,a2)))]
           [(eq? op '/)
            (let([a1 (div e1)]
                 [a2 (div e2)])
              `(/ 
                (- 
                 (* ,e2 ,a1) 
                 (* ,e1 ,a2)) 
                (expt ,e2 2)))]
           [(eq? op 'expt)
            `(* ,e2 
                (* ,(div e1) (expt ,e1 (- ,e2 1))))]
           [else
            (error "Currently do not support meow: " `(,op ,e1 ,e2))])]    
        [(? number? x) 0]
        [`(,x ,ind)
         (let* ([var (lookup x var_list)]
                [type (get-type var)]
                [func (get-value var)])
           (cond
             [(and (eq? x div_var)
                   (eq-index? cell_direction ind))
              1]; an unknown
             [else 0]))]
        [else (error "No match for: " exp)])))
  div)



; Pass 4: optimization and elimination of calculation results
; Can be applied to any steps
(define p-eval
  (lambda(exp)
    (match exp
      [`(,sym ,index)
       `(,sym ,index)]
      [(? number? x) x]
      [`(if ,a ,e1 ,e2)
       (let([a0 (p-eval a)]
            [v1 (p-eval e1)]
            [v2 (p-eval e2)])
         (if (and
              (and (number? v1)
                   (zero? v1))
              (and (number? v2)
                   (zero? v2)))
             0 `(if ,a ,v1 ,v2)))]      
      [`(,op ,e1 ,e2)
       (let([v1 (p-eval e1)]
            [v2 (p-eval e2)])
         (match op
           [`+ 
            (if (and (number? v1)
                     (number? v2))
                (+ v1 v2)
                (cond 
                  [(and (number? v1)
                        (zero? v1)) v2]
                  [(and (number? v2)
                        (zero? v2)) v1]
                  [else `(,op ,v1 ,v2)]))]
           [`- 
            (if (and (number? v1)
                     (number? v2))
                (- v1 v2)
                (cond 
                  [(and (number? v1)
                        (zero? v1)) `(- 0 ,v2)]
                  [(and (number? v2)
                        (zero? v2)) v1]
                  [else `(,op ,v1 ,v2)]))]
           [`* 
            (if (and (number? v1)
                     (number? v2))
                (* v1 v2)
                (cond 
                  [(and (number? v1)
                        (zero? v1)) 0]
                  [(and (number? v1)
                        (eq? v1 1)) v2]
                  [(and (number? v2)
                        (zero? v2)) 0]
                  [(and (number? v2)
                        (eq? v2 1)) v1]
                  [else `(,op ,v1 ,v2)]))]
           [`/ 
            (if (and (number? v1)
                     (number? v2))
                (if (zero? v2)
                    (error "Divided by zero" e2)
                    (/ v1 v2))
                (cond 
                  [(and (number? v1)
                        (zero? v1)) 0]
                  [(and (number? v2)
                        (eq? v2 1)) v1]
                  [else `(,op ,v1 ,v2)]))]
           [`expt 
            (if (and (number? v1)
                     (number? v2))
                (expt v1 v2)
                (cond 
                  [(and (number? v1)
                        (zero? v1)) 0]
                  [(and (number? v1)
                        (eq? v1 1)) 1]
                  [(and (number? v2)
                        (zero? v2)) 1]
                  [(and (number? v2)
                        (eq? v2 1)) v1]
                  [else `(,op ,v1 ,v2)]))]
           [else `(,op ,v1 ,v2)]))])))

(provide (all-defined-out))