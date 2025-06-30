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

    if (self.config.app_runtime == .braille) {
        if (b.lazyDependency("brlapi", .{
            .target = target,
            .optimize = optimize,
        })) |dep| {
            step.root_module.addImport("brlapi", dep.module("brlapi"));
        }
    }

    if (self.config.app_runtime == .terminal) {
        if (b.lazyDependency("ncurses", .{
            .target = target,
            .optimize = optimize,
        })) |dep| {
            step.root_module.addImport("ncurses", dep.module("ncurses"));
        }
    }
}

