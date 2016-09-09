#lang racket

; Data structure for model construction and translation

(require "Dataops.rkt")
(require "TermParse.rkt")

; The data type for variables
(define (data n v)
  (let*([dat (make-vector n v)])
    (lambda(i)(vector-ref dat i)))) 

; Flux, source and old term

(define (J_info var_list upwd-scheme upwd-avg var_n0)
  (define step1 (p-b-upwd var_list upwd-scheme upwd-avg 'F))
  (define step2 (p-s-i var_list))
  (lambda (zone_list exp_list)
    (let*([varnames (map car var_n0)]
          [f_R (lambda(c)(p-eval (step2 (step1 c))))]
          [R_J (map f_R exp_list)]
          [f_dv 
           (lambda(d)(lambda(v)(lambda(eqn)(p-eval ((NR-div var_list v d) eqn)))))]
          [dJdv 
           (lambda(d)(map (lambda(x)(map x R_J)) (map (f_dv d) varnames)))])
      (list
       (cons "dir_index" zone_list)
       (cons "J_eqn" R_J)
       (cons "dJdv_i" (dJdv 'i)) 
       (cons "dJdv_adj" (dJdv '(F i)))))))


(define (S_info var_list var_n0)
  (define step (p-s-i var_list))
  (lambda (zone_list exp_list)
    (let*([varnames (map car var_n0)]
          [f_R (lambda(c)(p-eval (step c)))]
          [R_S (map f_R exp_list)]
          [f_dv 
           (lambda(v)(lambda(eqn)(p-eval ((NR-div var_list v `i) eqn))))]
          [dSdv 
           (map (lambda(x)(map x R_S)) (map f_dv varnames))])
      (list
       (cons "index" zone_list)
       (cons "S_eqn" R_S)
       (cons "dSdv_i" dSdv)))))


(define (O_info var_list var_n0)
  (define step (p-s-i var_list))
  (lambda (zone_list exp_list)
    (let*([varnames (map car var_n0)]
          [f_R (lambda(c)(p-eval (step c)))]
          [R_O (map f_R exp_list)])
      (list
       (cons "index" zone_list)
       (cons "O_eqn" R_O)))))


; Dimension
(define dim_list
  (lambda (dim)
    (cond
      [(eq? dim 1)
       (list (cons 'W 1)
             (cons 'E 2))]
      [(eq? dim 2)
       (list (cons 'W 1)
             (cons 'E 2)
             (cons 'N 3)
             (cons 'S 4))]
      [(eq? dim 3)
       (list (cons 'W 1)
             (cons 'E 2)
             (cons 'N 3)
             (cons 'S 4)
             (cons 'U 5)
             (cons 'D 6))])))


(provide (all-defined-out))
