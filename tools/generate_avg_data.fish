#!/usr/bin/env fish

if test (count $argv) -lt 3
    echo "required parameters: OUTFILE MIN_LEN MAX_LEN"
    exit 1
end

set -l results $argv[1]
set -l min $argv[2]
set -l max $argv[3]

for exe in (ls zig-out/bin)
    echo -n generating data for $exe:
    echo (string split - -m 1 -f 2 (string split _ -f 2 $exe)) >> $results
    for len in (seq $min $max) ; echo -n $len\t >> $results
        echo -n " $len"
        zig-out/bin/$exe --raw average 1_000_000 $len >> $results
    end
    echo \n >> $results
    echo
end
