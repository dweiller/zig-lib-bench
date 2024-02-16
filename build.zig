const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const link_libc = b.option(bool, "libc", "Link libc (default: false)") orelse false;

    const from_dir = try addFromDir(b, "compiler-rt", optimize, target, link_libc);
    if (!from_dir) {
        const zig_version = @import("builtin").zig_version_string;
        const exe = b.addExecutable(.{
            .name = b.fmt("memcpy-bench-{s}", .{zig_version}),
            .root_source_file = .{ .path = "src/benchmark.zig" },
            .target = target,
            .optimize = optimize,
            .link_libc = link_libc,
        });

        b.installArtifact(exe);
    }

    const shared_histogram = b.addSharedLibrary(.{
        .name = "histogram",
        .root_source_file = .{ .path = "src/histogram.zig" },
        .optimize = .ReleaseFast,
        .target = target,
        .link_libc = true,
    });

    b.installArtifact(shared_histogram);

    const static_histogram = b.addStaticLibrary(.{
        .name = "histogram",
        .root_source_file = .{ .path = "src/histogram.zig" },
        .optimize = .ReleaseFast,
        .target = target,
        .link_libc = true,
    });

    b.installArtifact(static_histogram);
}

fn addFromDir(
    b: *std.Build,
    dir: []const u8,
    optimize: std.builtin.OptimizeMode,
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
        const exe = b.addExecutable(.{
            .name = b.fmt("memcpy-bench-{s}", .{std.fs.path.stem(entry.name)}),
            .root_source_file = .{ .path = "src/benchmark.zig" },
            .target = target,
            .optimize = optimize,
            .link_libc = link_libc,
        });
        exe.addObjectFile(.{ .path = b.pathJoin(&.{ dir, entry.name }) });

        b.installArtifact(exe);
        has_compiler_rt = true;
    }

    return has_compiler_rt;
}
