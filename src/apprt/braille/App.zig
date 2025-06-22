const App = @This();
const std = @import("std");
const log = std.log.scoped(.braille_app);
const CoreApp = @import("../../App.zig");
const Surface = @import("../../ui/Surface.zig");
const brlapi = @import("../../lib/brlapi.zig");
const apprt = @import("../../apprt.zig");

core_app: *CoreApp,
running: bool = true,
sleep_cond: std.Thread.Condition = .{},
mutex: std.Thread.Mutex = .{},

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
    log.info("openning brlapi connection", .{});
    _ = try brlapi.openConnection(.{});
    log.info("entering tty mode", .{});
    _ = try brlapi.enterTtyMode(1, null);

    try self.core_app.setup(self);
    while (self.running) {

        try self.core_app.tick(self);
    }
}

pub fn quit(self: *App) void {
    brlapi.leaveTtyMode() catch unreachable;
    log.info("leaving tty mode", .{});
    brlapi.closeConnection();
    log.info("closing brltty connection", .{});
    self.running = false;
}

pub fn redrawSurface(self: App, surface: *Surface) void {
    _ = surface;
    _ = self;
    log.debug("redrawing surface", .{});
}

pub fn wakeup(self: *App) void {
    self.mutex.lock();
    defer self.mutex.unlock();
    self.sleep_cond.signal();
}

pub fn performAction(
    self: *App,
    comptime action: apprt.Action.Key,
    value: apprt.Action.Value(action)
) !bool {
        _ = value;
        switch (action) {
            .quit => self.quit(),
        }
}
