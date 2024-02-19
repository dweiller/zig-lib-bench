set term svg size 600,480 dynamic background rgb 'white'
set xlabel 'bytes'
set ylabel 'ns'
set title 'ns per copy, averaged over ' . ARGV[4] . ' iterations'
set xrange [-1:ARGV[3]]
plot for [i=0:ARGV[2]] ARGV[1] index i using 1:2 with points pt 0 title columnhead
