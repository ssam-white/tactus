const Tactus = @This();
const std = @import("std");
const Config = @import("Config.zig");
const SharedDeps = @import("SharedDeps.zig");

exe: *std.Build.Step.Compile,
install_step: *std.Build.Step.InstallArtifact,

pub fn init(b: *std.Build, cfg: *const Config, deps: *const SharedDeps) !Tactus {
    const exe: *std.Build.Step.Compile = b.addExecutable(.{
        .name = "tactus",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = cfg.target,
            .optimize = cfg.optimize
        }),
    });

    const install_step = b.addInstallArtifact(exe, .{});
    try deps.add(exe);

    return .{
        .exe = exe,
        .install_step = install_step
    };
    
}

pub fn install(self: *const Tactus) void {
    const b = self.install_step.step.owner;
    b.getInstallStep().dependOn(&self.install_step.step);
}
