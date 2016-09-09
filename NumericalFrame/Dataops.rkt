#lang racket


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
(define (list-series n c)
    (if (< n 1) (remove* (list '()) (flatten c))
        (list-series (- n 1) (list n c) )))

(provide (all-defined-out))