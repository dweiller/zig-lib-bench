pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    if (args.len < 2) {
        usage(null);
        std.process.exit(1);
    }

    const mode = std.meta.stringToEnum(Mode, args[1]) orelse
        fatal("invalid mode: got \"{s}\", expected \"offsets\" or \"average\"", .{args[1]});

    switch (mode) {
        .offsets => if (args.len != 6) {
            usage(.offsets);
            std.process.exit(1);
        },
        .average => if (args.len != 4) {
            usage(.average);
            std.process.exit(1);
        },
    }

    const iterations = std.fmt.parseInt(usize, args[2], 10) catch |err| {
        fatal("invalid iteration count: {s}", .{@errorName(err)});
    };

    const copy_len = std.fmt.parseInt(usize, args[3], 10) catch |err|
        fatal("invalid copy length: {s}", .{@errorName(err)});

    const s_offset = switch (mode) {
        .offsets => std.fmt.parseInt(usize, args[4], 10) catch |err|
            fatal("invalid source offset: {s}", .{@errorName(err)}),
        .average => alignment,
    };

    const d_offset = switch (mode) {
        .offsets => std.fmt.parseInt(usize, args[5], 10) catch |err|
            fatal("invalid dest offset: {s}", .{@errorName(err)}),
        .average => alignment,
    };

    std.debug.print("copying block of size {d}\n", .{std.fmt.fmtIntSizeBin(copy_len)});

    const src = try allocator.alignedAlloc(u8, alignment, copy_len + s_offset);
    defer allocator.free(src);

    const dest = try allocator.alignedAlloc(u8, alignment, copy_len + d_offset);
    defer allocator.free(dest);

    // make sure all pages are faulted
    @memset(src, 0);
    @memset(dest, 0);

    (switch (mode) {
        .offsets => printResult(
            .{ s_offset, d_offset },
            runOffsets(iterations, copy_len, s_offset, d_offset, dest, src),
            true,
        ),
        .average => printResult(null, runAverage(iterations, copy_len, dest, src), true),
    }) catch |err| std.log.err("could not write results: {s}", .{@errorName(err)});
}

fn runOffsets(
    iterations: usize,
    copy_len: usize,
    s_offset: usize,
    d_offset: usize,
    dest: []u8,
    src: []const u8,
) u64 {
    const time = runOffsetsInner(iterations, copy_len, s_offset, d_offset, dest, src);
    return @intCast((@as(u128, copy_len) * iterations * std.time.ns_per_s) / time);
}

fn runOffsetsInner(
    iterations: usize,
    copy_len: usize,
    s_offset: usize,
    d_offset: usize,
    dest: []u8,
    src: []const u8,
) u64 {
    var timer = std.time.Timer.start() catch @panic("no supported clock available");

    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        _ = @memcpy(dest.ptr[d_offset..][0..copy_len], src.ptr[s_offset..][0..copy_len]);
    }

    const time = timer.lap();

    return time;
}

fn runAverage(iterations: usize, copy_len: usize, dest: []u8, src: []const u8) u64 {
    var times: [alignment * alignment]u64 = undefined;
    for (0..alignment) |s_offset| {
        for (0..alignment, times[s_offset * alignment ..][0..alignment]) |d_offset, *time| {
            time.* = runOffsetsInner(iterations, copy_len, s_offset, d_offset, dest, src);
        }
    }

    var avg: u128 = 0;
    for (times) |time| {
        avg = std.math.add(u128, avg, time) catch @panic("add overflowed");
    }
    avg /= times.len;

    return @intCast((@as(u128, copy_len) * iterations * std.time.ns_per_s) / avg);
}

fn printResult(
    offsets: ?struct { usize, usize },
    throughput: u64,
    human_readable: bool,
) std.fs.File.WriteError!void {
    const stdout = std.io.getStdOut();
    if (offsets) |o| {
        try stdout.writer().print("{d}\t{d}\t", .{ o[0], o[1] });
    }
    if (human_readable) {
        try stdout.writer().print("{:.2}/s\n", .{std.fmt.fmtIntSizeBin(throughput)});
    } else {
        try stdout.writer().print("{d}\n", .{throughput});
    }
}

const alignment = if (std.simd.suggestVectorLength(u8)) |len|
    @alignOf(@Type(.{ .Vector = .{
        .child = u8,
        .len = len,
    } }))
else
    @alignOf(usize);

fn fatal(comptime fmt: []const u8, args: anytype) noreturn {
    const stderr = std.io.getStdErr();
    stderr.writer().print(fmt ++ "\n", args) catch @panic("failed writing error message");
    std.process.exit(1);
}

const Mode = enum {
    offsets,
    average,
};

fn usage(mode: ?Mode) void {
    const stderr = std.io.getStdErr();
    const message = if (mode) |m| switch (m) {
        .offsets => "usage: memcpy-bench offsets ITERATIONS COPY_LENGTH SOURCE_OFFSET DEST_OFFSET\n",
        .average => "usage: memcpy-bench average ITERATIONS COPY_LENGTH\n",
    } else 
    \\usage:
    \\        memcpy-bench offsets ITERATIONS COPY_LENGTH SOURCE_OFSSET DEST_OFFSET
    \\        memcpy-bench average ITERATIONS COPY_LENGTH
    ;

    stderr.writeAll(message) catch @panic("failed to write usage message");
}

const std = @import("std");
