#!/bin/sh

if [ $# -ne 2 ]
then
    echo "usage: build-commits.sh <COMPILER> <COMMIT-FILE>"
    exit 1
fi

compiler=$1
commit_file=$2

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
    name=${commit}-fast.o
    $compiler build-obj -OReleaseFast -fno-builtin lib/compiler_rt.zig -femit-bin=${out_dir}/${name}
    rm ${out_dir}/${name}.o
done

git checkout $initial_commit 2> /dev/null
