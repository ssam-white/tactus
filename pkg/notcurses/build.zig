const std = @import("std");
const NativeTargetInfo = std.zig.system.NativeTargetInfo;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("notcurses", .{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const dynamic_link_opts: std.Build.Module.LinkSystemLibraryOptions = .{
        .preferred_link_mode = .dynamic,
        .search_strategy = .paths_first,
    };

    try module.include_dirs.append(b.allocator, .{ .path = .{ .cwd_relative = "/usr/local/opt/notcurses/include" }});
    try module.lib_paths.append(b.allocator, .{ .cwd_relative = "/usr/local/opt/notcurses/lib" });

    // _ = dynamic_link_opts;
    module.linkSystemLibrary("notcurses", dynamic_link_opts);
    module.linkSystemLibrary("notcurses-core", dynamic_link_opts);

    // if (b.systemIntegrationOption("notcurses", .{})) {
    // } else {
    //     _ = try buildLib(b, module, .{
    //         .target = target,
    //         .optimize = optimize,
    //     });
    // }
}

fn buildLib(b: *std.Build, module: *std.Build.Module, options: anytype) !*std.Build.Step.Compile {
    const target = options.target;
    const optimize = options.optimize;

    const lib = b.addStaticLibrary(.{
        .name = "notcurses",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();

    if (b.lazyDependency("notcurses", .{})) |upstream| {
        lib.addIncludePath(upstream.path("src/lib/"));
        lib.addIncludePath(upstream.path("src/"));
        lib.addIncludePath(upstream.path("include"));
        module.addIncludePath(upstream.path("src"));
        module.addIncludePath(upstream.path("include"));

        // lib.addConfigHeader(b.addConfigHeader(.{
        //     .style = .{ .cmake = upstream.path("tools/version.h.in") },
        // }, .{
        //     .notcurses_VERSION_MAJOR = 3,
        //     .notcurses_VERSION_MINOR = 0,
        //     .notcurses_VERSION_PATCH = 16,
        // }));
        lib.addConfigHeader(b.addConfigHeader(.{
            .style = .{ .cmake = upstream.path("tools/version.h.in") }
        }, .{
            .notcurses_VERSION_MAJOR = 3,
            .notcurses_VERSION_MINOR = 0,
            .notcurses_VERSION_PATCH = 16,
            .notcurses_VERSION_TWEAK = 0,
        }));

        lib.addConfigHeader(b.addConfigHeader(.{
            .style    = .{ .cmake = upstream.path("config.h.in") },
        }, .{
            .DFSG_BUILD               = false,  // OFF by default
            .USE_ASAN                 = false,  // OFF unless you passed USE_ASAN=ON
            .USE_DEFLATE              = true,   // ON by default
            .USE_GPM                  = false,  // OFF by default
            .USE_QRCODEGEN            = false,  // OFF by default
            .USE_FFMPEG               = false,  // OFF unless USE_MULTIMEDIA=ffmpeg
            .USE_OIIO                 = false,  // OFF unless USE_MULTIMEDIA=oiio
            .CMAKE_INSTALL_FULL_DATADIR = "/usr/local/share", // adjust to your install prefix
        }));  




        var flags = std.ArrayList([]const u8).init(b.allocator);
        defer flags.deinit();
        try flags.appendSlice(&.{});
        lib.addCSourceFiles(.{
            .root = upstream.path(""),
            .flags = flags.items,
            .files = &.{
                "src/lib/automaton.c",
                "src/lib/banner.c",
                "src/lib/blit.c",
                "src/lib/debug.c",
                "src/lib/direct.c",
                "src/lib/egcpool.c",
                "src/lib/fade.c",
                "src/lib/fd.c",
                "src/lib/fill.c",
                "src/lib/gpm.c",
                "src/lib/in.c",
                "src/lib/kitty.c",
                "src/lib/layout.c",
                "src/lib/linux.c",
                "src/lib/menu.c",
                "src/lib/metric.c",
                "src/lib/mice.c",
                "src/lib/notcurses.c",
                "src/lib/plot.c",
                "src/lib/progbar.c",
                "src/lib/reader.c",
                "src/lib/reel.c",
                "src/lib/render.c",
                "src/lib/selector.c",
                "src/lib/sixel.c",
                "src/lib/sprite.c",
                "src/lib/stats.c",
                "src/lib/tabbed.c",
                "src/lib/termdesc.c",
                "src/lib/tree.c",
                "src/lib/unixsig.c",
                "src/lib/util.c",
                "src/lib/visual.c",
                "src/lib/windows.c"
             },
        });

        lib.installHeadersDirectory(
            upstream.path("src"),
            "",
            .{ .include_extensions = &.{".h"} },
        );
    }

    b.installArtifact(lib);

    return lib;
}
