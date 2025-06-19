const App = @This();
const std = @import("std");
const CoreApp = @import("../../App.zig");

const log = std.log.scoped(.terminal_app);

core_app: *CoreApp,

pub fn init(core_app: *CoreApp, conf: anytype) !App {
    _ = conf;
    return .{
        .core_app = core_app
    };
}

pub fn terminate(self: *App) void {
    _ = self;
}

pub fn run(self: *App) !void {
    _ = self;
    log.debug("Starting terminal runtime", .{});
}
