# The MIT License (MIT)
# Copyright (c) 2016 Mamy Ratsimbazafy

proc binomialCoeff*(n, k: int): int =
  result = 1
  for i in 0 ..< k:
    result *= (n-i) div (i + 1)

when isMainModule:
  assert binomialCoeff(4, 2) == 6