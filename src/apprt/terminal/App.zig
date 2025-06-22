const App = @This();
const std = @import("std");
const CoreApp = @import("../../App.zig");
const notcurses = @import("notcurses");

const log = std.log.scoped(.terminal_app);

core_app: *CoreApp,
running: bool = true,
nc: ?*notcurses.c.struct_notcurses = undefined,

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
    const options: notcurses.c.struct_notcurses_options = .{
        .flags = notcurses.c.NCOPTION_INHIBIT_SETLOCALE
    };
     self.nc = notcurses.c.notcurses_init(&options, null);

    const stdn = notcurses.c.notcurses_stdplane(self.nc);
    _ = notcurses.c.ncplane_erase(stdn);
    _ = notcurses.c.notcurses_render(self.nc);
    
    try self.core_app.setup(self);
    while (self.running) {
        try self.core_app.tick(self);
    }
}

pub fn quit(self: *App) void {
    self.running = false;
}
