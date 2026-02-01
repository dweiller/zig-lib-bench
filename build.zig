const std = @import("std");
const assert = std.debug.assert;

const BenchDeps = struct {
    memcpy_dist_mod: *std.Build.Module,
    memmove_dist_mod: *std.Build.Module,
    memset_dist_mod: *std.Build.Module,
    zli_mod: *std.Build.Module,
    table_mod: *std.Build.Module,
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const memcpy_object_dir = b.option(
        []const u8,
        "memcpy-object-dir",
        "directory of objects overriding compiler-rt memcpy",
    );

    const memmove_object_dir = b.option(
        []const u8,
        "memmove-object-dir",
        "directory of objects overriding compiler-rt memmove",
    );

    const memset_object_dir = b.option(
        []const u8,
        "memset-object-dir",
        "directory of objects overriding compiler-rt memset",
    );

    const link_libc = b.option(bool, "libc", "Link libc (default: false)") orelse false;

    const deps: BenchDeps = .{
        .memcpy_dist_mod = b.createModule(.{
            .root_source_file = try addDistributions(b, .memcpy),
        }),
        .memmove_dist_mod = b.createModule(.{
            .root_source_file = try addDistributions(b, .memmove),
        }),
        .memset_dist_mod = b.createModule(.{
            .root_source_file = try addDistributions(b, .memset),
        }),
        .zli_mod = b.dependency("zli", .{}).module("zli"),
        .table_mod = b.dependency("simple_tables", .{}).module("table"),
    };

    if (memcpy_object_dir) |dir| {
        try addFromDir(b, dir, deps, target, link_libc, .memcpy);
    }

    if (memmove_object_dir) |dir| {
        try addFromDir(b, dir, deps, target, link_libc, .memmove);
    }

    if (memset_object_dir) |dir| {
        try addFromDir(b, dir, deps, target, link_libc, .memset);
    }

    addBenchExes(
        b,
        deps,
        .zig_compiler,
        .zig_compiler,
        .zig_compiler,
        target,
        link_libc,
    );

    const histogram_mod = b.createModule(.{
        .root_source_file = b.path("src/histogram.zig"),
        .optimize = .ReleaseFast,
        .target = target,
        .link_libc = true,
    });
    const shared_histogram = b.addLibrary(.{
        .name = "histogram",
        .root_module = histogram_mod,
        .linkage = .dynamic,
    });

    b.installArtifact(shared_histogram);

    const static_histogram = b.addLibrary(.{
        .name = "histogram",
        .root_module = histogram_mod,
        .linkage = .static,
    });

    b.installArtifact(static_histogram);
}

const Bench = enum { memcpy, memmove, memset };

fn addFromDir(
    b: *std.Build,
    dir: []const u8,
    deps: BenchDeps,
    target: std.Build.ResolvedTarget,
    link_libc: bool,
    bench: Bench,
) !void {
    var lib_dir = std.fs.cwd().openDir(dir, .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => {
            const fail = b.addFail(b.fmt("directory '{s}' does not exist", .{dir}));
            b.getInstallStep().dependOn(&fail.step);
            return;
        },
        else => return err,
    };
    defer lib_dir.close();

    var iter = lib_dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        const path = b.path(b.pathJoin(&.{ dir, entry.name }));

        addBenchExe(
            b,
            deps,
            .{ .object = path },
            target,
            link_libc,
            bench,
        );
    }
}

const BenchImpl = union(enum) {
    zig_compiler,
    object: std.Build.LazyPath,
};

fn addBenchExe(
    b: *std.Build,
    deps: BenchDeps,
    impl: BenchImpl,
    target: std.Build.ResolvedTarget,
    link_libc: bool,
    bench: Bench,
) void {
    const root_mod = b.createModule(.{
        .root_source_file = b.path(b.fmt("src/{t}-bench.zig", .{bench})),
        .target = target,
        .optimize = .ReleaseFast,
        .link_libc = link_libc,
        .imports = &.{
            .{ .name = "distribution", .module = deps.memcpy_dist_mod },
            .{ .name = "table", .module = deps.table_mod },
            .{ .name = "zli", .module = deps.zli_mod },
        },
    });

    switch (impl) {
        .zig_compiler => {},
        .object => |path| {
            root_mod.addObjectFile(path);
        },
    }

    const version_string = switch (impl) {
        .zig_compiler => @import("builtin").zig_version_string,
        .object => |path| std.fs.path.stem(path.basename(b, null)),
    };

    const exe = b.addExecutable(.{
        .name = b.fmt("{t}-bench-{s}", .{ bench, version_string }),
        .root_module = root_mod,
    });

    b.installArtifact(exe);
}

fn addBenchExes(
    b: *std.Build,
    deps: BenchDeps,
    memcpy_impl: BenchImpl,
    memmove_impl: BenchImpl,
    memset_impl: BenchImpl,
    target: std.Build.ResolvedTarget,
    link_libc: bool,
) void {
    addBenchExe(b, deps, memcpy_impl, target, link_libc, .memcpy);
    addBenchExe(b, deps, memmove_impl, target, link_libc, .memmove);
    addBenchExe(b, deps, memset_impl, target, link_libc, .memset);
}

fn addDistributions(
    b: *std.Build,
    mem_func: Bench,
) !std.Build.LazyPath {
    const distributions = [_]u8{ 'A', 'B', 'D', 'L', 'M', 'Q', 'S', 'U', 'W' };

    const wf_step = b.addWriteFiles();
    var bytes = try std.ArrayList(u8).initCapacity(b.allocator, 1024);

    for (distributions) |dist| {
        const path = b.pathJoin(&.{
            "distributions",
            switch (mem_func) {
                inline else => |f| .{'M'} ++ @tagName(f)[1..] ++ "Google" ++ .{dist} ++ ".csv",
            },
        });
        const csv_file = try b.build_root.handle.openFile(path, .{});

        var evented_io: std.Io.Threaded = .init_single_threaded;
        var csv_reader = csv_file.reader(evented_io.io(), &.{});

        try bytes.print(b.allocator, "pub const {c} = [_]f64{{ ", .{dist});
        try csv_reader.interface.appendRemaining(b.allocator, &bytes, .unlimited);
        try bytes.print(b.allocator, " }};", .{});
    }
    return wf_step.add(
        switch (mem_func) {
            inline else => |f| @tagName(f) ++ "-distribution.zig",
        },
        bytes.items,
    );
}
