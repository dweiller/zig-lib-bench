const Cli = zli.CliCommand("memmove-bench", .{
    .parameters = &.{
        .{
            .name = .{ .long = .{ .full = "machine-readable" } },
            .short_help = "output results in machine-readable tsv format",
            .type = bool,
        },
        .{
            .name = .{ .long = .{ .full = "seed" } },
            .short_help = "seed for random number generator",
            .type = u64,
        },
    },
    .subcommands = &.{
        .{
            .name = "distrib",
            .parameters = &distrib_args,
            .help_message = "run benchmark against Google memcpy distributions",
        },
    },
});

const distrib_args = [_]zli.Arg{
    .{
        .name = .{ .long = .{ .full = "iterations" } },
        .short_help = "minimum number of iterations per distribution",
        .type = usize,
    },
    .{
        .name = .{ .long = .{ .full = "distribution" } },
        .short_help = "distribution to benchmark",
        .type = Distribution,
    },
    .{
        .name = .{ .long = .{ .full = "offset-src" } },
        .short_help = "source pointer offset",
        .type = usize,
    },
    // .{
    //     .name = .{ .long = .{ .full = "align-dest" } },
    //     .short_help = "destination pointer alignment, ignored if --align-src and --offset are both provided",
    //     .type = usize,
    // },
    .{
        .name = .{ .long = .{ .full = "offset" } },
        .short_help = "offset (dest - src) when moving within the same buffer",
        .type = isize,
    },
    // .{
    //     .name = .{ .long = .{ .full = "non-overlapping" } },
    //     .short_help = "include non-overlapping copies",
    //     .type = bool,
    // },
};

pub fn main() u8 {
    return parseAndRun() catch |err| {
        switch (err) {
            error.AlreadyHandled => return 1,
            else => {
                std.log.err("{s}", .{@errorName(err)});
                if (@errorReturnTrace()) |trace| {
                    std.debug.dumpStackTrace(trace.*);
                }
                return 2;
            },
        }
    };
}

fn parseAndRun() !u8 {
    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();

    const arena_allocator = arena.allocator();

    const parse_result = try Cli.parse(arena_allocator);
    defer parse_result.deinit(arena_allocator);

    const params = switch (parse_result) {
        .ok => |params| params,
        .err => |err| {
            err.renderToStdErr();
            return 1;
        },
    };

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer std.debug.assert(gpa.deinit() == .ok);
    try run(gpa.allocator(), params);
    return 0;
}

fn run(allocator: std.mem.Allocator, params: Cli.Params) !void {
    const subcommand = params.subcommand orelse {
        try Cli.printHelp();
        return std.process.cleanExit();
    };

    const seed = params.options.seed orelse 0;
    const machine_readable = if (params.options.@"machine-readable")
        true
    else
        !std.fs.File.stdout().isTty();

    switch (subcommand) {
        .distrib => |sc| try runDistrib(allocator, seed, machine_readable, sc),
    }
}

fn runDistrib(
    allocator: std.mem.Allocator,
    seed: u64,
    machine_readable: bool,
    params: zli.Options(&distrib_args),
) !void {
    const move_offset = params.offset orelse {
        std.log.err("must provide '--offset'", .{});
        return error.AlreadyHandled;
    };
    const distribution = params.distribution orelse {
        std.log.err("must provide '--distribution", .{});
        return error.AlreadyHandled;
    };
    const src_offset = params.@"offset-src" orelse 0;

    const max_copy_len = 4096;
    const buffer = try allocator.alignedAlloc(
        u8,
        .fromByteUnits(std.heap.pageSize()),
        src_offset + max_copy_len + @abs(move_offset),
    );
    defer allocator.free(buffer);

    // make sure all pages are faulted
    @memset(buffer, 0);

    const src, const dest = blk: {
        var src_start: usize = src_offset;
        var dest_start: usize = src_offset;

        if (move_offset > 0)
            dest_start += @as(usize, @intCast(move_offset))
        else
            src_start += @as(usize, @intCast(-move_offset));

        break :blk .{
            buffer[src_start..][0..max_copy_len],
            buffer[dest_start..][0..max_copy_len],
        };
    };

    var rng = std.Random.DefaultPrng.init(seed);
    var param_generator: ParamGenerator = .{
        .allocator = allocator,
        .dist = distribution,
        .src = src,
        .dest = dest,
        .random = rng.random(),
    };

    const f = struct {
        extern fn memmove(?[*]u8, ?[*]const u8, usize) ?[*]u8;
        fn f(noalias d: []u8, noalias s: []const u8) void {
            _ = memmove(d.ptr, s.ptr, d.len);
        }
    }.f;

    const results = try benchmark.benchmark(
        .{
            .initial_iterations = 2000,
        },
        f,
        &param_generator,
    );

    try printResult(
        distribution,
        .{ src_offset, move_offset },
        results,
        machine_readable,
    );
}

