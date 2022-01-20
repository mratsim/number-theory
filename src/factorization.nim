# Impulse
# Copyright (c) 2020-Present The SciNim Project
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# ############################################################
#
#                    Prime Factorization
#
# ############################################################

import std/bitops
# Note: Compile-time precomputations

func product(s: openArray[SomeInteger]): SomeInteger =
  if s.len == 0: return 0
  result = 1
  for num in s:
    result *= num

func gcd(u, v: int): int =
  # With wheel factorization we only need to test
  # the numbers that are coprimes with the wheel circumference
  # coprime <=> gcd(n, circumference) == 1
  if u == 0: return v
  if v == 0: return u
  let shift = countTrailingZeroBits(u or v)
  var u = u shr u.countTrailingZeroBits()
  var v = v
  while true:
    v = v shr v.countTrailingZeroBits()
    if u > v:
      swap(u, v)
    v = v - u
    if v == 0:
      return u shl shift

func wheel*(primes: openarray[int32]): seq[uint8] =
  ## Build wheel of prime gaps for wheel factorization
  ## https://en.wikipedia.org/wiki/Wheel_factorization

  # 1. Generate the coprimes of the wheel circumference
  let wheelCircumference = primes.product
  var wheelCoprimes: seq[int]
  for i in primes[^1]+2 ..< wheelCircumference+2:
    if gcd(i, wheelCircumference) == 1:
      wheelCoprimes.add i

  # 2. Compute the gaps between coprimes
  for i in 1 ..< wheelCoprimes.len:
    let gap = wheelCoPrimes[i] - wheelCoPrimes[i-1]
    result.add uint8(gap)

  let nextTurn = wheelCircumference + wheelCoprimes[0] - wheelCoprimes[^1]
  result.add uint8(nextTurn)

iterator listFactorize*(n: var int32, primes: openarray[int32]): int32 =
  ## Factorize via a list of primes
  for prime in primes:
    while n mod prime == 0:
      yield prime
      n = n div prime

iterator wheelFactorize*(n: int32, firstNextPrime: int32, wheel: openarray[uint8]): int32 =
  ## Factorize n using wheel factorization
  ## Assuming a 2-3-5 wheel, `firstNextPrime` should be 7
  ## Assuming a 2-3-5-7 wheel, `firstNextPrime` should be 11
  var divisor = firstNextPrime
  var gap = 0
  var n = n
  while divisor*divisor <= n:
    while n mod divisor == 0:
      yield divisor
      n = n div divisor
    if gap == wheel.len:
      gap = 0
    divisor += int32 wheel[gap]
    gap += 1
  if n > 1:
    yield n

# Sanity checks
# -------------------------------------------------------------------------------

when isMainModule:
  import std/sequtils

  func maxNumFactors(maxNum, minDivisorWithoutMultiples: int64): int =
    ## Compute the max number of factors
    ## that can be had for any number less or equal `maxNum`
    ## with `minDivisorWithoutMultiples`
    ## i.e. assuming we factorize with 2, 3, 4,
    ## the `minDivisorWithoutMultiples` is 3
    ## as factorizing with 4 will significantly reduce the max number of `2` factors
    ## This is useful to dimension the array of twiddle factors
    ## without dynamic memory allocation (for real-time signal processing)

    var d = minDivisorWithoutMultiples
    result = 0
    while d < maxNum:
      d *= minDivisorWithoutMultiples
      inc result

  echo "Max num factors: ", high(int32).maxNumFactors(minDivisorWithoutMultiples = 4)

  proc gcdChecks() =
    doAssert gcd(2, 3) == 1
    doAssert gcd(2, 5) == 1
    doAssert gcd(2, 12) == 2
    doAssert gcd(36, 14) == 2
    doAssert gcd(36, 28) == 4
    doAssert gcd(2*3*5*7*7, 5*7*7*13) == 5*7*7

  gcdChecks()

  proc wheelChecks() =
    doAssert wheel([int32 2, 3, 5]) == @[uint8 4, 2, 4, 2, 4, 6, 2, 6]

    doAssert wheel([int32 2, 3, 5, 7]) == @[
      uint8 2, 4, 2, 4, 6,  2, 6,  4,
            2, 4, 6, 6, 2,  6, 4,  2,
            6, 4, 6, 8, 4,  2, 4,  2,
            4, 8, 6, 4, 6,  2, 4,  6,
            2, 6, 6, 4, 2,  4, 6,  2,
            6, 4, 2, 4, 2, 10, 2, 10
    ]

    echo "wheel size 2-3-5-7-11: ", [int32 2, 3, 5, 7, 11].product, ", gaps: ", wheel([int32 2, 3, 5, 7, 11]).len

  wheelChecks()

  proc factorChecks(n: int32, firstNextPrime: static int32, primes: static seq[int32]): seq[int32] =
    var n = n
    for factor in n.listFactorize(primes):
      result.add factor

    const wheel = wheel(primes)
    for factor in wheelFactorize(n, firstNextPrime, wheel):
      result.add factor

  doAssert: factorChecks(12, firstNextPrime = 7, @[int32 2, 3, 5]) == @[int32 2, 2, 3]
  doAssert: factorChecks(24, firstNextPrime = 7, @[int32 2, 3, 5]) == @[int32 2, 2, 2, 3]
  doAssert: factorChecks(4817191, firstNextPrime = 7, @[int32 2, 3, 5]) == @[int32 1303, 3697]

  doAssert: factorChecks(12, firstNextPrime = 11, @[int32 2, 3, 5, 7]) == @[int32 2, 2, 3]
  doAssert: factorChecks(24, firstNextPrime = 11, @[int32 2, 3, 5, 7]) == @[int32 2, 2, 2, 3]
  doAssert: factorChecks(4817191, firstNextPrime = 11, @[int32 2, 3, 5, 7]) == @[int32 1303, 3697]

  doAssert: factorChecks(12, firstNextPrime = 13, @[int32 2, 3, 5, 7, 11]) == @[int32 2, 2, 3]
  doAssert: factorChecks(24, firstNextPrime = 13, @[int32 2, 3, 5, 7, 11]) == @[int32 2, 2, 2, 3]
  doAssert: factorChecks(4817191, firstNextPrime = 13, @[int32 2, 3, 5, 7, 11]) == @[int32 1303, 3697]