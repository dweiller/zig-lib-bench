set term svg background rgb 'white'
set style data histogram
set style histogram rowstacked
set style fill solid
set boxwidth 0.7 relative
stats "memcpy-hist.tsv"
plot for [INDEX=0:STATS_blocks-3:2] "memcpy-hist.tsv" index INDEX using 2:xticlabels(1)
