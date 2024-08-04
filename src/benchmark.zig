pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    var index: usize = 1;

    const machine_readable = if (std.mem.eql(u8, "--raw", args[index])) true else false;
    index += @intFromBool(machine_readable);

    if (args.len < 1 + index) {
        usage(null);
        std.process.exit(1);
    }

    const mode = std.meta.stringToEnum(Mode, args[index]) orelse {
        fatal("invalid mode: got \"{s}\", available options are:{s}\n", .{ args[index], mode_options });
    };
    index += 1;

    switch (mode) {
        .offsets => if (args.len != 4 + index) {
            usage(.offsets);
            std.process.exit(1);
        },
        .average => if (args.len != 2 + index) {
            usage(.average);
            std.process.exit(1);
        },
        .lrandom => if (args.len != 6 + index) {
            usage(.lrandom);
            std.process.exit(1);
        },
    }

    const iterations = std.fmt.parseInt(usize, args[index], 10) catch |err| {
        fatal("invalid iteration count: {s}", .{@errorName(err)});
    };
    index += 1;

    const seed, const min = blk: {
        if (mode == .lrandom) {
            const seed = std.fmt.parseInt(u64, args[index], 10) catch |err|
                fatal("invalid seed; {s}", .{@errorName(err)});
            index += 1;

            const min = std.fmt.parseInt(u16, args[index], 10) catch |err|
                fatal("invalid min length: {s}", .{@errorName(err)});
            index += 1;

            break :blk .{ seed, min };
        } else break :blk .{ undefined, undefined };
    };

    const copy_len = std.fmt.parseInt(usize, args[index], 10) catch |err|
        fatal("invalid copy length: {s}", .{@errorName(err)});
    index += 1;

    const s_offset = switch (mode) {
        .offsets, .lrandom => blk: {
            index += 1;
            break :blk std.fmt.parseInt(usize, args[index - 1], 10) catch |err|
                fatal("invalid source offset: {s}", .{@errorName(err)});
        },
        .average => alignment,
    };

    const d_offset = switch (mode) {
        .offsets, .lrandom => blk: {
            index += 1;
            break :blk std.fmt.parseInt(usize, args[index - 1], 10) catch |err|
                fatal("invalid dest offset: {s}", .{@errorName(err)});
        },
        .average => alignment,
    };

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
            runOffsets(iterations, copy_len, dest[d_offset..], src[s_offset..]),
            machine_readable,
        ),
        .average => printResult(null, runAverage(iterations, copy_len, dest, src), machine_readable),
        .lrandom => printResult(
            .{ s_offset, d_offset },
            runRandom(
                allocator,
                seed,
                iterations,
                min,
                std.math.cast(u16, copy_len) orelse @panic("invalid max length: TooLong"),
                dest[d_offset..],
                src[s_offset..],
            ),
            machine_readable,
        ),
    }) catch |err| std.log.err("could not write results: {s}", .{@errorName(err)});
}

fn runOffsets(
    iterations: usize,
    copy_len: usize,
    dest: []u8,
    src: []const u8,
) f64 {
    const time = runOffsetsInner(iterations, copy_len, dest, src);
    return @as(f64, @floatFromInt(time)) / @as(f64, @floatFromInt(iterations));
}

fn runOffsetsInner(
    iterations: usize,
    copy_len: usize,
    dest: []u8,
    src: []const u8,
) u64 {
    var timer = std.time.Timer.start() catch @panic("no supported clock available");

    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        @memcpy(dest[0..copy_len], src[0..copy_len]);
    }

    const time = timer.read();

    return time;
}

fn runAverage(iterations: usize, copy_len: usize, dest: []u8, src: []const u8) f64 {
    var times: [alignment * alignment]u64 = undefined;
    for (0..alignment) |s_offset| {
        for (0..alignment, times[s_offset * alignment ..][0..alignment]) |d_offset, *time| {
            time.* = runOffsetsInner(iterations, copy_len, dest[d_offset..], src[s_offset..]);
        }
    }

    var sum: u128 = 0;
    for (times) |time| {
        sum = std.math.add(u128, sum, time) catch @panic("add overflowed");
    }

    return @as(f64, @floatFromInt(sum)) / @as(f64, @floatFromInt(iterations));
}

fn runRandom(
    allocator: Allocator,
    seed: u64,
    iterations: usize,
    min_length: u16,
    max_length: u16,
    dest: []u8,
    src: []const u8,
) f64 {
    const lengths = allocator.alloc(u16, iterations) catch @panic("could not allocate lengths buffer");
    defer allocator.free(lengths);

    var rng = std.Random.DefaultPrng.init(seed);
    const random = rng.random();

    for (lengths) |*length| {
        length.* = random.intRangeAtMost(u16, min_length, max_length);
    }

    var copied_bytes: u64 = 0;
    var timer = std.time.Timer.start() catch @panic("no supported clock available");

    for (lengths) |copy_len| {
        @memcpy(dest[0..copy_len], src[0..copy_len]);
        copied_bytes += copy_len;
    }

    const time = timer.read();

    return @floatFromInt(time);
}

fn printResult(
    offsets: ?struct { usize, usize },
    value: f64,
    machine_readable: bool,
) std.fs.File.WriteError!void {
    const stdout = std.io.getStdOut();
    if (offsets) |o| {
        try stdout.writer().print("{d}\t{d}\t", .{ o[0], o[1] });
    }
    if (!machine_readable) {
        try stdout.writer().print("{:.2}\n", .{std.fmt.fmtDuration(@intFromFloat(value))});
    } else {
        try stdout.writer().print("{d}\n", .{value});
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
    lrandom,
};

const mode_options = blk: {
    var buf: []const u8 = "";
    for (@typeInfo(Mode).Enum.fields) |field| {
        buf = buf ++ "\n\t" ++ field.name;
    }
    break :blk buf;
};

fn usage(mode: ?Mode) void {
    const stderr = std.io.getStdErr();
    const message = if (mode) |m| switch (m) {
        .offsets => "usage: memcpy-bench offsets ITERATIONS COPY_LENGTH SOURCE_OFFSET DEST_OFFSET\n",
        .average => "usage: memcpy-bench average ITERATIONS COPY_LENGTH\n",
        .lrandom => "usage: memcpy-bench lrandom ITERATIONS SEED MIN_LENGTH MAX_LENGTH SOURCE_OFFSET DEST_OFFSET\n",
    } else 
    \\usage:
    \\        memcpy-bench offsets ITERATIONS COPY_LENGTH SOURCE_OFSSET DEST_OFFSET
    \\        memcpy-bench average ITERATIONS COPY_LENGTH
    \\        memcpy-bench lrandom ITERATIONS SEED MIN_LENGTH MAX_LENGTH SOURCE_OFFSET DEST_OFFSET
    \\
    ;

    stderr.writeAll(message) catch @panic("failed to write usage message");
}

const std = @import("std");
const Allocator = std.mem.Allocator;
