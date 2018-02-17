# The MIT License (MIT)
# Copyright (c) 2016 Mamy Ratsimbazafy

# Compiler defined const: https://github.com/nim-lang/Nim/wiki/Consts-defined-by-the-compiler
const withBuiltins = defined(gcc) or defined(clang)

when withBuiltins:
  proc builtin_clz(n: cuint): cint {.importc: "__builtin_clz", nodecl.}
  proc builtin_clz(n: culong): cint {.importc: "__builtin_clzl", nodecl.}
  proc builtin_clz(n: culonglong): cint {.importc: "__builtin_clzll", nodecl.}
  type TbuiltinSupported = cuint or culong or culonglong
    ## Count Leading Zero with optimized builtins routines from GCC/Clang
    ## Warning ⚠: if n = 0, clz is undefined

proc bit_length*[T: SomeInteger](n: T): T =
  ## Calculates how many bits are necessary to represent the number

  when withBuiltins and T is TbuiltinSupported:
    result = if n == T(0): 0                    # Removing this branch would make divmod 4x faster :/
             else: T.sizeof * 8 - builtin_clz(n)

  else:
    var x = n
    while x != T(0):
      x = x shr 1
      inc(result)