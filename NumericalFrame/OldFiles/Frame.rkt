#lang racket
;A practical design of an abstract numerical solver

;The inner iterative solver of each time step
;It can be directly applied in steady-state solver
;Spatial-related issues are solved within this domain 
;An example for this process: Newton-Rampson method
(define (iter-solve x0 f0)
	(let ([f ((update-f x0) f0)]
		  [x (f x0)])
	     (if (close-enough? x x0)
	         (cons x f)
	         (iter-solve x f))))

;Updating solution for each time step
(define (time-loop f_n x_n t_n t_max)
	(let ([dt (calc_dt f_n x_n)]
	      [f_n_ (update-f-t f_n dt)]
	      [solution (iter-solve x_n f_n_)]
	      [x_n1 (car solution)]
	      [f_n1 (cadr solution)]
	      [t_n1 (update-t t_n dt)])
	     (begin
	     	(savedata file t_n1 solution)
	     	(if (reach? t_n1 t_max)
	     	    "Problem solved"
	     	    (time-loop f_n1 x_n1 t_n1 t_max)))))

; The two processes can be implemented in (similar 'solve-linear-eqns) which is listed below


;We start from the most basic,simple and abstract form
;Suppose we have a continuous math system.
;They are represented by location and time, but not implemented yet
;x_f is the solution while eqn_f is the equation
;Both are continous, but as functions on the LHS of the equation
;BCs and ICs are included in those functions

(define (basic_system eqn_f x_f)
	(satisfy? (eqn_f x_f)))

;The satisfy? function could means iszero for most cases


;The solution process actually means the way we reverse the above function.
;It means: we have eqn_f, we want to get the x_f to obtain a #t
;First consider the analytical way, if possible
;Transforming the form of equation to integral is also included


;So the solution process can be written as:
(define (solve_analytical x_f0 eqn_f0)
	(let ([x_eqn_f ((deduce x_f0) eqn_f0)])
	     (if (and 
	          (simplest? x_eqn_f)
	          (satisfy? (x_eqn_f x_f))
	         x_eqn_f
	         (solve_analytical x_f0 x_eqn_f)))))

;Here x_f0 is the symbol representation of the unknown.
;The "simplest?" means that x_eqn_f is now a function only of x and t
;The "deduce" is the most important step to eliminate intermediate terms.


;We have not considered BC and IC yet, it will be discussed later.
;Now we consider the numerical solution
(define (solve_numerical eqn_f x_f)
	(lambda(similar)
		(let ([num_eqn
		       ((similar 'discretize x_f) eqn_f)] ;;In this step BC is also implemented.
		      [num_solve_f 
		       (((similar 'generate-solver) x_f) num_eqn)]
		      [num_x0
		       (((similar 'set-IC-values) x_f) )])
	     ((similar 'solve-linear-eqns) lin_solve_f num_x0))))


;Comparision between analytical and numerical solution:

;1.  What first distinguish numerical and analytical solving process is the discretization 
;1.1 The "deduce" term is replaced by three stuffs: discretize, deduce and set-IC-values.
;1.2 The "set-IC-values" can be analogous to some "Initial guess" steps in analytical solving.
;1.3 For analytical solution, we guess the mathematical forms and realize the coefficients.
;1.4 Upwind schemes begin to play a critical role.

;2.  The 'deduce function becomes deductive in numerical solution
;2.1 The "pattern matching" process in analytical solving is conducted by human brain.
;2.2 The numerical solving transfer the discretized equations into solvable linear equations
;2.3 Newton-Rampson and direct solving are two implicit extremes, most solvers are between them. 

;3.  The concept of x_f changed from a purely symbolic term into spatial-temportal related values.
;3.1 The location and time variables have been discretized,so they can not be solved in a single step
;3.2 BCs can be merged into equations but ICs must be used separately as initial numerical inputs
;3.3 Now the geometrical and time spliting should be mplicitly implemented in (similar 'set-value)

;4.  Numerical solving must be completed by time and spatial stepping
;4.1 Spatial difference can be implicitly looped within time
;4.2 Semi-analytical method is possible because of 4.1

;Since ICs and geometry becomes important, we developed
;an elegant way to express the analytical method with ICs and BCs
(define (system f ic x)
	(((eq? f) ic) x))
(define (solve-analytical f ic)
	(lambda(inv)
		(inv (eq? f) ic)))

;Original equations are always symbolic types
(define eqn_f0
	(lambda (inputfile)((parse 'physics) inputfile)))

(define x_f0 
	(define x0
		(lambda (inputfile)((parse 'ic) inputfile))
	(lambda(x0)(set-values-on-geometry x0))))

(define mesh-data
	(define geom_eqns
		(lambda(inputfile)((parse 'geom) inputfile)))
	(define (mesh eqns)
		(lambda(mesh-algorithm)
			(mesh-algorithm geom-eqns)))
	(mesh geom-eqns))
;It seems like there should be some similarities between mesh and numerical discretization!
