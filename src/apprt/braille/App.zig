const App = @This();
const std = @import("std");
const log = std.log.scoped(.braille_app);
const CoreApp = @import("../../App.zig");
const Surface = @import("../../Surface.zig");

core_app: *CoreApp,
running: bool = true,

pub fn init(core_app: *CoreApp, opts: anytype) !App {
    _ = opts;
    return .{
        .core_app = core_app
    };
}

pub fn terminate(self: *App) void {
    _ = self;
}

pub fn run(self: *App) !void {
    while (self.running) {
        try self.core_app.tick(self);

        const must_quit = false;

        if (must_quit) self.quit();
    }
}

pub fn quit(self: *App) void {
    self.running = false;
}

pub fn redrawSurface(self: App, surface: *Surface) void {
    _ = surface;
    _ = self;
    log.debug("redrawing surface", .{});
}

pub fn wakeup(_: *App) void {}
