#lang racket

(require rnrs/io/ports-6)
(require "Dataops.rkt")


; Translate Scheme expression to matlab code
;For each equation, including derivative, source/sink and residual 
(define (trans-matlab var_list)
  (define adj_status #f)
  (define sym_list
    (list (cons 'var "var_array")
          (cons 'index "cell_index")
          (cons 'adj "adj_index(cell_index,dim)")
          (cons 'dim "dim")))
  (define (get-val x)
    (cadr (assq x sym_list)))
  (define (adj? index)
    (list? index))
  (define pass
    (lambda(exp)
      (match exp
        [(? number? x) (number->string x)]
        [(? symbol? x) (symbol->string x)]
        [`(,x ,index) 
         (let* ([var (lookup x var_list)]
                [type (get-type var)]
                [var_i (get-value var)])
           (if (symbol? index) ; center
               (string-append  (get-val 'var)
                               "(" 
                               (number->string var_i)
                               "," 
                               (get-val 'index) 
                               ")")
               (begin 
                 (set! adj_status #t);need to change the param head
                 (string-append  (get-val 'var)
                                 "(" 
                                 (number->string var_i)
                                 "," 
                                 (get-val 'adj)
                                 "("
                                 (get-val 'index)
                                 ","
                                 (get-val 'dim)
                                 ")"
                                 ")"))))]
        [`(if ,a ,e1 ,e2)
         (string-append "logical" "(" (pass a) ")" 
                        ".*" (pass e1) 
                        "+" "1-logical" "(" (pass a) ")" 
                        ".*" (pass e2))]
        [`(,op ,e1 ,e2)
         (cond [(eq? op 'expt) 
                (string-append "(" (pass e1) ".^" (pass e2) ")")]
               [(memq op '(* /))
                (string-append "(" (pass e1) "." (pass op) (pass e2) ")")]
               [else
                (string-append "(" (pass e1) (pass op) (pass e2)  ")")]
               )])))
  (define combine ; add function head
    (lambda(exp)
      (let ([fun_str (pass exp)])
        (if adj_status
            (begin
              (set! adj_status #f)
              (string-append "@" 
                       "(" 
                       (get-val 'index)
                       "," 
                       (get-val 'var) 
                       ","
                       (get-val 'dim)
                       ")" fun_str ";"))
            (string-append "@" 
                       "(" 
                       (get-val 'index)
                       "," 
                       (get-val 'var) 
                       ")" fun_str ";")))))
  combine)

;string-append "@(cell_index,i_dim)"
;BC_info
;
;
;(define (delete-par)
;  (define pass
;    (lambda(exp)
;      (match exp
;        [`((,e1 ,e2 ,e3)) `(,(pass e1) ,(pass e2) ,(pass e3))]
;        [else exp])))
;  pass)
;
;
;(define sample '(if (>
;                     (+
;                      (p_o i)
;                      (* 50 (- 1 (S_o i))))
;                     (+
;                      (p_o (W i))
;                      (* 50 (- 1 (S_o (W i))))))
;                    (- 1 (expt (S_o i) 0.5))
;                    (- 1 (expt (S_o (W i)) 0.5))))
;
;
;(define a ((delete-par) ((trans-syn var_list "@(cell_index,i_dim,var_table)") sample)))
;(define filename "ex.txt")
;(if (file-exists? filename)
;    (delete-file filename)
;    (let ([f (open-file-output-port filename)])
;      (begin (display a f) (close-output-port f))))