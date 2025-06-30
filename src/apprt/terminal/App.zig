const App = @This();
const std = @import("std");
const CoreApp = @import("../../App.zig");
const Surface = @import("Surface.zig");
const Renderer = @import("Renderer.zig");
const ncurses = @import("ncurses");

const Allocator = std.mem.Allocator;

const log = std.log.scoped(.terminal_app);


core_app: *CoreApp,
running: bool = true,
renderer: Renderer,

pub fn init(core_app: *CoreApp, conf: anytype) !App {
    _ = conf;
    return .{
        .core_app = core_app,
    };
}

pub fn terminate(self: *App) void {
    _ = self;
    _ = ncurses.c.endwin();
}

pub fn run(self: *App) !void {
    _ = ncurses.c.initscr();
    try self.core_app.setup(self);
    while (self.running) {
        _ = ncurses.c.getch();
        try self.core_app.tick(self);
    }
}

pub fn quit(self: *App) void {
    self.running = false;
}

pub fn render(self: *App) void {
    self.renderer.render(self);
}
