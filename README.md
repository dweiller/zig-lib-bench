# Zig `@memcpy` benchmarks

### building

Put an object file or archive that exports `memcpy` into a subdirectory `compiler-rt/`. Then run
```sh
zig build -Doptimize=ReleaseFast`
```
which will build a copy of the benchmark executable for each file in `compiler-rt`. The simplest way
to get a suitable archive is to modify the zig compiler-rt source code and then run `zig build-lib
lib/compiler-rt.zig -OReleaseFast`. If there are no files in `compiler-rt`, a version of the
benchmark built against the invoking compiler's `memcpy` will be used.
