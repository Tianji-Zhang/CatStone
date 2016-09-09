#lang racket

; Target with first order upwd and BCs

; First we define the treatment for upwd schemes and normal 2nd-order difference scheme
(define (upwd-avg sym)
  (lambda(F)
    `(/ (+ (,sym (,F i)) (,sym i)) 2)))
(define (upwd-1st-order sym-target sym-control)
  (lambda(F)
    `(if(> (,sym-control i) (,sym-control (,F i)))
       (,sym-target i) 
       (,sym-target (,F i)))))
(define (upwd-2nd-order sym-target sym-control)
  (lambda(F)
    `(if(> (,sym-control i) (,sym-control (,F i)))
       (+ (/ (,sym-target i) 1.5)
          (/ ,sym-target (,F i) 3)) 
       (+ (/ (,sym-target (,F i)) 1.5)
          (/ ,sym-target (,F (,F i)) 3)))))


;Left face for center cells
;(define (flux-face L)
;  '(* 
;    (/ (* 
;        ; first order upwd scheme
;        ; if for second-order then we implement (L (L i)) for the next cell
;        ; We could also check boundary for 2-order. If out of bound, we can deteriorate or choose other
;        (if(> (P_o i) (P_o (L i))) (kr_o i) (kr_o (L i))) 
;        ; Avg scheme for other parameters
;        (/ (+ (k (L i)) (k i)) 2)) 
;       (* (/ (+ (A (L i)) (A i)) 2) 
;          (* (/ (+ (mu_o (L i)) (A i)) 2) (/ (+ (B_o (L i)) (A i)) 2))))
;    (/ 
;     ; Difference for P_o
;     (- (P_o (L i)) (P_o i)) (dx i))))


; We need conditions to treat:
; 1. upwd for inner face
; 2. boundary face
; 3. upwd for face trying to visit boundary with high order
; We already have treated 1 in flux-face.
; But for 1 and 3, we need to have a list for them
; Each column represent: 
;                        cell index
;                        direction of face
;                        substitution method

; Default using avg scheme
(define upwd-kr_o (upwd-1st-order `kr_o `p_o))
(define upwd-kr_w (upwd-1st-order `kr_w `p_w))
(define upwd-scheme
  (list `[kr_o func ,upwd-kr_o]
        `[kr_w func ,upwd-kr_w]))



; Our general steps for discretization is:
; 1. Transfer the face flux functions to either the flux-face or the special-faces (with upwd and BCs)
; 2. substitute parameters with our unknowns

; Thus we have 2 passes for the parser,
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

(define lookup
  (lambda (symbol sym_list)
    (cond
      [(empty? sym_list) #f]
      [else
       (let ([sym (caar sym_list)]
             [sym_info (car sym_list)])
         (if (eq? sym symbol)
             sym_info
             (lookup symbol (cdr sym_list))))])))
(define (get-type v)
  (cadr v))
(define (get-value v)
  (caddr v))


;;Practice Parser for Pass 1
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

; First Pass: add index to each face regarding to upwd scheme
(define (parser-pass1 var_list upwd_list upwd_default face_direction)
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
        [`(,op ,e1 ,e2)
         `(,op ,(parse e1) ,(parse e2))]
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
;
;;pass2: substitute the variables with unknowns, if possible
; It can also be used to treat source-sink term
(define (parser-pass2 var_list)
  ; used to preserve the index for function expansion
  (define (parse index)
    (lambda(exp)
      (match exp
        ; Time term for source-sink, now only support 1st-order time
        ; This is not elegant, need to be modified!
        [`(d/dt ,e)
         `(d/dt ,`(/ (parse index) e) ((parse index) 'dt))]
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
           (if (eq? type 'var); an unknown
               `(,x ,index)
               ((parse index) func)))])))
  (parse 'i));initial index as center for source-sink term





;Above are the processing for inner faces;
;For boundary faces and upwd-boundary-meeting faces, there should be further treatment
; List for special face upwd
(define special-faces-eqn1
  (list `[0  W (/ (- 100 (p_o i)) (dx i))];BC
        `[99 E (/ (- 0 (p_o i)) (dx i))]))
; For more complex situations, we can define more in the third column.
; The real problem is how should we define them


; The parser-pass2 can be also used to parser source-sink term
; Currently, only source term has induced time difference
(define Source_eqn1
  '(d/dt 
      (/ (* V (* S_o phi)) 
         B_o)))
(define Source_eqn2
  '(d/dt 
      (/ (* V (* S_w phi)) 
         B_w)))

;(meow2 Source_eqn2)


; The derivator for Newton-Rampson solver
; Still need to be optimized along with pass-2
; the way of optimize: 
; 1. eliminate 0 for +,-,*,/,^ and 1 for *,/,^
; 2. calculate the constants
; 3. (for div only) treat other param in *,/ as constant
(define (eq-index? a b)
  (or
  (and
   (and (list? a) (list? b))
   (eq? (car a) (car b)))
  (and
   (and (symbol? a) (symbol? b))
   (eq? a b))))
(define (newton_rampson_div var_list div_var cell_direction)
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
             [else 0]))])))
  div)




; Pass 4: optimization and elimination of calculation results
; Can be applied to any steps
(define eval-p4
  (lambda(exp)
    (match exp
      [`(,sym ,index)
       `(,sym ,index)]
      [(? number? x) x]
      [`(if ,a ,e1 ,e2)
       (let([a0 (eval-p4 a)]
            [v1 (eval-p4 e1)]
            [v2 (eval-p4 e2)])
         (if (and
              (and (number? v1)
                   (zero? v1))
              (and (number? v2)
                   (zero? v2)))
             0 `(if ,a ,v1 ,v2)))]      
      [`(,op ,e1 ,e2)
       (let([v1 (eval-p4 e1)]
            [v2 (eval-p4 e2)])
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

;Some tests
;(define meow (parser-pass1 var_list upwd-scheme upwd-avg `W ))
;(define meow2 (parser-pass2 var_list))
;(define test_sample_eqn2 (meow2 (meow Flux_eqn2)))
; Test
;(define test_sample_source (meow2 Source_eqn2))
;(define meow3 (newton_rampson_div var_list `p_o `(F i)))
;(define meow4 (newton_rampson_div var_list `p_o `(W i)))
;test_sample_eqn2
;(meow Flux_eqn1)
;(eval-p4 (meow2 (meow Flux_eqn1)))
;(meow3 (eval-p4 (meow2 (meow Flux_eqn1))))
;(meow3 (meow2 (meow Flux_eqn1)))
;(eval-p4 (meow3 (meow2 (meow Flux_eqn1))))
;(eval-p4 (meow3 test_sample_eqn2))
;(meow3 test_sample_source)
;(eval-p4 (meow3 test_sample_source))
;(meow3 '(expt (p_o (W i)) 2))
;(meow3 `(+ 1 (p_o (W i))))
;(eval-p4 (meow3 '(expt (p_o (W i)) 2)))

