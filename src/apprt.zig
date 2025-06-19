const std = @import("std");
const braille = @import("apprt/braille.zig");
const terminal = @import("apprt/terminal.zig");
const action = @import("apprt/action.zig");
const build_config = @import("build_config.zig");

const Action = action.Action;

pub const Runtime = enum {
    none,
    braille,
    terminal,

    pub fn default(target: std.Target) Runtime {
        return switch (target.os.tag) {
            .linux => .braille,
            .macos => .terminal,
            else => .none
        };
    }
};

pub const runtime = switch (build_config.app_runtime) {
    .terminal => terminal,
    .braille => braille,
    .none => braille,
};

pub const App = runtime.App;
pub const Surface = runtime.Surface;
