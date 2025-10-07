const Cli = zli.CliCommand("memset-bench", .{
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
        .name = .{ .long = .{ .full = "offset" } },
        .short_help = "dest offset",
        .type = usize,
    },
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
    const distribution = params.distribution orelse {
        std.log.err("must provide '--distribution", .{});
        return error.AlreadyHandled;
    };
    const offset = params.offset orelse 0;

    const max_len = 4096;
    const buffer = try allocator.alignedAlloc(
        u8,
        .fromByteUnits(std.heap.pageSize()),
        max_len + offset,
    );
    defer allocator.free(buffer);

    // make sure all pages are faulted
    @memset(buffer, 0);

    var rng = std.Random.DefaultPrng.init(seed);
    var param_generator: ParamGenerator = .{
        .allocator = allocator,
        .dist = distribution,
        .dest = buffer[offset..][0..max_len],
        .value = 1,
        .random = rng.random(),
    };

    const f = struct {
        fn f(d: []u8, v: u8) void {
            @memset(d, v);
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
        offset,
        results,
        machine_readable,
    );
}

const Distribution = std.meta.DeclEnum(@import("distribution"));

const ParamGenerator = struct {
    allocator: Allocator,
    dist: Distribution,
    dest: []u8,
    value: u8,
    random: std.Random,

    pub const Batch = struct {
        dest_buffer: []const []u8,
        value: u8,
        index: usize,

        pub fn next(self: *Batch) ?struct { []u8, u8 } {
            if (self.index == 0) return null;
            self.index -= 1;
            return .{ self.dest_buffer[self.index], self.value };
        }
    };

    pub fn generate_batch(self: *ParamGenerator, iterations: usize) !Batch {
        const dest_buffer = try self.allocator.alloc([]u8, iterations);
        std.log.debug("generating batch for {d} iterations", .{iterations});

        const distribution = @import("distribution");
        const weights = switch (self.dist) {
            inline else => |t| @field(distribution, @tagName(t)),
        };

        for (dest_buffer) |*d| {
            const len = self.random.weightedIndex(f64, &weights);
            d.* = self.dest[0..len];
        }
        return .{
            .dest_buffer = dest_buffer,
            .value = self.random.int(u8),
            .index = iterations,
        };
    }

    pub fn deinit_batch(self: ParamGenerator, batch: Batch) void {
        self.allocator.free(batch.dest_buffer);
    }
};

fn printResult(
    distribution: Distribution,
    offset: usize,
    result: benchmark.Result,
    machine_readable: bool,
) !void {
    var stdout = std.fs.File.stdout().writer(&.{});
    const writer = &stdout.interface;
    if (!machine_readable) {
        try table.format(
            writer,
            &.{
                .{ .fmt = "{s}", .header = "dist", .alignment = .middle },
                .{ .fmt = "{D}", .header = "time", .alignment = .{ .separator = '.' } },
                .{ .fmt = "{d}", .header = "iterations", .alignment = .right },
                .{ .fmt = "{t}", .header = "termination", .alignment = .middle },
                .{ .fmt = "{d}", .header = "offset", .alignment = .right },
            },
            .{},
            [1]struct {
                []const u8,
                u64,
                u32,
                benchmark.TerminationCondition,
                usize,
            }{
                .{
                    @tagName(distribution),
                    @intFromFloat(result.duration),
                    result.iterations,
                    result.termination,
                    offset,
                },
            },
        );
    } else {
        try writer.print("{s}\t{d}\t{d}\t{d}\n", .{
            @tagName(distribution),
            offset,
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
