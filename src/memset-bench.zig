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
            .help_message = "run benchmark against Google memset distributions",
        },
        .{
            .name = "scan",
            .parameters = &scan_args,
            .help_message = "benchmark single individual sizes",
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
        .short_help = "dest offset from page boundary",
        .type = usize,
    },
};

const scan_args = [_]zli.Arg{
    .{
        .name = .{ .long = .{ .full = "size" } },
        .short_help = "set of sizes to benchmark",
        .type = []const u8,
    },
    .{
        .name = .{ .long = .{ .full = "offset" } },
        .short_help = "dest offset from page boundary",
        .type = usize,
    },
};

pub fn main(init: std.process.Init) u8 {
    parseAndRun(init.io, init.arena, init.gpa, init.minimal.args) catch |err| {
        switch (err) {
            error.AlreadyHandled => return 1,
            else => {
                std.log.err("{s}", .{@errorName(err)});
                if (@errorReturnTrace()) |trace| {
                    std.debug.dumpStackTrace(trace);
                }
                return 2;
            },
        }
    };
    return 0;
}

fn parseAndRun(
    io: std.Io,
    arena: *std.heap.ArenaAllocator,
    gpa: std.mem.Allocator,
    args: std.process.Args,
) !void {
    const parse_result = try Cli.parse(io, arena.allocator(), args);
    defer parse_result.deinit(arena.allocator());

    const params = switch (parse_result) {
        .ok => |params| params,
        .err => |err| {
            err.renderToStdErr(io);
            return error.AlreadyHandled;
        },
    };

    try run(io, gpa, params);
}

fn run(io: std.Io, allocator: std.mem.Allocator, params: Cli.Params) !void {
    const subcommand = params.subcommand orelse {
        try Cli.printHelp(io);
        return std.process.cleanExit(io);
    };

    const seed = params.options.seed orelse 0;
    const machine_readable = if (params.options.@"machine-readable")
        true
    else
        !(std.Io.File.stdout().isTty(io) catch false);

    switch (subcommand) {
        .distrib => |sc| try runDistrib(io, allocator, seed, machine_readable, sc),
        .scan => |sc| try runScan(io, allocator, seed, machine_readable, sc),
    }
}

fn runDistrib(
    io: std.Io,
    allocator: std.mem.Allocator,
    seed: u64,
    machine_readable: bool,
    params: zli.Options(&distrib_args),
) !void {
    const distributions = if (params.distribution) |dist|
        &.{dist}
    else
        std.enums.values(Distribution);
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

    var results: [@typeInfo(Distribution).@"enum".fields.len]DistResult = undefined;

    for (distributions, results[0..distributions.len]) |dist, *res| {
        var rng: std.Random.DefaultPrng = .init(seed);
        var param_generator: DistParamGenerator = .{
            .allocator = allocator,
            .dist = dist,
            .dest = buffer[offset..][0..max_len],
            .random = rng.random(),
        };

        const result = try benchmark.benchmark(
            .{
                .initial_iterations = 2000,
            },
            memset,
            &param_generator,
        );
        res.* = .{
            .distribution = @tagName(dist),
            .duration = result.timePerIteration(),
            .iterations = result.iterations,
            .termination = result.termination,
            .offset = offset,
        };
    }

    var stdout = std.Io.File.stdout().writer(io, &.{});
    try printDistResult(
        &stdout.interface,
        results[0..distributions.len],
        machine_readable,
    );
}

fn runScan(
    io: std.Io,
    allocator: std.mem.Allocator,
    seed: u64,
    machine_readable: bool,
    params: zli.Options(&scan_args),
) !void {
    const offset = params.offset orelse 0;

    var result_buffer: std.ArrayList(ScanResult) = .empty;
    if (params.size) |size_arg| {
        if (size_arg.len == 0) {
            std.log.err("argument to '--size' must not be empty", .{});
            return error.AlreadyHandled;
        }
        var field_iter = std.mem.splitScalar(u8, size_arg, ',');
        while (field_iter.next()) |size_str| {
            const start, const end, const step = try parseIntRange(size_str);
            try scanRange(allocator, &result_buffer, start, end, step, offset, seed);
        }
    } else {
        std.log.err("missing expected '--size' argument", .{});
        return error.AlreadyHandled;
    }

    var stdout = std.Io.File.stdout().writer(io, &.{});
    try printScanResult(&stdout.interface, result_buffer.items, machine_readable);
}

fn scanRange(
    allocator: Allocator,
    result_buffer: *std.ArrayList(ScanResult),
    start: usize,
    end: usize,
    step: usize,
    offset: usize,
    seed: u64,
) !void {
    assert(start <= end);

    const count = (end - start) / step + 1;
    const results = try result_buffer.addManyAsSlice(allocator, count);

    const dest = try allocator.alignedAlloc(
        u8,
        .fromByteUnits(std.heap.pageSize()),
        end + offset,
    );
    defer allocator.free(dest);

    // make sure all pages are faulted
    @memset(dest, 0);

    var size = start;
    for (results) |*res| {
        var rng: std.Random.DefaultPrng = .init(seed);
        var param_generator: ScanParamGenerator = .{
            .random = rng.random(),
            .dest = dest[offset..][0..size],
        };
        const result = try benchmark.benchmark(
            .{ .initial_iterations = 2000 },
            memset,
            &param_generator,
        );
        res.* = .{
            .size = size,
            .duration = result.timePerIteration(),
            .iterations = result.iterations,
            .termination = result.termination,
            .offset = offset,
            .bytes_per_ns = @as(f64, @floatFromInt(size)) / result.timePerIteration(),
        };
        size += step;
    }
}

