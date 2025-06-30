const Config = @This();
const std = @import("std");

optimize: std.builtin.OptimizeMode,
target: std.Build.ResolvedTarget,

pub fn init(b: *std.Build) !Config {
    const optomize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const config: Config = .{
        .optimize = optomize,
        .target = target,
    };

    return config;
}

pub fn fromOptions() Config {
    const options = @import("build_options");
    _ = options;
    return .{
        .optimize = undefined,
        .target = undefined,
    };
}

pub fn addOptions(self: *const Config, step: *std.Build.Step.Options) !void {
    _ = self; _ = step;
}
