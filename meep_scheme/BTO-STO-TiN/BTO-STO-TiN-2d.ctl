

(define-param unit-length 1e-6)
(define-param unit-frequency 3e14)

;------------------------------dielectric

(define-param eps-BTO (* 2.278 2.278))
(define-param eps-SiO2 (* 1.44 1.44))
(define-param eps-STO (* 2.29 2.29))


(define BTO
      (make dielectric (epsilon eps-BTO)))	

(define SiO2
      (make dielectric (epsilon eps-SiO2)))
	  
(define STO
      (make dielectric (epsilon eps-STO)))
	  
(define TiN
      (make dielectric (epsilon 1)
            (E-susceptibilities 
             (make drude-susceptibility
               (frequency 6.2868) (gamma 0.8889) (sigma 1))
             )))
	  
;(set! default-material silver)

;------------------------------End Material------------------------------

;------------------------------Geometry------------------------------

(define-param Ly-air-top 1) ; 
(define-param Ly-BTO 0.200) ; 
(define-param Ly-STO 0.200) ; 
(define-param Ly-TiN-bottom 1) ; 

(define-param size-y (+ Ly-air-top Ly-BTO Ly-STO Ly-TiN-bottom)   )     
(define-param size-z 4)

(set! geometry-lattice (make lattice (size no-size size-y size-z)))
(set-param! resolution 50)

(set! geometry (list
			
			(make block 
				(center 0 (/ Ly-BTO 2) 0) 
				(size infinity Ly-BTO infinity) 
				(material BTO)
			)
			
			(make block 
				(center 0 (/ Ly-STO -2) 0) 
				(size infinity Ly-STO infinity) 
				(material STO)
			)
			
			(make block 
				(center 0 (+ (/ Ly-STO -1) (/ Ly-TiN-bottom -2) ) 0) 
				(size infinity Ly-TiN-bottom infinity) 
				(material TiN)
			)
			
))
	

(define dpml 0.200)
	
(set! pml-layers (list 
	;(make pml (direction X) (thickness dpml))
	;(make pml (direction Y) (thickness dpml))
	;(make pml (direction Z) (thickness dpml))
	;(make absorber (direction X) (thickness dpml-x))
	;(make absorber (direction Y) (thickness dpml))
	;(make absorber (direction Z) (thickness dpml))
	(make pml (thickness dpml))
))

;------------------------------End Geometry------------------------------

;------------------------------MEEP Setting Gaussian source------------------------------
; (define-param fcen 1.6)
; (define-param df 2.0)
; (set! sources (list (make source
		      ; (src (make gaussian-src (frequency fcen) (fwidth df)))
		      ; (component Ez) (center 0 0 0))))

; (define-param kmin 0)
; (define-param kmax (/ 1 (/ (/ 6.2832 1e8) unit-length)))
; ;(define-param kmax 2.2)
; (define-param k-interp 99)
; (define kpts (interpolate k-interp (list (vector3 0 0 kmin) (vector3 0 0 kmax))))

; (define all-freqs (run-k-points 200 kpts)) ; a list of lists of frequencies

; (map (lambda (kx fs)
       ; (map (lambda (f) 
	      ; (print "eps:, " (real-part f) ", " (imag-part f) 
		     ; ", " (sqr (/ kx f)) "\n"))
	    ; fs))
     ; (map vector3-x kpts) all-freqs)
	 

;------------------------------MEEP Setting source------------------------------
; 637nm = 1.5699
(define-param fcen 0.667)
(define-param df 0.1)
(define-param zpossource (- dpml (/ size-z 2)))


;------------------------------Continuous source------------------------------
(set! sources (list 
		(make source
			(src (make continuous-src (frequency fcen)))
			(component Ex)
			(center 0 0 zpossource)
			(width 5)
			(amplitude 1)
		)
))

;------------------------------Gaussian source------------------------------
; (set! sources (list 
		; (make source
			; (src (make gaussian-src (frequency fcen) (fwidth df)))
			; (component Ex)
			; ;(center 0 0 zpossource)
			; (center xpossource)
			; (amplitude 1)
		; )
; ))

;------------------------------Eigenmode source------------------------------
; (set! sources (list 
		; (make eigenmode-source
			; (src (make continuous-src (frequency fcen) ))
			; (center 0 0 zpossource)
			; (size (* 2 d-NW1) (* 2 d-NW1) 0)
			; ;(direction NO-DIRECTION)
			; (eig-kpoint (vector3 0 0 6.3662))
			; (eig-match-freq? true)
			; (eig-band 1)
		; )
; ))


