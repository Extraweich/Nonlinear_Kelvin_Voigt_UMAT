!DEC$ FREEFORM

MODULE FUNCTIONS
CONTAINS

    FUNCTION HYDROSTATIC(EPS, ntens) RESULT (HYDRO)
	  ! Calculate the hydrostatic strain/stress without changing factors (covariant/contravariant)
	  IMPLICIT NONE
	  DOUBLE PRECISION, DIMENSION(:), INTENT(IN) :: EPS
	  INTEGER, INTENT(IN) :: ntens
	  DOUBLE PRECISION, DIMENSION(ntens) :: HYDRO
	  
	  DOUBLE PRECISION :: TRACE
	  INTEGER :: I
	  
	  TRACE = EPS(1)+EPS(2)+EPS(3)
	  DO I=1, 3
	    HYDRO(I) = 1.D0/3.D0*TRACE
	    HYDRO(I+3) = 0.D0
	  ENDDO
    END FUNCTION
	
    FUNCTION DEVIATORIC(EPS, HYDRO, ntens) RESULT (DEV)
	  ! Calculate the deviatoric strain/stress without changing factors (covariant/contravariant)
	  IMPLICIT NONE
	  DOUBLE PRECISION, DIMENSION(:), INTENT(IN) :: EPS, HYDRO
	  INTEGER, INTENT(IN) :: ntens
	  DOUBLE PRECISION, DIMENSION(ntens) :: DEV
	  
	  INTEGER :: I
	  
	  DO I=1, 3
	    DEV(I) = EPS(I)-HYDRO(I)
	    DEV(I+3) = EPS(I+3)
      ENDDO
    END FUNCTION
    
    FUNCTION GET_IND_STRESS(SIGMA) RESULT (IND_STRESS)
      ! Calculate indicator stress IND_STRESS for a given stress state SIGMA
      IMPLICIT NONE
      DOUBLE PRECISION, DIMENSION(6), INTENT(IN) :: SIGMA
      DOUBLE PRECISION :: IND_STRESS
      
      IND_STRESS = sqrt(SIGMA(1)**2.D0+SIGMA(2)**2.D0+SIGMA(3)**2.D0 &
                        -SIGMA(1)*SIGMA(2)-SIGMA(1)*SIGMA(3)-SIGMA(2)*SIGMA(3) &
                        *3.D0*(SIGMA(4)**2+SIGMA(5)**2+SIGMA(6)**2))
                        
    END FUNCTION
    
    FUNCTION GET_G0(IND_STRESS) RESULT (G0)
      ! Calculate G0 for a given indicator stress
      IMPLICIT NONE
      DOUBLE PRECISION, INTENT(IN) :: IND_STRESS
      DOUBLE PRECISION :: G0
      
      G0 = 1
      
    END FUNCTION
    
    FUNCTION GET_G01G2(IND_STRESS) RESULT (G1G2)
      ! Calculate G0 for a given indicator stress
      IMPLICIT NONE
      DOUBLE PRECISION, INTENT(IN) :: IND_STRESS
      DOUBLE PRECISION :: G1G2
      
      G1G2 = 1
      
    END FUNCTION
    
    FUNCTION GET_A_SIG(IND_STRESS) RESULT (A_SIG)
      ! Calculate G0 for a given indicator stress
      IMPLICIT NONE
      DOUBLE PRECISION, INTENT(IN) :: IND_STRESS
      DOUBLE PRECISION :: A_SIG
      
      A_SIG = 1
      
    END FUNCTION
    
    FUNCTION GET_DPSI(dtime, A_SIG) RESULT (DPSI)
      ! Calculate the reduced time increment 
      IMPLICIT NONE
      DOUBLE PRECISION, INTENT(IN) :: dtime
      DOUBLE PRECISION :: A_SIG
      DOUBLE PRECISION :: DPSI
      
      DPSI = dtime/A_SIG
      
    END FUNCTION
    
    FUNCTION GET_RES_NORM(DSTRAN_TRIAL, DSTRAN, ntens) RESULT (STRAN_RES)
      ! Calculate the strain residuum norm
      IMPLICIT NONE
      DOUBLE PRECISION, DIMENSION(:), INTENT(IN) :: DSTRAN_TRIAL, DSTRAN
      INTEGER, INTENT(IN) :: ntens
      INTEGER :: I
      DOUBLE PRECISION :: NORM_STRAN, NORM_DIFF
      DOUBLE PRECISION, DIMENSION(ntens) :: STRAN_DIFF
      DOUBLE PRECISION :: STRAN_RES
      
      STRAN_DIFF = DSTRAN_TRIAL - DSTRAN
      
      NORM_DIFF = 0.D0
      NORM_STRAN = 0.D0
      DO I=1, ntens
        NORM_DIFF = NORM_DIFF + STRAN_DIFF(I)**2
	    NORM_STRAN = NORM_STRAN + DSTRAN(I)**2
	  ENDDO
      
      NORM_DIFF = sqrt(NORM_DIFF)
      NORM_STRAN = sqrt(NORM_STRAN)
	  
	  ! print *, 'DSTRAN:', DSTRAN
	  ! print *, 'DSTRAN_TRIAL:', DSTRAN_TRIAL
      
      STRAN_RES = NORM_DIFF/NORM_STRAN
      
    END FUNCTION
	
	FUNCTION GET_G(G0_NL, G1G2_NL, DPSI, G0, G1, G2, G3, TAU1, TAU2, TAU3) RESULT (G)
	  ! Return the effective viscous shear modulus
	  IMPLICIT NONE
	  DOUBLE PRECISION, INTENT(IN) :: G0_NL, G1G2_NL, DPSI, G0, G1, G2, G3, TAU1, TAU2, TAU3
	  DOUBLE PRECISION :: G, DECAY1, DECAY2, DECAY3
	  
	  DECAY1 = 1.D0-exp(-DPSI/TAU1)
      DECAY2 = 1.D0-exp(-DPSI/TAU2)
      DECAY3 = 1.D0-exp(-DPSI/TAU3)
	  
	  G = 1.D0/(G0_NL/G0+G1G2_NL*(1.D0/G1*(1.D0-TAU1/DPSI*DECAY1)+1.D0/G2*(1.D0-TAU2/DPSI*DECAY2)+1.D0/G3*(1.D0-TAU3/DPSI*DECAY3)))
	
	END FUNCTION
	
	FUNCTION GET_K(G0_NL, G1G2_NL, DPSI, K0, K1, K2, K3, TAU1, TAU2, TAU3) RESULT (K)
	  ! Return the effective viscous shear modulus
	  IMPLICIT NONE
	  DOUBLE PRECISION, INTENT(IN) :: G0_NL, G1G2_NL, DPSI, K0, K1, K2, K3, TAU1, TAU2, TAU3
	  DOUBLE PRECISION :: K, DECAY1, DECAY2, DECAY3
	  
	  DECAY1 = 1.D0-exp(-DPSI/TAU1)
      DECAY2 = 1.D0-exp(-DPSI/TAU2)
      DECAY3 = 1.D0-exp(-DPSI/TAU3)
	  
	  K = 1.D0/(G0_NL/K0+G1G2_NL*(1.D0/K1*(1.D0-TAU1/DPSI*DECAY1)+1.D0/K2*(1.D0-TAU2/DPSI*DECAY2)+1.D0/K3*(1.D0-TAU3/DPSI*DECAY3)))
	
	END FUNCTION
	
	FUNCTION GET_DEPS(stress, DSIGMA, STRAN_INH1, STRAN_INH2, STRAN_INH3, &
	  dtime, ntens, G0, G1, G2, G3, K0, K1, K2, K3, TAU1, TAU2, TAU3, M_PRIME_EPS, M_PRIME_SIG, M_CIRC) RESULT (DEPS)
	  ! Calculate strain increment based on stress increment
	  IMPLICIT NONE
	  INTEGER, INTENT(IN) :: ntens
	  DOUBLE PRECISION, INTENT(IN), DIMENSION(ntens) :: stress, DSIGMA, STRAN_INH1, STRAN_INH2, STRAN_INH3
	  DOUBLE PRECISION, INTENT(IN) :: dtime, G0, G1, G2, G3, K0, K1, K2, K3, TAU1, TAU2, TAU3
	  DOUBLE PRECISION, INTENT(IN), DIMENSION(6,6) :: M_PRIME_EPS, M_PRIME_SIG, M_CIRC
	  DOUBLE PRECISION, DIMENSION(ntens) :: DEPS
	  DOUBLE PRECISION, DIMENSION(ntens) :: STRESS_NEW, HISTORY_STRAIN
	  DOUBLE PRECISION :: IND_STRESS, G0_NL, G1G2_NL, A_SIG_NL, DPSI, DECAY1, DECAY2, DECAY3, K, G
	  !DOUBLE PRECISION :: GET_G0, GET_G1G2, GET_A_SIG, GET_G, GET_K, GET_IND_STRESS
	  
	  STRESS_NEW = stress + DSIGMA
	  IND_STRESS = GET_IND_STRESS(STRESS_NEW) 
	  
	  G0_NL = GET_G0(IND_STRESS)
	  G1G2_NL = GET_G1G2(IND_STRESS)
	  A_SIG_NL = GET_A_SIG(IND_STRESS)
	  
	  DPSI = GET_DPSI(dtime, A_SIG_NL)
	  
	  G = GET_G(G0_NL, G1G2_NL, DPSI, G0, G1, G2, G3, TAU1, TAU2, TAU3)
	  K = GET_K(G0_NL, G1G2_NL, DPSI, K0, K1, K2, K3, TAU1, TAU2, TAU3)
	  
	  DECAY1 = 1.D0-exp(-DPSI/TAU1)
      DECAY2 = 1.D0-exp(-DPSI/TAU2)
      DECAY3 = 1.D0-exp(-DPSI/TAU3)
	  
	  HISTORY_STRAIN = (STRAN_INH1*DECAY1 + STRAN_INH2*DECAY2 + STRAN_INH3*DECAY3)
	  
	  DEPS = matmul((1.D0/(2.D0*G)*M_PRIME_SIG + 1.D0/(3.D0*K)*M_CIRC), DSIGMA) + HISTORY_STRAIN
	  
    END FUNCTION
	
	FUNCTION GET_JACOBIAN(stress, DSIGMA, STRAN_INH1, STRAN_INH2, STRAN_INH3, &
	  dtime, ntens, G0, G1, G2, G3, K0, K1, K2, K3, TAU1, TAU2, TAU3, M_PRIME_EPS, M_PRIME_SIG, M_CIRC, h) RESULT (JACOBIAN)
	  ! Calculate Jacobian (numerically)
	  IMPLICIT NONE
	  INTEGER, INTENT(IN) :: ntens
	  DOUBLE PRECISION, INTENT(IN), DIMENSION(ntens) :: stress, DSIGMA, STRAN_INH1, STRAN_INH2, STRAN_INH3
	  DOUBLE PRECISION, INTENT(IN) :: dtime, G0, G1, G2, G3, K0, K1, K2, K3, TAU1, TAU2, TAU3
	  DOUBLE PRECISION, INTENT(IN), DIMENSION(6,6) :: M_PRIME_EPS, M_PRIME_SIG, M_CIRC
	  DOUBLE PRECISION, DIMENSION(6,6) :: JACOBIAN
	  DOUBLE PRECISION, DIMENSION(ntens) :: DH
	  DOUBLE PRECISION :: h
	  INTEGER :: I, J
	  
	  DO J=1, ntens
	    DO I=1, ntens
		  IF (I == J) THEN
	        DH(I) = h
		  ELSE
		    DH(I) = 0.D0
	      END IF
        ENDDO
	    JACOBIAN(:,J) = 1.D0/(2.D0*h)*(GET_DEPS(stress, DSIGMA+DH, STRAN_INH1, STRAN_INH2, STRAN_INH3, &
	                    dtime, ntens, G0, G1, G2, G3, K0, K1, K2, K3, TAU1, TAU2, TAU3, M_PRIME_EPS, M_PRIME_SIG, M_CIRC) &
	                    - GET_DEPS(stress, DSIGMA-DH, STRAN_INH1, STRAN_INH2, STRAN_INH3, &
	                    dtime, ntens, G0, G1, G2, G3, K0, K1, K2, K3, TAU1, TAU2, TAU3, M_PRIME_EPS, M_PRIME_SIG, M_CIRC))
	  ENDDO
      
    END FUNCTION

