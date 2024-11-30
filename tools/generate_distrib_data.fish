#!/usr/bin/env fish

if test (count $argv) -lt 3
    echo "required parameters: EXE_FILE ITERATIONS RESULT_DIR"
    exit 1
end

set -l exe_file $argv[1]
set -l iterations $argv[2]
set -l result_dir $argv[3]

set -l exe_list (cat $exe_file)

for exe in $exe_list
    set -l commit (string split - -m 2 -f 3 $exe)
    set -l result_file "$result_dir/$commit.tsv"
    echo "generating data for $exe"
    if test -f $result_file
        echo "appending data to existing file $result_file"
    else
        echo "creating file $result_file"
        echo -e "dist\tsrc_offset\tdest_offset\ttime\titerations" > $result_file
    end
    for dist in A B D L M Q S U W
        for i in (seq $iterations)
            zig-out/bin/$exe --raw distrib 0 $dist 0 0 >> $result_file
            if test $status -ne 0
                echo
                echo "zig-out/bin/$exe" failed
                exit 1
            end
        end
    end
end
