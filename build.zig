const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const link_libc = b.option(bool, "libc", "Link libc (default: false)") orelse false;

    const dist_mod = b.createModule(.{
        .root_source_file = try addDistributions(b),
    });

    const from_dir = try addFromDir(b, "compiler-rt", dist_mod, target, link_libc);
    if (!from_dir) {
        const zig_version = @import("builtin").zig_version_string;
        const exe = b.addExecutable(.{
            .name = b.fmt("memcpy-bench-{s}", .{zig_version}),
            .root_source_file = b.path("src/memcpy-bench.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .link_libc = link_libc,
        });
        exe.root_module.addImport("distribution", dist_mod);

        b.installArtifact(exe);
    }

    const shared_histogram = b.addSharedLibrary(.{
        .name = "histogram",
        .root_source_file = b.path("src/histogram.zig"),
        .optimize = .ReleaseFast,
        .target = target,
        .link_libc = true,
    });

    b.installArtifact(shared_histogram);

    const static_histogram = b.addStaticLibrary(.{
        .name = "histogram",
        .root_source_file = b.path("src/histogram.zig"),
        .optimize = .ReleaseFast,
        .target = target,
        .link_libc = true,
    });

    b.installArtifact(static_histogram);
}

fn addFromDir(
    b: *std.Build,
    dir: []const u8,
    dist_mod: *std.Build.Module,
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
            .root_source_file = b.path("src/memcpy-bench.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .link_libc = link_libc,
        });
        exe.addObjectFile(b.path(b.pathJoin(&.{ dir, entry.name })));
        exe.root_module.addImport("distribution", dist_mod);

        b.installArtifact(exe);
        has_compiler_rt = true;
    }

    return has_compiler_rt;
}

fn addDistributions(
    b: *std.Build,
) !std.Build.LazyPath {
    const distributions = [_]struct { u8, []const u8 }{
        .{ 'A', "MemcpyGoogleA.csv" },
        .{ 'B', "MemcpyGoogleB.csv" },
        .{ 'D', "MemcpyGoogleD.csv" },
        .{ 'L', "MemcpyGoogleL.csv" },
        .{ 'M', "MemcpyGoogleM.csv" },
        .{ 'Q', "MemcpyGoogleQ.csv" },
        .{ 'S', "MemcpyGoogleS.csv" },
        .{ 'U', "MemcpyGoogleU.csv" },
        .{ 'W', "MemcpyGoogleW.csv" },
    };

    const wf_step = b.addWriteFiles();
    var bytes = try std.ArrayList(u8).initCapacity(b.allocator, 1024);
    for (distributions) |dist| {
        const path = b.pathJoin(&.{ "distributions", dist[1] });
        const csv_file = try b.build_root.handle.openFile(path, .{});
        const csv_data = try csv_file.readToEndAlloc(b.allocator, 1 << 20);
        try bytes.writer().print(
            \\pub const {c}: [4097]f64 = d: {{
            \\    const d = [_]f64{{ {s} }};
            \\    break :d d ++ (.{{0}} ** (4097 - d.len));
            \\}};
            \\
        , .{ dist[0], csv_data });
    }
    return wf_step.add("distribution.zig", bytes.items);
}
