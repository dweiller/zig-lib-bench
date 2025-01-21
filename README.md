# Zig `@memcpy` benchmarks

### building

Put an object file or archive that exports `memcpy` into a subdirectory `compiler-rt/`. Then run
```console
zig build`
```
which will build a copy of the benchmark executable for each file in `compiler-rt/`. Note that this
repo's `build.zig` will blindly try to build benchmarks for all files in `compiler-rt/` so make sure
they all match the native target (or the one passed with `-Dtarget`). Benchmarks are always built in
`ReleaseFast` mode so you probably also want the objects in `compiler-rt/` to have been built in
`ReleaseFast` mode.

The simplest way to get a suitable object is to modify the Zig compiler-rt source code and then run
`zig build-obj lib/compiler-rt.zig -OReleaseFast`. If there are no files in `compiler-rt/`, a
version of the benchmark will be built with the invoking compiler's `memcpy`.

### tools

For building multiple versions of `compiler-rt` at once, there are convenience scripts
`build-commits.sh` and `build-matrix.sh` in the `tools/` directory. Copy these into a git checkout
of the Zig compiler repo and run them to build `lib/compiler-rt.zig` against multiple commits at
once. They both require a path to a Zig compiler and a file containing a newline-separated list of
commits (they are passed directly to `git checkout`). `build-matrix.sh` additionally requires a
target triple, a file containing a newline-separated list of arguments for `-mcpu` and an
optimization mode and will build `compiler-rt` for the Cartesian product of the specified commits
and CPUs.

Both `build-commits.sh` and `build-matrix.sh` places object files in a subdirectory call
`compiler-rt-commits` this directory can be moved/copied to the `compiler-rt` directory in this repo
in order to build the benchmarks.

To run the benchmarks there are convenience scripts `generate-distrib-data.fish` and
`generate-avg-data.fish` to run the `distrib` and `average` benchmarks respectively. Run them to get
a simple usage message. They both require an `EXE_FILE` argument, which must be a newline-separated
list of executables in `zig-out/bin/` (e.g. you can get one with `ls zig-out/bin/ > exe-list`).
`generate-avg-data.fish` also requires a `LENGTH_FILE` which is a newline-separated list of copy
lengths to benchmark.

If it's inconvenient that there are fish scripts feel to raise an issue or PR more portable scripts.