END MODULE FUNCTIONS


SUBROUTINE UMAT(stress,statev,ddsdde,sse,spd,scd,&
	rpl,ddsddt,drplde,drpldt,&
	stran,dstran,time,dtime,temp,dtemp,predef,dpred,cmname,&
	ndi,nshr,ntens,nstatv,props,nprops,coords,drot,pnewdt,&
	celent,dfgrd0,dfgrd1,noel,npt,layer,kspt,kstep,kinc)
    
	USE FUNCTIONS
	IMPLICIT NONE
      
	integer, intent(in) 									:: ndi,nshr,ntens,nstatv,nprops,noel,npt,layer,kspt,kstep,kinc
	double precision, intent(inout), dimension(ntens)		:: stress
	double precision, intent(inout), dimension(nstatv)		:: statev
	double precision, intent(out), dimension(ntens,ntens)	:: ddsdde
	double precision, intent(inout)							:: sse, spd, scd, pnewdt
	double precision							            :: rpl,drpldt
	double precision,  dimension(ntens)			            :: ddsddt,drplde	
	double precision, intent(in), dimension(ntens)			:: stran,dstran
	double precision, intent(in), dimension(2) 				:: time
	double precision, intent(in), dimension(1) 				:: predef, dpred
	double precision, intent(in) 							:: dtime,temp,dtemp,celent
	character(80), intent(in)								:: cmname
	double precision, intent(in), dimension(nprops)			:: props
	double precision, intent(in), dimension(3)				:: coords
	double precision, intent(in), dimension(3,3)			:: drot,dfgrd0,dfgrd1

    integer													:: i,j, n, info
	
	INTEGER                                                 :: ITER
    INTEGER, PARAMETER	                                    :: ITER_MAX = 50
	DOUBLE PRECISION                                        :: h = 1E-4
	DOUBLE PRECISION, PARAMETER                             :: RES_MIN = 1E-4
	
	DOUBLE PRECISION :: E0, NU, E1, TAU1, E2, TAU2, E3, TAU3, G0, K0, G1, K1, G2, K2, G3, K3, G, K 
	DOUBLE PRECISION :: DECAY1, DECAY2, DECAY3, A_SIG, DPSI, STRAN_RES, G0_NL, G1G2_NL, A_SIG_NL
	! DOUBLE PRECISION :: GET_DPSI, GET_G, GET_K, GET_RES_NORM
	DOUBLE PRECISION, DIMENSION(6) :: DSTRESS, DSIGMA_TRIAL, DSTRAN_TRIAL, DDSTRESS, R !, GET_DEPS
	DOUBLE PRECISION, DIMENSION(6) :: STRAN_INH1, STRAN_INH2, STRAN_INH3, HISTORY_STRAIN, STRAIN_DIFF
	DOUBLE PRECISION, DIMENSION(6,6) :: M_PRIME_EPS, M_PRIME_SIG, M_CIRC, JACOBIAN !, GET_JACOBIAN
	
	DOUBLE PRECISION, DIMENSION(3,3) :: A, A_INV
	DOUBLE PRECISION, DIMENSION(3) :: b, x
    
	DOUBLE PRECISION :: LAMBDA, MU
	
	
	! EXTERNAL dsyev
    
	M_PRIME_EPS = reshape( 1.D0/6.D0*(/4.D0, -2.D0, -2.D0, 0.D0, 0.D0, 0.D0, &
                                      -2.D0, 4.D0, -2.D0, 0.D0, 0.D0, 0.D0, &
                                      -2.D0, -2.D0, 4.D0, 0.D0, 0.D0, 0.D0, & 
                                      0.D0, 0.D0, 0.D0, 3.D0, 0.D0, 0.D0, &
                                      0.D0, 0.D0, 0.D0, 0.D0, 3.D0, 0.D0, &
                                      0.D0, 0.D0, 0.D0, 0.D0, 0.D0, 3.D0/), (/6, 6/) )
									  
    M_PRIME_SIG = reshape( 1.D0/6.D0*(/4.D0, -2.D0, -2.D0, 0.D0, 0.D0, 0.D0, &
                                      -2.D0, 4.D0, -2.D0, 0.D0, 0.D0, 0.D0, &
                                      -2.D0, -2.D0, 4.D0, 0.D0, 0.D0, 0.D0, & 
                                      0.D0, 0.D0, 0.D0, 12.D0, 0.D0, 0.D0, &
                                      0.D0, 0.D0, 0.D0, 0.D0, 12.D0, 0.D0, &
                                      0.D0, 0.D0, 0.D0, 0.D0, 0.D0, 12.D0/), (/6, 6/) )
									  
	M_CIRC = reshape( 1.D0/3.D0*(/1.D0, 1.D0, 1.D0, 0.D0, 0.D0, 0.D0, &
                                      1.D0, 1.D0, 1.D0, 0.D0, 0.D0, 0.D0, &
                                      1.D0, 1.D0, 1.D0, 0.D0, 0.D0, 0.D0, & 
                                      0.D0, 0.D0, 0.D0, 0.D0, 0.D0, 0.D0, &
                                      0.D0, 0.D0, 0.D0, 0.D0, 0.D0, 0.D0, &
                                      0.D0, 0.D0, 0.D0, 0.D0, 0.D0, 0.D0/), (/6, 6/) )
   
	E0 = PROPS(1)
	NU = PROPS(2)
	E1 = PROPS(3)
	TAU1 = PROPS(4)
    E2 = PROPS(5)
	TAU2 = PROPS(6)
    E3 = PROPS(7)
	TAU3 = PROPS(8)
    
	G0 = E0/(2.D0*(1.D0+NU))
	K0 = E0/(3.D0*(1.D0-2.D0*NU))
	G1 = E1/(2.D0*(1.D0+NU))
	K1 = E1/(3.D0*(1.D0-2.D0*NU))
    G2 = E2/(2.D0*(1.D0+NU))
	K2 = E2/(3.D0*(1.D0-2.D0*NU))
	G3 = E3/(2.D0*(1.D0+NU))
	K3 = E3/(3.D0*(1.D0-2.D0*NU))
	
	! Build state variables
	STRAN_INH1(1) = STATEV(1)
	STRAN_INH1(2) = STATEV(2)
	STRAN_INH1(3) = STATEV(3)
	STRAN_INH1(4) = STATEV(4)
	STRAN_INH1(5) = STATEV(5)
	STRAN_INH1(6) = STATEV(6)

	STRAN_INH2(1) = STATEV(7)
	STRAN_INH2(2) = STATEV(8)
	STRAN_INH2(3) = STATEV(9)
	STRAN_INH2(4) = STATEV(10)
	STRAN_INH2(5) = STATEV(11)
	STRAN_INH2(6) = STATEV(12)
	
	STRAN_INH3(1) = STATEV(13)
	STRAN_INH3(2) = STATEV(14)
	STRAN_INH3(3) = STATEV(15)
	STRAN_INH3(4) = STATEV(16)
	STRAN_INH3(5) = STATEV(17)
	STRAN_INH3(6) = STATEV(18)
    
    ! Old nonlinear parameters
    G0_NL = STATEV(19)
    G1G2_NL = STATEV(20)
    A_SIG_NL = STATEV(21)
    
    ! Get new reduced time increment and time dependent material parameters
    DPSI = GET_DPSI(dtime, A_SIG_NL)
    
    DECAY1 = 1.D0-exp(-DPSI/TAU1)
    DECAY2 = 1.D0-exp(-DPSI/TAU2)
    DECAY3 = 1.D0-exp(-DPSI/TAU3)
    
    G = GET_G(G0_NL, G1G2_NL, DPSI, G0, G1, G2, G3, TAU1, TAU2, TAU3)
	K = GET_K(G0_NL, G1G2_NL, DPSI, K0, K1, K2, K3, TAU1, TAU2, TAU3)
	
	HISTORY_STRAIN = (STRAN_INH1*DECAY1 + STRAN_INH2*DECAY2 + STRAN_INH3*DECAY3)
    STRAIN_DIFF = DSTRAN - HISTORY_STRAIN
    
	! Calculate trial stress based on nonlinear parameters from previous time step
    DSIGMA_TRIAL = matmul((2.D0*G*M_PRIME_EPS + 3.D0*K*M_CIRC), STRAIN_DIFF)
    
    ! Calculate trial strain to check if trial stress is sufficient
    DSTRAN_TRIAL = matmul((1.D0/(2.D0*G)*M_PRIME_SIG + 1.D0/(3.D0*K)*M_CIRC), DSIGMA_TRIAL) + HISTORY_STRAIN
    
    ! Calculate residuum
    STRAN_RES = GET_RES_NORM(DSTRAN_TRIAL, DSTRAN, ntens)
    
	! ---- Newton-Raphson ----
	ITER = 0
	DSTRESS = DSIGMA_TRIAL
	n = 6 ! make parameter later
    DO WHILE(ITER < ITER_MAX .AND. STRAN_RES > RES_MIN)
	  ! Calculate Jacobian
	  JACOBIAN = GET_JACOBIAN(stress, DSTRESS, STRAN_INH1, STRAN_INH2, STRAN_INH3, &
	                   dtime, ntens, G0, G1, G2, G3, K0, K1, K2, K3, TAU1, TAU2, TAU3, &
					   M_PRIME_EPS, M_PRIME_SIG, M_CIRC, h)
	  
	  ! Solve for DDSTRESS
	  R = DSTRAN_TRIAL - DSTRAN
	  call linsolv(n,JACOBIAN,R,DDSTRESS,info)
	 
	  ! Update DSTRESS
	  DSTRESS = DSTRESS + DDSTRESS
	 
	  ! Update trial strain
	  DSTRAN_TRIAL = GET_DEPS(stress, DSTRESS, STRAN_INH1, STRAN_INH2, STRAN_INH3, &
	  dtime, ntens, G0, G1, G2, G3, K0, K1, K2, K3, TAU1, TAU2, TAU3, M_PRIME_EPS, M_PRIME_SIG, M_CIRC)
	
	  STRAN_RES = GET_RES_NORM(DSTRAN_TRIAL, DSTRAN, ntens)
	  ITER = ITER + 1
	END DO
	
	IF (ITER == ITER_MAX) THEN
	  print *, 'Newton-Raphson did not converge (time, noel)', time, noel
	END IF
    
	DPSI = GET_DPSI(dtime, A_SIG_NL)
    
    DECAY1 = 1.D0-exp(-DPSI/TAU1)
    DECAY2 = 1.D0-exp(-DPSI/TAU2)
    DECAY3 = 1.D0-exp(-DPSI/TAU3)
	
    ! Update stress
    stress = stress + DSTRESS
    
    ! Update state variables
	STRAN_INH1 = STRAN_INH1 + STRAN_INH1*(-1.D0)*DECAY1 + G1G2_NL*TAU1/DPSI*DECAY1*matmul((1.D0/(2.D0*G1)*M_PRIME_SIG + 1.D0/(3.D0*K1)*M_CIRC), DSTRESS)
	STRAN_INH2 = STRAN_INH2 + STRAN_INH2*(-1.D0)*DECAY2 + G1G2_NL*TAU2/DPSI*DECAY2*matmul((1.D0/(2.D0*G2)*M_PRIME_SIG + 1.D0/(3.D0*K2)*M_CIRC), DSTRESS)
	STRAN_INH3 = STRAN_INH3 + STRAN_INH3*(-1.D0)*DECAY3 + G1G2_NL*TAU3/DPSI*DECAY3*matmul((1.D0/(2.D0*G3)*M_PRIME_SIG + 1.D0/(3.D0*K3)*M_CIRC), DSTRESS)	
	
	! Write state variables to STATEV
	STATEV(1) = STRAN_INH1(1)
	STATEV(2) = STRAN_INH1(2)
	STATEV(3) = STRAN_INH1(3)
	STATEV(4) = STRAN_INH1(4)
	STATEV(5) = STRAN_INH1(5)
	STATEV(6) = STRAN_INH1(6)

	STATEV(7) = STRAN_INH2(1)
	STATEV(8) = STRAN_INH2(2)
	STATEV(9) = STRAN_INH2(3)
	STATEV(10) = STRAN_INH2(4)
	STATEV(11) = STRAN_INH2(5)
	STATEV(12) = STRAN_INH2(6)
	
	STATEV(13) = STRAN_INH3(1)
	STATEV(14) = STRAN_INH3(2)
	STATEV(15) = STRAN_INH3(3)
	STATEV(16) = STRAN_INH3(4)
	STATEV(17) = STRAN_INH3(5)
	STATEV(18) = STRAN_INH3(6)
    
    STATEV(19) = G0_NL
    STATEV(20) = G1G2_NL
    STATEV(21) = A_SIG_NL
    
    STATEV(22) = STRAN_RES
	
	! Calculate DDSDDE
	DO I=1, ntens
	  DO J=1, ntens
	    DDSDDE(I,J) = 0.D0
      ENDDO
    ENDDO
	
	DDSDDE = 2.D0*G*M_PRIME_EPS + 3.D0*K*M_CIRC
	
