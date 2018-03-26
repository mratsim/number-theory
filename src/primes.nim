# The MIT License (MIT)
# Copyright (c) 2016 Mamy Ratsimbazafy

import ./integer_math

type
  Base = seq[byte]
  BitVector = distinct Base

proc `[]`(b: BitVector, i: Natural): bool {.noSideEffect, inline.}=
  bool Base(b)[i shr 3] shr (i and 7) and 1

proc bv_set(b: var BitVector, i: Natural) {.noSideEffect, inline.}=
  var w = addr Base(b)[i shr 3]
  w[] = w[] or byte(1 shl (i and 7)) # bit hack to set bit to 1

# To limit initialization time, primes will be with value 0 in the bit array
# Non-prime will be with value 1
proc primeSieve*(n: range[2..high(int)]): seq[int] =
  var sieve = newSeq[byte](n shr 3 + 1).BitVector
  let maxn = (n - 1) shr 1
  let sqn = isqrt(n) shr 1

  result = @[2]

  for i in 1 .. sqn:
    if not sieve[i]:
      let prime = i shl 1 + 1
      result.add prime
      for j in countup((prime*prime) shr 1, maxn, prime): # cross off multiples from i^2 to n, increment by i^2 + 2i because i^2+i is even
        sieve.bv_set(j)

  for i in sqn+1 .. maxn:
    if not sieve[i]:
      result.add(i shl 1 + 1)

when isMainModule:
  import times

  echo "Warmup"
  discard primeSieve(1_000_000)
  echo "Warmup successful"

  let start = cpuTime()
  discard primeSieve(1_000_000_000) # don't forget to compile with release
  let stop = cpuTime()

  echo "Time taken: ", stop - start

  echo primeSieve(1_000)
