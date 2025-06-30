const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const build_options = b.addOptions();
    build_options.addOption(i32, "attr_w", b.option(i32, "attr_w", "integer width of fg and bg attributes") orelse 0);
    build_options.addOption(bool, "egc", b.option(bool, "egc", "enable extended grapheme cluster support") orelse false);
    build_options.addOption(usize, "printf_buf", b.option(usize, "printf_buf", "buffer size for printf operations") orelse 1024);
    build_options.addOption(usize, "read_buf", b.option(usize, "read_buf", "buffer size for tty reads") orelse 8);

    const module = b.addModule("termbox2", .{
        .root_source_file = b.path("src/termbox2.zig"),
        .link_libc = true,
        .optimize = optimize,
        .target = target,
    });
    module.addOptions("build_options", build_options);
    const dynamic_link_opts: std.Build.Module.LinkSystemLibraryOptions = .{
        .preferred_link_mode = .dynamic,
        .search_strategy = .paths_first,
    };

    // try module.lib_paths.append(b.allocator, .{ .cwd_relative = "/usr/local/opt/termbox2/lib" });
    
    try module.include_dirs.append(b.allocator, .{ .path = .{ .cwd_relative = "/usr/local/opt/termbox2/include" }});
    try module.lib_paths.append(b.allocator, .{ .cwd_relative = "/usr/local/opt/termbox2/lib" });

    module.linkSystemLibrary("termbox2", dynamic_link_opts);
}