fn parseIntRange(buffer: []const u8) !struct { usize, usize, usize } {
    const sep = std.mem.findScalar(u8, buffer, '-') orelse {
        const value = std.fmt.parseInt(usize, buffer, 0) catch {
            std.log.err("invalid size '{s}'", .{buffer});
            return error.AlreadyHandled;
        };
        return .{ value, value, 1 };
    };

    if (sep == 0 or sep == buffer.len - 1) {
        std.log.err("size range cannot be open-ended", .{});
        return error.AlreadyHandled;
    }

    const start = std.fmt.parseInt(usize, buffer[0..sep], 0) catch {
        std.log.err("invalid size '{s}'", .{buffer[0..sep]});
        return error.AlreadyHandled;
    };

    const colon = std.mem.findScalarPos(u8, buffer, sep + 1, ':') orelse buffer.len;
    const end = std.fmt.parseInt(usize, buffer[sep + 1 .. colon], 0) catch {
        std.log.err("invalid size '{s}'", .{buffer[sep + 1 .. colon]});
        return error.AlreadyHandled;
    };

    const step = if (colon < buffer.len - 1)
        std.fmt.parseInt(usize, buffer[colon + 1 ..], 0) catch {
            std.log.err("invalid step in range '{s}'", .{buffer});
            return error.AlreadyHandled;
        }
    else
        1;

    if (end < start) {
        std.log.err("start of size range '{s}' is smaller than then end", .{buffer});
        return error.AlreadyHandled;
    }

    return .{ start, end, step };
}

fn memset(d: []u8, v: u8) void {
    @memset(d, v);
}

const ScanResult = struct {
    size: usize,
    duration: f64,
    iterations: u32,
    termination: benchmark.TerminationCondition,
    offset: usize,
    bytes_per_ns: f64,
};

const DistResult = struct {
    distribution: []const u8,
    duration: f64,
    iterations: u32,
    termination: benchmark.TerminationCondition,
    offset: usize,
};

const Distribution = std.meta.DeclEnum(@import("distribution"));

const DistParamGenerator = struct {
    allocator: Allocator,
    dist: Distribution,
    dest: []u8,
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

    pub fn generate_batch(self: *DistParamGenerator, iterations: usize) !Batch {
        const dest_buffer = try self.allocator.alloc([]u8, iterations);
        std.log.debug("generating batch for {d} iterations", .{iterations});

        const distribution = @import("distribution");
        const weights: []const f64 = switch (self.dist) {
            inline else => |t| &@field(distribution, @tagName(t)),
        };

        for (dest_buffer) |*d| {
            const len = self.random.weightedIndex(f64, weights);
            d.* = self.dest[0..len];
        }
        return .{
            .dest_buffer = dest_buffer,
            .value = self.random.int(u8),
            .index = iterations,
        };
    }

    pub fn deinit_batch(self: DistParamGenerator, batch: Batch) void {
        self.allocator.free(batch.dest_buffer);
    }
};

const ScanParamGenerator = struct {
    random: std.Random,
    dest: []u8,

    pub const Batch = struct {
        value: u8,
        dest: []u8,
        iterations: usize,

        pub fn next(self: *Batch) ?struct { []u8, u8 } {
            if (self.iterations == 0) return null;
            self.iterations -= 1;
            defer self.value += 1;
            return .{ self.dest, self.value };
        }
    };

    pub fn generate_batch(self: @This(), iterations: usize) Batch {
        return .{
            .value = self.random.int(u8),
            .dest = self.dest,
            .iterations = iterations,
        };
    }

    pub fn deinit_batch(self: @This(), batch: Batch) void {
        _ = self;
        _ = batch;
    }
};

fn printDistResult(
    writer: *std.Io.Writer,
    results: []const DistResult,
    machine_readable: bool,
) !void {
    if (!machine_readable) {
        try table.format(
            writer,
            &.{
                .{ .fmt = "{s}", .header = "dist", .alignment = .middle },
                .{ .fmt = "{d:.2}", .header = "time (ns)", .alignment = .{ .separator = '.' } },
                .{ .fmt = "{d}", .header = "iterations", .alignment = .right },
                .{ .fmt = "{t}", .header = "termination", .alignment = .middle },
                .{ .fmt = "{d}", .header = "offset", .alignment = .right },
            },
            .{},
            results,
        );
    } else {
        for (results) |result| {
            try writer.print("{s}\t{d}\t{d}\t{d}\n", .{
                result.distribution,
                result.offset,
                result.duration,
                result.iterations,
            });
        }
    }
}

fn printScanResult(
    writer: *std.Io.Writer,
    results: []const ScanResult,
    machine_readable: bool,
) !void {
    if (!machine_readable) {
        try table.format(
            writer,
            &.{
                .{ .fmt = "{d}", .header = "size", .alignment = .right },
                .{ .fmt = "{d:.2}", .header = "time (ns)", .alignment = .{ .separator = '.' } },
                .{ .fmt = "{d}", .header = "iterations", .alignment = .right },
                .{ .fmt = "{t}", .header = "termination", .alignment = .middle },
                .{ .fmt = "{d}", .header = "offset", .alignment = .right },
                .{ .fmt = "{d:.2}", .header = "bytes per ns", .alignment = .{ .separator = '.' } },
            },
            .{},
            results,
        );
    } else {
        for (results) |result| {
            try writer.print("{d}\t{d}\t{d}\t{d}\n", .{
                result.size,
                result.offset,
                result.duration,
                result.iterations,
            });
        }
    }
}

const alignment = if (std.simd.suggestVectorLength(u8)) |len|
    @alignOf(@Vector(len, u8))
else
    @alignOf(usize);

const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

const benchmark = @import("benchmark.zig");
const table = @import("table");

const zli = @import("zli");
