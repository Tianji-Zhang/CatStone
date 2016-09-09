#lang racket
(define (trans-syn var_list exp)
  (define (pass exp)
    (match exp
      [(? number? x) x]
      [`(,x ,index) 
       (let* ([var (lookup x var_list)]
              [type (get-type var)]
              [var_i (get-value var)])
              `(,x ,index))]
      [`(if ,a ,e1 ,e2)
       `(logical,(pass a).*,(pass e1) 
                + (1 - logical,(pass a)).*,(pass e2))]
      [`(,op ,e1 ,e2)
       (if (memq op '(+ -))
           `(,(pass e1) ,op ,(pass e2))
           (match op
             ['* `(,(pass e1) .* ,(pass e2))]
             ['\ `(,(pass e1) ./ ,(pass e2))]
             ['expt `(,(pass e1).^,(pass e2))]
             [else `(,(pass e1) ,op ,(pass e2))]))]))
  (pass exp))