RETURN
END SUBROUTINE UMAT

SUBROUTINE SDVINI(STATEV,COORDS,NSTATV,NCRDS,NOEL,NPT,&
	LAYER,KSPT)
! Sets the initial values of the STATEV
	INCLUDE 'ABA_PARAM.INC'
!
	DIMENSION STATEV(NSTATV),COORDS(NCRDS)
	
	! Strains of first KV Element
	STATEV(1) = 0.D0 
	STATEV(2) = 0.D0 
	STATEV(3) = 0.D0 
	STATEV(4) = 0.D0 
	STATEV(5) = 0.D0 
	STATEV(6) = 0.D0 
	
	! Strains of second KV Element
	STATEV(7) = 0.D0 
    STATEV(8) = 0.D0 
	STATEV(9) = 0.D0 
	STATEV(10) = 0.D0 
	STATEV(11) = 0.D0 
	STATEV(12) = 0.D0  
	
	! Strains of third KV Element
	STATEV(13) = 0.D0 
	STATEV(14) = 0.D0 
    STATEV(15) = 0.D0 
	STATEV(16) = 0.D0 
	STATEV(17) = 0.D0 
	STATEV(18) = 0.D0 
	
	! Non-linear parameter g0, g1g2, a_sigma
	STATEV(19) = 1.D0 
	STATEV(20) = 1.D0 
	STATEV(21) = 1.D0 
	
	! Residuum for Newton iterations
	STATEV(22) = 0.D0


RETURN
END

subroutine invert (n,A,Ainv) 
	implicit none 
	integer n,info
	integer ipiv(n)
	integer nsize 
	parameter (nsize=9) ! matrix size 
	integer LWORK_MKL
	parameter (LWORK_MKL=64*nsize)
	real*8 WORK_MKL (LWORK_MKL)
	real*8 A(n,n), Ainv (n,n)
	Ainv = A
	! Intially, Ainv = A.
	! After linear solve, Ainv = inv(A)
	CALL dgetrf (n,n,Ainv,n, ipiv,info)
	CALL dgetri (n,Ainv,n, ipiv, WORK_MKL, LWORK_MKL, info)
end subroutine invert

subroutine linsolv(n,Ain,b,x, info)
	implicit none 
	integer n,info,nrhs
	integer ipiv(n)
	real*8 A(n, n), Ain (n,n), b(n), x(n)
	parameter (nrhs=1)
	A = Ain
	x = b
	
	! Initially x = b
	! After linear solve, x=inv(A)*b
	call dgesv(n, nrhs, A, n, ipiv, x, n, info)
	
	if (info.ne. 0) then 
	  write(*,*) '***ERROR INVERTING LOCAL JACOBIAN***', info 
	end if
end subroutine linsolv
