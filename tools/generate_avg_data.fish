#!/usr/bin/env fish

if test (count $argv) -lt 4
    echo "required parameters: OUTFILE EXE_FILE LENGTH_FILE ITERATIONS"
    exit 1
end

set -l results $argv[1]
set -l exe_file $argv[2]
set -l len_file $argv[3]
set -l iterations $argv[4]

set -l exe_list (cat $exe_file)
set -l lengths (cat $len_file)

for exe in $exe_list
    echo -n generating data for $exe:
    echo (string split - -m 1 -f 2 (string split _ -f 2 $exe)) >> $results
    for len in $lengths ; echo -n $len\t >> $results
        echo -n " $len"
        zig-out/bin/$exe --raw average $iterations $len >> $results
        if test $status -ne 0
            echo
            echo "zig-out/bin/$exe" failed
            exit $status
        end
    end
    echo \n >> $results
    echo
end
