#lang racket
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
            `(,op ,(div e1) ,(div e2))]
           [(eq? op '*)
            (cond
              [(number? e1)
               `(* ,e1 ,(div e2))]
              [(number? e2)
               `(* ,e2 ,(div e1))]
              [(and (number? e1)
                    (number? e2)) 0]
              [else `(+ (* ,e2 ,(div e1)) 
                        (* ,e1 ,(div e2)))])]
           [(eq? op '/)
            (if (number? e2) 
                `(/ ,(div e1) ,e2)
                `(/ 
                  (- 
                   (* ,e2 ,(div e1)) 
                   (* ,e1 ,(div e2))) 
                  (expt ,e2 2)))]
           [(eq? op 'expt)
            (if (number? e1)
                0
                `(* ,e2 
                    (expt ,e1 (- ,e2 1))))]
           [else
            (error "Currently do not support meow: " `(,op ,e1 ,e2))])]    
        [(? number? x) 0]
        [`(,x ,ind)
         (let* ([var (lookup x var_list)]
                [type (get-type var)]
                [func (get-value var)])
           (cond
             [(and (eq? x div_var)
                   (eq? cell_direction ind))
              1]; an unknown
             [else 0]))])))
  div)