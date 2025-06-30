const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("ncurses", .{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const dynamic_link_opts: std.Build.Module.LinkSystemLibraryOptions = .{
        .preferred_link_mode = .static,
        .search_strategy = .paths_first,
    };

    try module.include_dirs.append(b.allocator, .{ .path = .{ .cwd_relative = "/usr/local/opt/ncurses/include" }});
    try module.lib_paths.append(b.allocator, .{ .cwd_relative = "/usr/local/opt/ncurses/lib" });

    module.linkSystemLibrary("ncurses", dynamic_link_opts);
}
