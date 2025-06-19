const SharedDeps = @This();
const std = @import("std");
const Config = @import("Config.zig");

config: *const Config,
options: *std.Build.Step.Options,

pub fn init(b: *std.Build, cfg: *const Config) !SharedDeps {
    var result: SharedDeps = .{
        .config = cfg,
        .options = undefined
    };
    try result.initTarget(b, cfg.target);
    return result;
}

fn initTarget(
    self: *SharedDeps,
    b: *std.Build,
    target: std.Build.ResolvedTarget
) !void {
    const config = try b.allocator.create(Config);
    config.* = self.config.*;
    config.target = target;
    self.config = config;

    self.options = b.addOptions();
    try self.config.addOptions(self.options);
}

pub fn add(
    self: *const SharedDeps,
    step: *std.Build.Step.Compile
) !void {
    const b = step.step.owner;

    const target = step.root_module.resolved_target.?;
    const optimize = step.root_module.optimize.?;
       
    step.root_module.addOptions("build_options", self.options);

    if (b.lazyDependency("libxev", .{
        .target = target,
        .optimize = optimize
    })) |dep| {
        step.root_module.addImport("xev", dep.module("xev"));
    }

    if (step.rootModuleTarget().os.tag == .linux) {
        step.addObjectFile(.{ .cwd_relative = "/usr/lib/libbrlapi.a" });
    }

    if (step.rootModuleTarget().os.tag == .macos) {
        step.addIncludePath(.{ .cwd_relative = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.1.sdk/usr/include/" });
    }
}

