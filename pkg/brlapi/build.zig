const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("brlapi", .{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // const lib = try buildLib(b, module, .{
    //     .target = target,
    //     .optimize = optimize,
    // });
   
    if (b.systemIntegrationOption("brlapi", .{})) {
        module.linkSystemLibrary("brlapi", dynamic_link_opts);
    }
    // else {
    //     module.linkLibrary(lib);
    //     b.installArtifact(lib);
    // }
}

fn buildLib(
    b: *std.Build,
    module: *std.Build.Module,
    options: anytype,
) !*std.Build.Step.Compile {
    const target = options.target;
    const optimize = options.optimize;

    const lib = b.addStaticLibrary(.{
        .name = "brlapi",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();

    const upstream = b.lazyDependency("brlapi", .{}) orelse return lib;
    lib.addIncludePath(upstream.path("include"));
    module.addIncludePath(upstream.path("include"));
    lib.installHeadersDirectory(upstream.path("include/brlapi"), "GLFW", .{});

    return lib;
}

const dynamic_link_opts: std.Build.Module.LinkSystemLibraryOptions = .{
    .preferred_link_mode = .dynamic,
    .search_strategy = .mode_first,
};


