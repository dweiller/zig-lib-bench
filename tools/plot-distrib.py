import polars as pl
import altair as alt

import argparse
import sys
import os

def load_data(files):
    data = pl.concat([
        pl.read_csv(x, separator="\t").with_columns(version=pl.lit(os.path.splitext(x)[0])) for x in files
    ])
    return data

def bar_plot(data, legend_title):
    return alt.Chart(data).mark_bar().encode(
        x=alt.X("dist:N", title="distribution").axis(labelAngle=0),
        y=alt.Y("mean(time):Q", title="mean time (ns)"),
        color=alt.Color("version:N").title(legend_title),
        xOffset="version:O",
    ).properties(
        title=alt.Title("memcpy performance", subtitle="Google distributions"),
        width=600,
        height=400,
    )

def error_bars(data):
    return alt.Chart(data).mark_errorbar(extent="ci").encode(
        x="dist:N",
        y=alt.Y("time:Q", title="confidence interval"),
        xOffset="version:O",
    )

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", help="output file")
    parser.add_argument("--legend-title", default="commit", help="title to use for the legend")
    parser.add_argument("files", nargs='*', help="input data tsv files")
    args = parser.parse_args()

    data = load_data(args.files)
    bars = bar_plot(data, args.legend_title);
    errors = error_bars(data);
    combined = bars + errors

    if args.output:
        combined.save(args.output)
    else:
        sys.stdout.write(combined.to_json())

if __name__ == "__main__":
    main()
