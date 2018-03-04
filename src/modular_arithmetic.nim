# The MIT License (MIT)
# Copyright (c) 2016 Mamy Ratsimbazafy

from ./integer_math import isOdd

proc addmod*[T: SomeInteger](a, b, m: T): T =
  ## Modular addition

  let a_m = if a < m: a
            else: a mod m
  if b == 0.T:
    return a_m
  let b_m = if b < m: b
            else: b mod m

  # We don't do a + b to avoid overflows
  # But we know that m at least is inferior to biggest T

  let b_from_m = m - b_m
  if a_m >= b_from_m:
    return a_m - b_from_m
  return m - b_from_m + a_m

proc submod*[T: SomeInteger](a, b, m: T): T =
  ## Modular substraction

  let a_m = if a < m: a
            else: a mod m
  if b == 0.T:
    return a_m
  let b_m = if b < m: b
            else: b mod m

  # We don't do a - b to avoid overflows

  if a_m >= b_m:
    return a_m - b_m
  return m - b_m + a_m

proc doublemod[T: SomeInteger](a, m: T): T {.inline.}=
  ## double a modulo m. assume a < m
  result = a
  if a >= m - a:
    result -= m
  result += a

proc mulmod*[T: SomeInteger](a, b, m: T): T =
  ## Modular multiplication

  var a_m = a mod m
  var b_m = b mod m
  if b_m > a_m:
    swap(a_m, b_m)
  while b_m > 0.T:
    if b_m.isOdd:
      result = addmod(result, a_m, m)
    a_m = doublemod(a_m, m)
    b_m = b_m shr 1

proc expmod*[T: SomeInteger](base, exponent, m: T): T =
  ## Modular exponentiation

  # Formula from applied Cryptography by Bruce Schneier
  # function modular_pow(base, exponent, modulus)
  #     result := 1
  #     while exponent > 0
  #         if (exponent mod 2 == 1):
  #            result := (result * base) mod modulus
  #         exponent := exponent >> 1
  #         base = (base * base) mod modulus
  #     return result

  result = 1.T # (exp 0 = 1)

  var e = exponent
  var b = base

  while e > 0.T:
    if isOdd e:
      result = mulmod(result, b, m)
    e = e shr 1 # e div 2
    b = mulmod(b,b,m)

proc invmod*[T:SomeInteger](a, m: T): T =
  ## Modular multiplication inverse
  ## Input:
  ##   - 2 positive integers a and m
  ## Result:
  ##   - An integer z that solves `az ≡ 1 mod m`
  # Adapted from Knuth, The Art of Computer Programming, Vol2 p342
  # and Menezes, Handbook of Applied Cryptography (HAC), p610
  # to avoid requiring signed integers
  # http://cacr.uwaterloo.ca/hac/about/chap14.pdf

  # Starting from the binary extended GCD formula (Bezout identity),
  # `ax + by = gcd(x,y)`
  # with input x,y and outputs a, b, gcd
  # We assume a and m are coprimes, i.e. gcd is 1, otherwise no inverse
  # `ax + my = 1`
  # `ax + my ≡ 1 mod m`
  # `ax ≡ 1 mod m``
  # Meaning we can use the Extended Euclid Algorithm
  # `ax + by` with
  # a = a, x = result, b = m, y = 0

  var
    a = a
    x = 1.T
    b = m
    y = 0.T
    oddIter = true # instead of requiring signed int, we keep track of even/odd iterations which would be in negative

  while b != 0.T:
    let
      q = a div b
      r = a mod b
      t = x + q * y
    x = y; y = t; a = b; b = r
    oddIter = not oddIter

  if a != 1.T:
    # a now holds the gcd(a, m) and should equal 1
    raise newException(ValueError, "No modular inverse exists")

  if oddIter:
    return x
  return m - x

template modulo*[T:SomeInteger](modulus: T, body: untyped): untyped =
  # `+`, `*`, `**` and pow will be replaced by their modular version
  template `+`(a, b: T): T =
    addmod(a, b, `modulus`)
  template `-`(a, b: T): T =
    submod(a, b, `modulus`)
  template `*`(a, b: T): T =
    mulmod(a, b, `modulus`)
  template `^`(a, b: T): T =
    expmod(a, b, `modulus`)
  template pow(a, b: T): T =
    expmod(a, b, `modulus`)
  body

when isMainModule:
  # https://www.khanacademy.org/computing/computer-science/cryptography/modarithmetic/a/fast-modular-exponentiation
  assert expmod(5, 117,19) == 1
  assert expmod(3, 1993, 17) == 14

  assert invmod(42, 2017) == 1969
  assert invmod(271, 383) == 106 # Handbook of Applied Cryptography p610

  assert expmod(5'u8, 117'u8,19'u8) == 1'u8
  assert expmod(3'u16, 1993'u16, 17'u16) == 14'u16

  assert invmod(42'u16, 2017'u16) == 1969'u16
  assert invmod(271'u16, 383'u16) == 106'u16
