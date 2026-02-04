fn destructor() callconv(.c) void {
    const io = std.Options.debug_io;

    const filename = if (std.c.getenv("MEMCPY_HIST_FILENAME")) |p|
        std.mem.sliceTo(p, 0)
    else
        "memcpy-hist.tsv";

    const file = std.Io.Dir.cwd().createFile(io, filename, .{
        .truncate = false,
        .lock = .exclusive,
    }) catch |err| {
        std.log.err("could not open memcpy-hist.csv: {s}", .{@errorName(err)});
        return;
    };
    defer file.close(io);

    var buffer: [64]u8 = undefined;
    var file_writer = file.writer(io, &buffer);

    const offset = file.length(io) catch |e| {
        std.log.err("could not append to {s}: {t}", .{ filename, e });
        return;
    };

    file_writer.seekToUnbuffered(offset) catch |e| {
        std.log.err("could not append to {s}: {t}", .{ filename, e });
        return;
    };

    writeHistogram(&file_writer.interface) catch |err| {
        std.log.err("could not write {s}: {t}", .{ filename, err });
    };
}

var cmdline_opt: ?[]u8 = null;

fn constructor(c_argc: c_int, c_argv: [*][*:0]c_char, c_envp: [*:null]?[*:0]c_char) callconv(.c) void {
    _ = c_envp;

    const argv = @as([*][*:0]u8, @ptrCast(c_argv))[0..@intCast(c_argc)];
    const args: std.process.Args = .{ .vector = argv };

    var size: usize = 0;
    {
        var iter = args.iterate();

        if (iter.next()) |arg| {
            size += arg.len;
        } else return;

        while (iter.next()) |arg| {
            size += arg.len + 1;
        }
    }

    var buffer = std.ArrayList(u8).initCapacity(std.heap.page_allocator, size) catch return;

    var iter = args.iterate();
    buffer.appendSliceAssumeCapacity(iter.next() orelse unreachable);

    while (iter.next()) |arg| {
        buffer.appendAssumeCapacity(' ');
        buffer.appendSliceAssumeCapacity(arg);
    }

    cmdline_opt = buffer.items;
}

fn writeHistogram(writer: *std.Io.Writer) !void {
    if (cmdline_opt) |cmdline| {
        try writer.print("# {s}\n", .{cmdline});
    }

    try writer.writeAll("\n# memcpy length\n#len\tcount\n");
    for (memcpy_len[0 .. memcpy_len.len - 1], 0..) |count, length| {
        try writer.print("{d}\t{d}\n", .{ length, count });
    }
    try writer.print(
        "big\t{d}\n\n\n# memcpy alignments\n#dest\tsrc\tcount\n",
        .{memcpy_len[memcpy_len.len - 1]},
    );
    for (memcpy_align, 0..) |src, d_align| {
        for (src, 0..) |count, s_align| {
            try writer.print("{d}\t{d}\t{d}\n", .{ d_align, s_align, count });
        }
    }
    try writer.splatByteAll('\n', 2);
}

export const fini_array: [1]*const fn () callconv(.c) void linksection(".fini_array") = .{&destructor};

export const init_array: [1]*const fn (
    c_int,
    [*][*:0]c_char,
    [*:null]?[*:0]c_char,
) callconv(.c) void linksection(".init_array") = .{&constructor};

const CopyType = if (std.simd.suggestVectorLength(u8)) |len|
    @Vector(len, u8)
else
    usize;

const alignment = @alignOf(CopyType);

var memcpy_len: [258]u32 = .{0} ** 258;
var memcpy_align: [alignment][alignment]u32 = .{.{0} ** alignment} ** alignment;

export fn memcpy(noalias dest: ?[*]u8, noalias src: ?[*]u8, len: usize) ?[*]u8 {
    @setRuntimeSafety(false);

    if (len != 0) {
        var d = dest.?;
        var s = src.?;
        var n = len;
        while (true) {
            d[0] = s[0];
            n -= 1;
            if (n == 0) break;
            d += 1;
            s += 1;
        }
    }

    const len_idx = @min(257, len);
    memcpy_len[len_idx] +|= 1;

    const d_align = @intFromPtr(dest.?) % alignment;
    const s_align = @intFromPtr(src.?) % alignment;
    memcpy_align[d_align][s_align] +|= 1;

    return dest;
}

const std = @import("std");
