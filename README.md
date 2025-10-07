# Zig buffer benchmarks

### building

Put object files or archives that export the desired function to test (e.g. `memcpy`) into a
subdirectory, and then run
```console
zig build -Dobject-dir=OBJ_DIR`
```
which will build a copy of the benchmark executable for each file in `OBJ_DIR/`. Note that this
repo's `build.zig` will blindly try to build benchmarks for all files in `OBJ_DIR/` so make sure
they all match the native target (or the one passed with `-Dtarget`). Benchmarks are always built in
`ReleaseFast` mode.

The simplest way to get a suitable object is to modify the Zig compiler-rt source code and then run
`zig build-obj lib/compiler-rt.zig -OReleaseFast`. If there are no files in `OBJ_DIR/` (or
`-Dobject-dir` is not passed), benchmarks will be built using functions from the the invoking
compiler's compiler-rt.

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
`compiler-rt-commits` this directory can be moved/copied to suitable place to be used with
`-Dobject-dir` in order to build the benchmarks.

To run the benchmarks there are some convenience scripts in the `tools/` directory. Run them to get
a simple usage message. They require an `EXE_FILE` argument, which must be a newline-separated
list of executables in `zig-out/bin/` (e.g. you can get one with `ls zig-out/bin/ > exe-list`).

If it's inconvenient that there are fish scripts feel to raise an issue or PR more portable scripts.
