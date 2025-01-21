#!/usr/bin/env fish

if test (count $argv) -lt 4
    echo "required parameters: EXE_FILE LENGTH_FILE ITERATIONS RESULT_DIR"
    exit 1
end

set -l exe_file $argv[1]
set -l len_file $argv[2]
set -l iterations $argv[3]
set -l result_dir $argv[4]

set -l exe_list (cat $exe_file)
set -l lengths (cat $len_file)

for exe in $exe_list
    echo -n generating data for $exe:
    set -l commit (string split - -m 2 -f 3 $exe)
    set -l result_file "$result_dir/$commit.tsv"
    echo -e "len\ttime" > $result_file
    for len in $lengths ; echo -n $len\t >> $result_file
        echo -n " $len"
        zig-out/bin/$exe --raw average $iterations $len >> $result_file
        if test $status -ne 0
            echo
            echo "zig-out/bin/$exe" failed
            exit $status
        end
    end
    echo
end
