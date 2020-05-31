# The MIT License (MIT)
# Copyright (c) 2016 Mamy Ratsimbazafy

import
  std/bitops,
  ./integer_math

type
  Base = uint64
  ByteSeq = seq[Base]
  BitSeq = distinct ByteSeq

const
  Shift = fastLog2(sizeof(Base) * 8)
  Mask = sizeof(Base) * 8 - 1

func `[]`(bs: BitSeq, i: int): bool =
  bool ByteSeq(bs)[i shr Shift] shr (i and Mask) and 1

func setBit(bs: var BitSeq, i: int) =
  template pos: untyped = ByteSeq(bs)[i shr Shift]
  pos = pos or uint64(1 shl (i and Mask))

# To limit initialization time, primes will be with value 0 in the bit array
# Non-prime will be with value 1
func primeSieve*(n: int): seq[int] =
  ## Sieve of Erastosthenes
  # Look Ma! no trial division
  doAssert n > 2

  var sieve = newSeq[uint64](n shr Shift + 1).BitSeq
  let max_n = (n-1) shr 1
  let sqr_n = isqrt(n) shr 1

  result = @[2]

  # 1. Cross-off multiples
  for i in 1 .. sqr_n:
    if not sieve[i]:
      let prime = i shl 1 + 1
      result.add prime
      for j in countup((prime*prime) shr 1, max_n, prime):
        # Cross-off multiples from i^2 to n
        # increment by i^2 + 2i because i^2+i is even
        sieve.setBit(j)

  # 2. Everything left in √n .. n is also a prime
  for i in sqr_n+1 .. max_n:
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
