pub const Options = struct {
    min_duration: u64 = 0,
    max_duration: u64 = 10 * std.time.ns_per_s,
    min_samples: u32 = 4,
    max_samples: u32 = 1000,
    initial_iterations: u32 = 4,
    max_iterations: u32 = 10_000_000,
    epsilon: f32 = 0.01,
    scale_factor: u32 = 40,
};

pub const TerminationCondition = enum {
    duration,
    samples,
    precision,
    iterations,
};

pub const Result = struct {
    duration: f64,
    iterations: u32,
    termination: TerminationCondition,
};

const Error = error{ IdempotentScale, ParamGen } || std.time.Timer.Error;

pub fn benchmark(
    options: Options,
    comptime func: anytype,
    param_generator: anytype,
) Error!Result {
    const factor = 100 + options.scale_factor;
    if (factor > 100 and (factor * options.initial_iterations) / 100 == options.initial_iterations) {
        return error.IdempotentScale;
    }

    var total_samples: u32 = 0;
    var total_duration: u64 = 0;
    var total_iterations: u32 = 0;

    var iterations = options.initial_iterations;
    var timer = try std.time.Timer.start();

    var duration_per_iter = std.math.floatMax(f64);
    var termination: ?TerminationCondition = null;

    while (true) {
        const GenType = switch (@typeInfo(@TypeOf(param_generator))) {
            .pointer => |p| p.child,
            else => @TypeOf(param_generator),
        };
        const RetType = @typeInfo(@typeInfo(@TypeOf(GenType.generate_batch)).@"fn".return_type.?);

        var param_batch = switch (RetType) {
            .error_union => param_generator.generate_batch(iterations) catch return error.ParamGen,
            else => param_generator.generate_batch(iterations),
        };
        defer param_generator.deinit_batch(param_batch);

        timer.reset();
        while (param_batch.next()) |params| {
            const r = @call(.auto, func, params);
            std.mem.doNotOptimizeAway(r);
        }
        const elapsed_ns = timer.read();

        total_samples += 1;
        total_duration += elapsed_ns;
        total_iterations += iterations;

        const ratio = ratio: {
            const total_f64: f64 = @floatFromInt(total_duration);
            const iters_f64: f64 = @floatFromInt(total_iterations);

            const new = total_f64 / iters_f64;
            defer duration_per_iter = new;

            break :ratio @abs((duration_per_iter / new) - 1);
        };

        if (total_duration >= options.min_duration and
            total_samples >= options.min_samples and ratio < options.epsilon)
        {
            termination = .precision;
        } else if (total_samples >= options.max_samples) {
            termination = .samples;
        } else if (total_duration >= options.max_duration) {
            termination = .duration;
        } else if (iterations >= options.max_iterations) {
            termination = .iterations;
        }

        if (termination) |term| {
            return .{
                .duration = duration_per_iter,
                .iterations = total_iterations,
                .termination = term,
            };
        }

        const new_iterations = (factor * iterations) / 100;
        assert(new_iterations >= iterations);
        iterations = new_iterations;
    }
}

const std = @import("std");
const assert = std.debug.assert;
