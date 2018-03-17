# The MIT License (MIT)
# Copyright (c) 2016 Mamy Ratsimbazafy

from ./private/bithacks import bit_length

proc isOdd*[T: SomeInteger](i: T): bool {.inline.}= (i and 1) != 0
proc isEven*[T: SomeInteger](i: T): bool {.inline.}= (i and 1) == 0

proc isqrt*[T: SomeInteger](n: T):  T =
  ## Integer square root, return the biggest squarable number under n
  ## Computation via Newton method
  result = n
  var y = (2.T shl ((n.bit_length() + 1) shr 1)) - 1
  while y < result:
    result = y
    y = (result + n div result) shr 1

proc product*[T](x: varargs[T]): T {.noSideEffect.} =
  ## Computes the sum of the elements in `x`.
  ## If `x` is empty, 0 is returned.
  assert x.len > 0
  result = 1.T
  for i in x:
    result = result * i

type
  ldiv_t {.bycopy, importc: "ldiv_t", header:"<stdlib.h>".} = object
    quot: clong               ##  quotient
    rem: clong                ##  remainder

  lldiv_t {.bycopy, importc: "lldiv_t", header:"<stdlib.h>".} = object
    quot: clonglong
    rem: clonglong

proc ldiv(a, b: clong): ldiv_t {.importc: "ldiv", header: "<stdlib.h>".}
proc lldiv(a, b: clonglong): lldiv_t {.importc: "lldiv", header: "<stdlib.h>".}

proc divmod*[T: SomeSignedInt](a, b: T): tuple[quot, rem: T] {.inline.}=
  ## Compute quotient and reminder of integer division in a single operation

  when T.sizeof == 4: # 32-bit (int32, clong)
    cast[type result](ldiv(a,b))
  elif T.sizeof == 8: # 64-bit (int64, clong)
    cast[type result](lldiv(a,b))

proc divmod*[T: SomeUnsignedInt](a, b: T): tuple[quot, rem: T] {.inline.}=
  # There is no single instruction for unsigned ints
  # Hopefully the compiler does its work properly
  (a div b, a mod b)
