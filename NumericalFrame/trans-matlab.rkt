#lang racket
(require rnrs/io/ports-6)
(require "Dataops.rkt")
(require "DataStructure.rkt")


; Translate Scheme expression to matlab code
;For each equation, including derivative, source/sink and residual 
(define (trans-matlab var_list)
  (define adj_status #f)
  (define sym_list
    (list (cons 'var "var_array")
          (cons 'index "cell_index")
          (cons 'adj "adj_index")
          (cons 'dim "dim")))
  (define (get-val x)
    (cdr (assq x sym_list)))
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


;default: index(list),equations,dRdv_i,dRdv_adj
(define (index->matlab dim_map title n)
  (define (getval x)
    (cdr (assq x dim_map)))
  (define proc-pair ;Ranged index
    (lambda(x)(string-append (number->string (+ 1 (car x))) 
                   ":" (number->string (+ 1 (cdr x))) ";")))
  (define proc-vector
    (lambda(x)
      (string-append "["
                     (vector-map (lambda(v) (string-append " " (number->string (+ v 1)))) x)
                     "];")))
  (define proc-val
    (lambda(x)
      (string-append (number->string (+ 1 x)) ";")))
  (lambda(info)
    (let* ([field (car info)]
          [val-list (cdr info)]
          [head 
           (string-append title 
                          "(" (number->string n) "). "  field)]
          [key (lambda(v) 
                 (string-append "{" 
                                (number->string v) "}="))]
          [proc-str (lambda(v proc  val)(string-append head (key v) (proc val)))])
      (cond
        [(list? val-list)
         (map 
          (lambda(x)
            (let([i_dim (getval (car x))]
                 [val (cadr x)])
              (cond
                [(pair? val)
                 (proc-str i_dim proc-pair val)]
                [(number? val)
                 (proc-str i_dim proc-val val)]
                [(vector? val)
                 (proc-str i_dim proc-pair val)]
                ))) 
          val-list)]
        [(pair? val-list)
         (list (proc-str 1 proc-pair val-list))]
        [(number? val-list)
         (list (proc-str 1 proc-val val-list))]
        [(vector? val-list)
         (list (proc-str 1 proc-pair val-list))]
        ))))

(define (eqn->matlab title n var_list)
  (define (list-series n c)
    (if (< n 1) (remove* (list '()) (flatten c))
        (list-series (- n 1) (list n c) )))
  (lambda(info)
    (let* ([field (car info)]
          [eqn-list (cdr info)]
          [head 
           (string-append title 
                          "(" (number->string n) "). "  field)]
          [key (lambda(v) 
                 (string-append "{" 
                                (number->string v) "}="))]
          [proc (lambda(x y)(string-append  head (key y) ((trans-matlab var_list) x)))])
      (map 
       proc
       eqn-list (list-series (length eqn-list) '())))))

(define (dRdv->matlab title n var_list)
  (lambda(info)
    (let* ([field (car info)]
          [eqn-list (cdr info)]
          [head 
           (string-append title 
                          "(" (number->string n) "). "  field)]
          [n_eqn (list-series (length eqn-list) '())]
          [key2D (lambda(i1 i2) 
                 (string-append "{" 
                                (number->string i1) "," (number->string i2) "}="))]
          [proc (lambda(x y)(string-append  head (key2D y) ((trans-matlab var_list) x)))])
      (map 
       (lambda(x i_var) 
         (map (lambda(x i_eqn)(string-append  head (key2D i_eqn i_var) ((trans-matlab var_list) x))) 
              x n_eqn))
       eqn-list n_eqn))))



(define (matlab-conv  dim_map info-list title var_list)
  (let([index 
        (map (lambda(v info) 
               ((index->matlab dim_map title v) (car info))) 
             (list-series (length info-list) '())
             info-list)]
       [R
        (map (lambda(v info) 
               ((eqn->matlab title v var_list) (cadr info))) 
             (list-series (length info-list) '())
             info-list)]
       [dRdv_i
        (if (empty? (cddar info-list))
            '()
            (map (lambda(v info) 
                   ((dRdv->matlab title v var_list) (caddr info))) 
                 (list-series (length info-list) '())
                 info-list))]
       [dRdv_adj
        (if (or ( empty? (cddar info-list)) (empty? (cdddar info-list)))
            '()
            (map (lambda(v info) 
                   ((dRdv->matlab title v var_list) (cadddr info))) 
                 (list-series (length info-list) '())
                 info-list))])
    (list index R dRdv_i dRdv_adj)))


(define (output-file filename)
  (lambda(content-list)
    (begin
      (cond [(file-exists? filename) 
             (delete-file filename)])
      (let ([f (open-file-output-port filename)])
        (begin (map 
                (lambda(x)
                  (begin 
                    (display x f)
                    (newline f))) 
                content-list) 
               (close-output-port f))))))


(provide (all-defined-out))