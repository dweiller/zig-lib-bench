#!/bin/sh

if [ $# -ne 5 ]
then
    echo "usage: measure-size.sh <COMPILER> <COMMIT-FILE> <TARGET> <CPU-FILE> <OPTIMIZE-MODE>"
    exit 1
fi

compiler=$1
commit_file=$2
target=$3
cpu_file=$4
mode=$5

initial_commit=$(git rev-parse --abbrev-ref HEAD)

out_dir=compiler-rt-commits

if [ ! -d $out_dir ]; then
    mkdir $out_dir
fi

for commit in $(cat $commit_file)
do
    git checkout $commit 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "failed to checkout $commit"
        exit 1;
    fi
    for cpu in $(cat $cpu_file)
    do
        name=${commit}-${target}-${cpu}-${mode}.o
        $compiler build-obj -O$mode -target $target -mcpu $cpu -fno-builtin lib/compiler-rt.zig -femit-bin=${out_dir}/${name}
        rm ${out_dir}/${name}.o
    done
done

git checkout $initial_commit 2> /dev/null
