const std = @import("std");
const NativeTargetInfo = std.zig.system.NativeTargetInfo;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("libunistring", .{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const dynamic_link_opts: std.Build.Module.LinkSystemLibraryOptions = .{
        .preferred_link_mode = .dynamic,
        .search_strategy = .mode_first,
    };

    if (b.systemIntegrationOption("libunistring", .{})) {
        module.linkSystemLibrary("libunistring", dynamic_link_opts);
    } else {
        _ = try buildLib(b, module, .{
            .target = target,
            .optimize = optimize,
        });
    }
}

fn buildLib(b: *std.Build, module: *std.Build.Module, options: anytype) !*std.Build.Step.Compile {
    const target = options.target;
    const optimize = options.optimize;

    const lib = b.addStaticLibrary(.{
        .name = "libunistring",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();

    if (b.lazyDependency("libunistring", .{})) |upstream| {
        module.addIncludePath(upstream.path("lib"));
        lib.addConfigHeader(b.addConfigHeader(.{
            .style = .{ .cmake = upstream.path("tools/version.h.in") }
        }, .{
            .notcurses_VERSION_MAJOR = 3,
            .notcurses_VERSION_MINOR = 0,
            .notcurses_VERSION_PATCH = 16,
            .notcurses_VERSION_TWEAK = 0,
        }));


        var flags = std.ArrayList([]const u8).init(b.allocator);
        defer flags.deinit();
        try flags.appendSlice(&.{});
        lib.addCSourceFiles(.{
            .root = upstream.path(""),
            .flags = flags.items,
            .files = &.{
                "lib/amemxfrm.c",
                "lib/c-ctype.c",
                "lib/c-strcasecmp.c",
                "lib/c-strncasecmp.c",
                "lib/float.c",
                "lib/frexp.c",
                "lib/frexpl.c",
                "lib/fseterr.c",
                "lib/hard-locale.c",
                "lib/iconv.c",
                "lib/iconv_open.c",
                "lib/isnan.c",
                "lib/isnand.c",
                "lib/isnanf.c",
                "lib/isnanl.c",
                "lib/iswblank.c",
                "lib/iswdigit.c",
                "lib/iswxdigit.c",
                "lib/itold.c",
                "lib/lc-charset-dispatch.c",
                "lib/localcharset.c",
                "lib/localename-table.c",
                "lib/localename.c",
                "lib/malloc.c",
                "lib/malloca.c",
                "lib/math.c",
                "lib/mbchar.c",
                "lib/mbiter.c",
                "lib/mbrtowc.c",
                "lib/mbsinit.c",
                "lib/mbsnlen.c",
                "lib/mbtowc-lock.c",
                "lib/memchr.c",
                "lib/memcmp2.c",
                "lib/printf-args.c",
                "lib/printf-frexp.c",
                "lib/printf-frexpl.c",
                "lib/printf-parse.c",
                "lib/relocatable.c",
                "lib/setlocale-lock.c",
                "lib/setlocale_null.c",
                "lib/signbitd.c",
                "lib/signbitf.c",
                "lib/signbitl.c",
                "lib/striconveh.c",
                "lib/striconveha.c",
                "lib/strncat.c",
                "lib/strstr.c",
                "lib/vasnprintf.c",
                "lib/version.c",
                "lib/wctype-h.c",
                "lib/wcwidth.c",
                "lib/windows-mutex.c",
                "lib/windows-once.c",
                "lib/windows-recmutex.c",
                "lib/windows-rwlock.c",
                "lib/xsize.c",
            },
        });

        lib.installHeadersDirectory(
            upstream.path("lib"),
            "",
            .{ .include_extensions = &.{".h"} },
        );
    }

    b.installArtifact(lib);

    return lib;
}
