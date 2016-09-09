#lang racket

;;Basic frame

(define (iter-solve x0 f0)
  (let* ([f ((update-f x0) f0)]
         [x (f x0)])
    (cons x f)))



(define (time-loop f_n x_n t_n t_max)
  (let* ([dt (calc_dt f_n x_n)]
         [f_n_ (update-f-t f_n dt)]
         [solution (iter-solve x_n f_n_)]
         [x_n1 (car solution)]
         [f_n1 (cdr solution)]
         [t_n1 (update-t t_n dt)])
    (begin
      (display x_n1)
      (if (reach? t_n1 t_max)
          "Problem solved"
          (time-loop f_n1 x_n1 t_n1 t_max)))))


;;calc activity


(define t_max 20)

(define (calc_dt f_x x_n) 1)

(define (update-f-t f dt) f)
(define (update-t t_n dt) (+ t_n dt))
(define (reach? a b) (> a b))

(define x0 (make-vector 5 0))
(define BC_x 1)

(define (update-f x)
  (lambda(f0)
    f0))

(define v_i vector-ref)

(define f
  (lambda(x)
    (let*([n (vector-length x)]
          [x1 (make-vector n 0)])
      (let loop ((i 0)) 
        (vector-set! x1 i (f_v x i)) 
        (if (< i (- n 1)) 
            (loop (+ i 1))
            x1)))))

;f should be an object containing vector of functions corresponding to x
; The math equation for single cell: C_i^(n+1)=C_i^n-(F_l(i)^n-F_r(i)^n)

(define (f_v C i)
  (+ (v_i C i)
     (- (i_left C i)
        (i_right C i))))

(define (i_left C i)
  (if (BC? i)
      BC_x
      (v_i C (- i 1))))

(define (BC? i)
  (<= i 0))

(define (i_right C i)
  (v_i C i))

(time-loop f x0 0 t_max)


;Note: The frame suits the case which the solving scheme is not very complex
;Iterative, single-step, Newton-Rampson based. Otherwise the framework should be extended.