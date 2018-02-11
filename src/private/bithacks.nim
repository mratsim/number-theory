# The MIT License (MIT)
# Copyright (c) 2016 Mamy Ratsimbazafy

proc bit_length*[T: SomeInteger](n: T): T =
  ## Calculates how many bits are necessary to represent the number
  result = 1.T
  var y: T = n shr 1
  while y > 0.T:
    y = y shr 1
    inc(result)