module polymer_constituents
  ! Use the numbers module which defines the precision and length of various numbers and constants.
  use numbers
  implicit none

  type name
    character(:), allocatable :: name(:)!, dimension(:), allocatable :: name(:)
  end type name

  type monomer
    ! Monomer type.
    type(name)    :: name
    integer(i16)  :: amount ! Monomer amount.
    real(dp)      :: mass   ! Monomer mass.
    real(dp), dimension(:), allocatable :: k_ij ! Monomer reaction coefficients. The 'allocatable' attribute makes it possible to declare the extents of the defined ranks at compilation time.
  end type monomer

  type dimer
    ! Dimer type has three constituents: Initiator, Monomer A and Monomer B.
    !type(name_term) :: name
    type(monomer) :: I, A, B
  end type dimer

  type termination
    ! Termination type. Allows for different terminations and termination lengths.
    type(name) :: name
    real(dp), dimension(:), allocatable     :: t ! Termination type.
    integer(i16), dimension(:), allocatable :: l ! Kinetic chain lengths.
  end type termination

  interface operator(/)
    ! Defines an operator which calls subroutines where operations are defined for derived type structures. In this case, for normalisation operations on parts of data structures with type 'dimer' or 'termination'.
    module procedure norm_term, norm_dimer_kij
  end interface

  contains
    function norm_term(a,b)
      ! Normalises the termination probabilities.
      type(termination) :: norm_term      ! Result.
      real(dp)          :: norm           ! Sum of all probabilities.
      type(termination), intent(in) :: a  ! Argument to the left of the interface operator(/).
      type(termination), intent(in) :: b  ! Argument to the right of the interface operator(/).

      norm = sum(abs(b % t)) ! Sum all probabilities.

      norm_term % t = a % t/norm  ! Normalise.
    end function norm_term

    function norm_dimer_kij(a,b)
      ! Normalise reaction coefficients.
      type(dimer) :: norm_dimer_kij           ! Result.
      real(dp)    :: norm_i, norm_a, norm_b   ! Sum of coefficients for possible  reactions.
      type(dimer), intent(in) :: a  ! Argument to the left of the interface operator(/).
      type(dimer), intent(in) :: b  ! Argument to the right of the interface operator(/).

      norm_i = sum(abs(b % I % k_ij)) ! Sum coefficients for I_ reactions.
      norm_a = sum(abs(b % A % k_ij)) ! Sum coefficients for A_ reactions.
      norm_b = sum(abs(b % B % k_ij)) ! Sum coefficients for B_ reactions.

      norm_dimer_kij % I % k_ij = a % I % k_ij/norm_i ! Normalise I_ reactions.
      norm_dimer_kij % A % k_ij = a % A % k_ij/norm_a ! Normalise A_ reactions.
      norm_dimer_kij % B % k_ij = a % B % k_ij/norm_b ! Normalise B_ reactions.
    end function norm_dimer_kij

end module polymer_constituents
