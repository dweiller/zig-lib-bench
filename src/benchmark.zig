pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    if (args.len != 5) {
        usage();
        std.process.exit(1);
    }

    const iterations = std.fmt.parseInt(usize, args[1], 10) catch |err| {
        fatal("invalid iteration count: {s}", .{@errorName(err)});
    };

    const copy_len = std.fmt.parseInt(usize, args[2], 10) catch |err|
        fatal("invalid copy length: {s}", .{@errorName(err)});

    const s_offset = std.fmt.parseInt(usize, args[3], 10) catch |err|
        fatal("invalid source offset: {s}", .{@errorName(err)});

    const d_offset = std.fmt.parseInt(usize, args[4], 10) catch |err|
        fatal("invalid dest offset: {s}", .{@errorName(err)});

    std.debug.print("copying block of size {d}\n", .{std.fmt.fmtIntSizeBin(copy_len)});

    const alignment = if (std.simd.suggestVectorLength(u8)) |len|
        @alignOf(@Type(.{ .Vector = .{
            .child = u8,
            .len = len,
        } }))
    else
        @alignOf(usize);

    const src = try allocator.alignedAlloc(u8, alignment, copy_len + s_offset);
    defer allocator.free(src);

    const dest = try allocator.alignedAlloc(u8, alignment, copy_len + d_offset);
    defer allocator.free(dest);

    // make sure all pages are faulted
    @memset(src, 0);
    @memset(dest, 0);

    var timer = try std.time.Timer.start();

    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        _ = @memcpy(dest.ptr[d_offset..][0..copy_len], src.ptr[s_offset..][0..copy_len]);
    }

    const time = timer.lap();

    const throughput: u64 = @intCast((@as(u128, copy_len) * iterations * std.time.ns_per_s) / time);

    const stdout = std.io.getStdOut();
    stdout.writer().print(
        "{d}\t{d}\t{:.2}\n",
        .{
            s_offset,
            d_offset,
            std.fmt.fmtIntSizeBin(throughput),
        },
    ) catch @panic("failed to write to stdout");
}

fn fatal(comptime fmt: []const u8, args: anytype) noreturn {
    const stderr = std.io.getStdErr();
    stderr.writer().print(fmt ++ "\n", args) catch @panic("failed writing error message");
    std.process.exit(1);
}

fn usage() void {
    const stderr = std.io.getStdErr();
    stderr.writeAll(
        \\\usage: memcpy-bench ITERATIONS COPY_LENGTH SOURCE_OFFSET DEST_OFFSET
        \\\
    ) catch @panic("failed to write usage message");
}

const std = @import("std");