const Distribution = std.meta.DeclEnum(@import("distribution"));

const ParamGenerator = struct {
    allocator: Allocator,
    dist: Distribution,
    dest: []u8,
    src: []const u8,
    random: std.Random,

    pub const Batch = struct {
        dest_buffer: []const []u8,
        src_buffer: []const []const u8,
        index: usize,

        pub fn next(self: *Batch) ?struct { []u8, []const u8 } {
            if (self.index == 0) return null;
            self.index -= 1;
            return .{ self.dest_buffer[self.index], self.src_buffer[self.index] };
        }
    };

    pub fn generate_batch(self: *ParamGenerator, iterations: usize) !Batch {
        const dest_buffer = try self.allocator.alloc([]u8, iterations);
        const src_buffer = try self.allocator.alloc([]const u8, iterations);
        std.log.debug("generating batch for {d} iterations", .{iterations});

        const distribution = @import("distribution");
        const weights = switch (self.dist) {
            inline else => |t| @field(distribution, @tagName(t)),
        };

        for (dest_buffer, src_buffer) |*d, *s| {
            const len = self.random.weightedIndex(f64, &weights);
            d.* = self.dest[0..len];
            s.* = self.src[0..len];
        }
        return .{
            .dest_buffer = dest_buffer,
            .src_buffer = src_buffer,
            .index = iterations,
        };
    }

    pub fn deinit_batch(self: ParamGenerator, batch: Batch) void {
        self.allocator.free(batch.dest_buffer);
        self.allocator.free(batch.src_buffer);
    }
};

fn printResult(
    distribution: Distribution,
    offsets: struct { usize, isize },
    result: benchmark.Result,
    machine_readable: bool,
) !void {
    var stdout = std.fs.File.stdout().writer(&.{});
    const writer = &stdout.interface;
    defer writer.flush() catch {};
    if (!machine_readable) {
        try table.format(
            writer,
            &.{
                .{ .fmt = "{s}", .header = "dist", .alignment = .middle },
                .{ .fmt = "{D}", .header = "time", .alignment = .{ .separator = '.' } },
                .{ .fmt = "{d}", .header = "iterations", .alignment = .right },
                .{ .fmt = "{t}", .header = "termination", .alignment = .middle },
                .{ .fmt = "{d}", .header = "src offset", .alignment = .right },
                .{ .fmt = "{d}", .header = "move offset", .alignment = .right },
            },
            .{},
            [1]struct {
                []const u8,
                u64,
                u32,
                benchmark.TerminationCondition,
                usize,
                isize,
            }{
                .{
                    @tagName(distribution),
                    @intFromFloat(result.duration),
                    result.iterations,
                    result.termination,
                    offsets[0],
                    offsets[1],
                },
            },
        );
    } else {
        try writer.print("{s}\t{d}\t{d}\t{d}\t{d}\n", .{
            @tagName(distribution),
            offsets[0],
            offsets[1],
            result.duration,
            result.iterations,
        });
    }
}

const alignment = if (std.simd.suggestVectorLength(u8)) |len|
    @alignOf(@Vector(len, u8))
else
    @alignOf(usize);

const Mode = enum {
    offsets,
    average,
    lrandom,
    distrib,
};

const mode_options = blk: {
    var buf: []const u8 = "";
    for (@typeInfo(Mode).@"enum".fields) |field| {
        buf = buf ++ "\n\t" ++ field.name;
    }
    break :blk buf;
};

const std = @import("std");
const Allocator = std.mem.Allocator;

const benchmark = @import("benchmark.zig");
const table = @import("table");

const zli = @import("zli");
