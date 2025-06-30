const std = @import("std");
const buildpkg = @import("src/build/main.zig");

pub fn build(b: *std.Build) !void {
    const config = try buildpkg.Config.init(b);
    const deps = try buildpkg.SharedDeps.init(b, &config);
    const exe = try buildpkg.TactusExe.init(b, &config, &deps);

    exe.install();
}