; (set! sources (list 
		; (make source
			; (src (make continuous-src (frequency fcen)))
			; (component Ey)
			; (center xpossource ypossource zpossource)
			; (width 3)
			; (amplitude 1)
		; )
		
		; (make source
			; (src (make continuous-src (frequency fcen)))
			; (component Ey)
			; (center (* xpossource -1) ypossource zpossource)
			; (width 3)
			; (amplitude -1)
		; )
			
		; (make source
			; (src (make continuous-src (frequency fcen)))
			; (component Ey)
			; (center xpossource (* ypossource -1) zpossource)
			; (width 3)
			; (amplitude -1)
		; )
		
		; (make source
			; (src (make continuous-src (frequency fcen)))
			; (component Ey)
			; (center (* xpossource -1) (* ypossource -1) zpossource)
			; (width 3)
			; (amplitude 1)
		; )
; ))

; (set! sources (list
		; (make source
			; (src (make gaussian-src (frequency fcen) (fwidth df)))
			; (component Ey)
			; (center xpossource ypossource zpossource)
			; (amplitude 1)
		; )
		
		; (make source
			; (src (make gaussian-src (frequency fcen) (fwidth df)))
			; (component Ey)
			; (center (* xpossource -1) ypossource zpossource)
			; (amplitude -1)
		; )
		
		; (make source
			; (src (make gaussian-src (frequency fcen) (fwidth df)))
			; (component Ey)
			; (center xpossource (* ypossource -1) zpossource)
			; (amplitude -1)
		; )
		
		; (make source
			; (src (make gaussian-src (frequency fcen) (fwidth df)))
			; (component Ey)
			; (center (* xpossource -1) (* ypossource -1) zpossource)
			; (amplitude 1)
		; )
; ))

;------------------------------End source------------------------------

;------------------------------Flux------------------------------

; (define-param nfreq 100) ; number of frequencies at which to compute flux             
; (define trans ; transmitted flux                                                
	; (add-flux fcen df nfreq
		; (make flux-region
			; (center (- (/ size-x 2) (* dpml 1.1)) )
			; (size 0)
		; )
; ))

; (define trans-2 ; transmitted flux                                                
	; (add-flux fcen df nfreq
		; (make flux-region
			; (center 0 0 (* -1 zpossource))
			; (size (* 2 d-NW1) (* 2 d-NW1) 0)
		; )
; ))

;------------------------------End flux------------------------------


;------------------------------k-point------------------------------
; 3.9e7 * 3e8 /2/pi / 3e14 = 6.21
; 4e7 * 3e8 /2/pi / 3e14 = 6.3662
; 5e7 * 3e8 /2/pi / 3e14 = 7.9577
; 160nm = 3.9270e+07 = 6.25
;(set-param! k-point (vector3 0 0 4))

;------------------------------Run------------------------------
(run-until 100
           (at-beginning output-epsilon)
           (to-appended "ex" (at-every 0.1 output-efield-x))
		   (to-appended "ey" (at-every 0.1 output-efield-y))
		   (to-appended "ez" (at-every 0.1 output-efield-z))
		   (to-appended "dpwr" (at-every 0.1 output-dpwr))
)


; (run-sources+ 
           ; (at-beginning output-epsilon)
		   
		   ; (stop-when-fields-decayed 20 Ex
				; (vector3 (- (/ size-x 2) (* dpml 1.1)) ) 1e-3)


		   ; ;(to-appended "ex" (at-every 0.05 output-efield-x))
		   ; ;(to-appended "ez" (at-every 0.05 output-efield-z))
		   ; ;(to-appended "dpwr" (at-every 0.05 output-dpwr))
		   ; ;(after-sources (to-appended "ex" (at-every 0.05 output-efield-x)))
		   ; ;(after-sources (to-appended "ey" (at-every 0.05 output-efield-y)))
		   ; ;(after-sources (to-appended "ez" (at-every 0.05 output-efield-z)))
		   ; ;(after-sources (to-appended "dpwr" (at-every 0.05 output-dpwr)))
		   ; ;(after-sources (harminv Ez (vector3 xpossource ypossource zpossource) fcen df))
		   ; ;(after-sources (harminv Ez (vector3 (/ w-wg-core 2) ypossource 0) fcen df))
		   ; ;(after-sources (harminv Ez (vector3 0 h-wg-core 0) fcen df))
		   ; ;(after-sources (harminv Ez (vector3 0 0 0) fcen df))
		   ; ;(after-sources (harminv Ey (vector3 xpossource ypossource 0) fcen df))
		   ; ;(after-sources (harminv Ez (vector3 (/ w-wg-core 2) (/ h-top 4) 0) fcen df))
; )

; (display-fluxes trans)
