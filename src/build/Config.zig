const Config = @This();
const std = @import("std");
const apprt = @import("../apprt.zig");

optimize: std.builtin.OptimizeMode,
target: std.Build.ResolvedTarget,
app_runtime: apprt.Runtime = .none,

pub fn init(b: *std.Build) !Config {
    const optomize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    var config: Config = .{
        .optimize = optomize,
        .target = target,
    };

    config.app_runtime = b.option(
        apprt.Runtime,
        "app-runtime",
        "The app runtime to use."
    ) orelse apprt.Runtime.default(target.result);

    return config;
}

pub fn fromOptions() Config {
    const options = @import("build_options");
    return .{
        .optimize = undefined,
        .target = undefined,
        .app_runtime = std.meta.stringToEnum(apprt.Runtime, @tagName(options.app_runtime)).?
    };
}

pub fn addOptions(self: *const Config, step: *std.Build.Step.Options) !void {
    step.addOption(apprt.Runtime, "app_runtime", self.app_runtime);
}
