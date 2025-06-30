const std = @import("std");
const buildpkg = @import("src/build/main.zig");

comptime {
    buildpkg.requireZig("0.14.0");
}

pub fn build(b: *std.Build) !void {
    const config = try buildpkg.Config.init(b);
    const deps = try buildpkg.SharedDeps.init(b, &config);
    const exe = try buildpkg.TactusExe.init(b, &config, &deps);

    // run step
    {
        const run_cmd = b.addRunArtifact(exe.exe);
        if (b.args) |args| run_cmd.addArgs(args);
        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    // tests
    {
        const test_step = b.step("test", "Run all tests");
        const test_filter = b.option([]const u8, "test-filter", "Filter for test");
        const test_exe = b.addTest(.{
            .name = "tactus-test",
            .filters = if (test_filter) |v| &.{v} else &.{},
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/main.zig"),
                .target = config.target,
                .optimize = .Debug,
            }),
        });
        {
            b.installArtifact(test_exe);
            try deps.add(test_exe);
            const test_run = b.addRunArtifact(test_exe);
            test_step.dependOn(&test_run.step);
        }
    }
}
