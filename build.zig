const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var lib_dir = try std.fs.cwd().openDir("compiler-rt", .{ .iterate = true });
    defer lib_dir.close();
    var iter = lib_dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        const exe = b.addExecutable(.{
            .name = b.fmt("memcpy-bench-{s}", .{std.fs.path.stem(entry.name)}),
            .root_source_file = .{ .path = "src/benchmark.zig" },
            .target = target,
            .optimize = optimize,
        });
        exe.addObjectFile(.{ .path = b.pathJoin(&.{ "compiler-rt", entry.name }) });

        b.installArtifact(exe);
    }

    const zig_version = @import("builtin").zig_version_string;
    const exe = b.addExecutable(.{
        .name = b.fmt("memcpy-bench-{s}", .{zig_version}),
        .root_source_file = .{ .path = "src/benchmark.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);
}
