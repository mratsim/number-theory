# The MIT License (MIT)
# Copyright (c) 2016 Mamy Ratsimbazafy

# Compiler defined const: https://github.com/nim-lang/Nim/wiki/Consts-defined-by-the-compiler
import ./stdlib_bitops

# We reuse bitops from Nim standard lib and optimize it further on x86.
# On x86 clz it is implemented as bitscanreverse then xor and we need to again xor/sub.
# We need the bsr instructions so we xor again hoping for the compiler to only keep 1.

proc bit_length*(x: SomeInteger): int {.noSideEffect.}=
  when nimvm:
    when sizeof(x) <= 4: result = if x == 0: 0 else: fastlog2_nim(x.uint32)
    else:                result = if x == 0: 0 else: fastlog2_nim(x.uint64)
  else:
    when useGCC_builtins:
      when sizeof(x) <= 4: result = if x == 0: 0 else: builtin_clz(x.uint32) xor 31.cint
      else:                result = if x == 0: 0 else: builtin_clzll(x.uint64) xor 63.cint
    elif useVCC_builtins:
      when sizeof(x) <= 4:
        result = if x == 0: 0 else: vcc_scan_impl(bitScanReverse, x.culong)
      elif arch64:
        result = if x == 0: 0 else: vcc_scan_impl(bitScanReverse64, x.uint64)
      else:
        result = if x == 0: 0 else: fastlog2_nim(x.uint64)
    elif useICC_builtins:
      when sizeof(x) <= 4:
        result = if x == 0: 0 else: icc_scan_impl(bitScanReverse, x.uint32)
      elif arch64:
        result = if x == 0: 0 else: icc_scan_impl(bitScanReverse64, x.uint64)
      else:
        result = if x == 0: 0 else: fastlog2_nim(x.uint64)
    else:
      when sizeof(x) <= 4:
        result = if x == 0: 0 else: fastlog2_nim(x.uint32)
      else:
        result = if x == 0: 0 else: fastlog2_nim(x.uint64)
