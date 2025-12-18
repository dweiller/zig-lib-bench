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

    const object_dir = b.option(
        []const u8,
        "object-dir",
        "directory of objects overriding compiler-rt functions",
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

    const from_dir = if (object_dir) |dir|
        try addFromDir(b, dir, deps, target, link_libc)
    else
        false;
    if (!from_dir) {
        const memcpy_exe, const memmove_exe, const memset_exe = addBenchExes(
            b,
            deps,
            .zig_compiler,
            target,
            link_libc,
        );
        b.installArtifact(memcpy_exe);
        b.installArtifact(memmove_exe);
        b.installArtifact(memset_exe);
    }

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

fn addFromDir(
    b: *std.Build,
    dir: []const u8,
    deps: BenchDeps,
    target: std.Build.ResolvedTarget,
    link_libc: bool,
) !bool {
    var lib_dir = std.fs.cwd().openDir(dir, .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => return false,
        else => return err,
    };
    defer lib_dir.close();

    var has_compiler_rt = false;

    var iter = lib_dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        const path = b.path(b.pathJoin(&.{ dir, entry.name }));

        const memcpy_exe, const memmove_exe, const memset_exe = addBenchExes(
            b,
            deps,
            .{ .object = path },
            target,
            link_libc,
        );
        b.installArtifact(memcpy_exe);
        b.installArtifact(memmove_exe);
        b.installArtifact(memset_exe);

        has_compiler_rt = true;
    }

    return has_compiler_rt;
}

fn addBenchExes(
    b: *std.Build,
    deps: BenchDeps,
    impl: union(enum) {
        zig_compiler,
        object: std.Build.LazyPath,
    },
    target: std.Build.ResolvedTarget,
    link_libc: bool,
) struct { *std.Build.Step.Compile, *std.Build.Step.Compile, *std.Build.Step.Compile } {
    const memcpy_root = b.createModule(.{
        .root_source_file = b.path("src/memcpy-bench.zig"),
        .target = target,
        .optimize = .ReleaseFast,
        .link_libc = link_libc,
        .imports = &.{
            .{ .name = "distribution", .module = deps.memcpy_dist_mod },
            .{ .name = "table", .module = deps.table_mod },
        },
    });

    const memmove_root = b.createModule(.{
        .root_source_file = b.path("src/memmove-bench.zig"),
        .target = target,
        .optimize = .ReleaseFast,
        .link_libc = link_libc,
        .imports = &.{
            .{ .name = "distribution", .module = deps.memmove_dist_mod },
            .{ .name = "zli", .module = deps.zli_mod },
            .{ .name = "table", .module = deps.table_mod },
        },
    });

    const memset_root = b.createModule(.{
        .root_source_file = b.path("src/memset-bench.zig"),
        .target = target,
        .optimize = .ReleaseFast,
        .link_libc = link_libc,
        .imports = &.{
            .{ .name = "distribution", .module = deps.memset_dist_mod },
            .{ .name = "zli", .module = deps.zli_mod },
            .{ .name = "table", .module = deps.table_mod },
        },
    });

    switch (impl) {
        .zig_compiler => {},
        .object => |path| {
            memcpy_root.addObjectFile(path);
            memmove_root.addObjectFile(path);
            memset_root.addObjectFile(path);
        },
    }

    const version_string = switch (impl) {
        .zig_compiler => @import("builtin").zig_version_string,
        .object => |path| std.fs.path.stem(path.basename(b, null)),
    };

    const memcpy_exe = b.addExecutable(.{
        .name = b.fmt("memcpy-bench-{s}", .{version_string}),
        .root_module = memcpy_root,
    });

    const memmove_exe = b.addExecutable(.{
        .name = b.fmt("memmove-bench-{s}", .{version_string}),
        .root_module = memmove_root,
    });

    const memset_exe = b.addExecutable(.{
        .name = b.fmt("memset-bench-{s}", .{version_string}),
        .root_module = memset_root,
    });

    return .{ memcpy_exe, memmove_exe, memset_exe };
}

fn addDistributions(
    b: *std.Build,
    mem_func: enum { memcpy, memmove, memset },
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
